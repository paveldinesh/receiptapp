import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  static const String _apiKeyPrefKey = 'gemini_api_key';
  static const String _geminiEnabledPrefKey = 'gemini_enabled';
  static const String _tokenSaverPrefKey = 'gemini_token_saver_mode';

  // Default API endpoint using lightweight, efficient gemini-1.5-flash
  static const String _geminiModel = 'gemini-1.5-flash';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$_geminiModel:generateContent';

  /// Save Gemini API key in SharedPreferences
  static Future<void> setApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPrefKey, apiKey.trim());
  }

  /// Get saved Gemini API key
  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPrefKey);
  }

  /// Enable or disable Gemini processing
  static Future<void> setGeminiEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_geminiEnabledPrefKey, enabled);
  }

  /// Check if Gemini processing is enabled (defaults to true)
  static Future<bool> isGeminiEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_geminiEnabledPrefKey) ?? true;
  }

  /// Set Token Saver Mode (Text-only prompt vs Multimodal vision)
  static Future<void> setTokenSaverMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tokenSaverPrefKey, enabled);
  }

  /// Get Token Saver Mode
  static Future<bool> isTokenSaverMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tokenSaverPrefKey) ?? true; // Default to true to conserve tokens
  }

  /// Parse receipt using Gemini REST API with strict max token limit (500 tokens max)
  static Future<Map<String, dynamic>?> parseReceipt({
    required String ocrText,
    File? imageFile,
  }) async {
    try {
      final apiKey = await getApiKey();
      final isEnabled = await isGeminiEnabled();

      if (!isEnabled) {
        debugPrint('Gemini processing is disabled by user.');
        return null;
      }

      if (apiKey == null || apiKey.isEmpty) {
        debugPrint('Gemini API key not configured.');
        return null;
      }

      final tokenSaver = await isTokenSaverMode();

      // System instruction for structured JSON extraction
      const promptText = '''
Extract receipt details from this text into concise JSON only. Do not include markdown formatting, code blocks, or extra text.
Target JSON Schema:
{
  "merchant": "string",
  "category": "Electronics|Food|Grocery|Fashion|Travel|Health|Other",
  "purchaseDate": "YYYY-MM-DD or null if date is missing, blurred, or unreadable",
  "currency": "₹",
  "subtotal": 0.0,
  "tax": 0.0,
  "totalAmount": 0.0,
  "paymentMethod": "Credit Card|UPI|Cash",
  "invoiceNumber": "string",
  "warrantyMonths": 12,
  "products": [{"name": "string", "quantity": 1, "price": 0.0}],
  "line_items": [{"name": "string", "quantity": 1, "rate": 0.0, "amount": 0.0}]
}

Instructions:
1. Distinguish receipt metadata labels (e.g. Table No, Bill No, Guest, Billed By, Server, Order No, Token No) from the actual merchant name and line items. The merchant is the store or restaurant name, not metadata labels or values.
2. For line_items: extract only the actual products/services purchased with their respective quantity, rate, and amount. Never fabricate or include metadata rows. If no individual items are detected, return an empty array.
3. For invoiceNumber: Extract the exact invoice or bill number from the text. Never fabricate, guess, or prefix with "INV-" if it is not present in the source text. If no invoice number is found, return null.
''';

      final List<Map<String, dynamic>> contents = [];

      // If token saver is OFF and an image file is provided, add low-res base64 image
      if (!tokenSaver && imageFile != null && await imageFile.exists()) {
        final imageBytes = await _downsampleImage(imageFile);
        if (imageBytes != null) {
          final base64Image = base64Encode(imageBytes);
          contents.add({
            'parts': [
              {'text': '$promptText\n\nOCR Raw Text:\n$ocrText'},
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': base64Image,
                }
              }
            ]
          });
        }
      }

      // Default / Token-Saver path: Send compact text prompt only
      if (contents.isEmpty) {
        contents.add({
          'parts': [
            {'text': '$promptText\n\nOCR Raw Text:\n$ocrText'}
          ]
        });
      }

      final requestBody = jsonEncode({
        'contents': contents,
        'generationConfig': {
          'temperature': 0.1,
          'maxOutputTokens': 700, // Token Cap: 700 tokens to accommodate line_items arrays
          'responseMimeType': 'application/json',
        }
      });

      final response = await http
          .post(
            Uri.parse('$_baseUrl?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: requestBody,
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = responseJson['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final firstCandidate = candidates.first as Map<String, dynamic>;
          final content = firstCandidate['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List<dynamic>?;
          if (parts != null && parts.isNotEmpty) {
            String rawJsonText = parts.first['text'] as String? ?? '';

            // Strip markdown block if present
            rawJsonText = rawJsonText
                .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
                .replaceAll(RegExp(r'^```\s*$', multiLine: true), '')
                .trim();

            final Map<String, dynamic> parsedMap = jsonDecode(rawJsonText) as Map<String, dynamic>;
            
            // 1. Merchant name safety verification
            String? merchant = parsedMap['merchant'] as String?;
            if (merchant != null) {
              final mLower = merchant.toLowerCase();
              final invalidMerchantLabels = [
                'table no', 'bill no', 'guest', 'billed by', 
                'order no', 'token no', 'covers', 'server', 'receipt'
              ];
              for (final label in invalidMerchantLabels) {
                if (mLower.contains(label)) {
                  merchant = null;
                  break;
                }
              }
              parsedMap['merchant'] = merchant ?? '';
            }

            // 2. Invoice number verbatim check
            String? inv = parsedMap['invoiceNumber'] as String?;
            if (inv != null && inv.isNotEmpty) {
              // Discard if not verbatim in raw OCR text
              if (!ocrText.contains(inv)) {
                parsedMap['invoiceNumber'] = null;
              }
            }

            // 3. Line items metadata check & cleaning
            final items = parsedMap['line_items'] as List<dynamic>?;
            if (items != null) {
              final cleanedItems = <dynamic>[];
              final invalidItemLabels = [
                'table no', 'bill no', 'guest', 'billed by',
                'order no', 'token no', 'covers', 'server', 'total', 'subtotal', 'tax'
              ];
              for (final item in items) {
                if (item is Map) {
                  final name = (item['name'] as String? ?? '').toLowerCase();
                  bool isMetadata = false;
                  for (final label in invalidItemLabels) {
                    if (name.contains(label)) {
                      isMetadata = true;
                      break;
                    }
                  }
                  if (!isMetadata) {
                    cleanedItems.add(item);
                  }
                }
              }
              parsedMap['line_items'] = cleanedItems;
            }

            debugPrint('Gemini parsed receipt successfully: ${parsedMap['merchant']}');
            return parsedMap;
          }
        }
      } else {
        debugPrint('Gemini API Error [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      debugPrint('Gemini processing exception: $e');
    }
    return null;
  }

  /// Downsamples receipt image to max 600px dimension to minimize vision token cost
  static Future<Uint8List?> _preprocessAndResize(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return bytes;

      if (decoded.width > 600 || decoded.height > 600) {
        final resized = img.copyResize(
          decoded,
          width: decoded.width > decoded.height ? 600 : null,
          height: decoded.height >= decoded.width ? 600 : null,
        );
        return Uint8List.fromList(img.encodeJpg(resized, quality: 75));
      }
      return bytes;
    } catch (_) {
      return null;
    }
  }

  static Future<Uint8List?> _downsampleImage(File imageFile) => _preprocessAndResize(imageFile);
}
