import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class CloudFunctionsService {
  Future<Map<String, dynamic>> parseReceiptText(String ocrText, {bool isFirebaseAvailable = false}) async {
    if (isFirebaseAvailable) {
      try {
        final result = await FirebaseFunctions.instance
            .httpsCallable('parseReceiptWithGemini')
            .call({'text': ocrText});
        
        final dynamic rawData = result.data;
        if (rawData is Map) {
          return {...Map<String, dynamic>.from(rawData), 'source': 'gemini'};
        } else if (rawData is String) {
          return {...Map<String, dynamic>.from(json.decode(rawData)), 'source': 'gemini'};
        }
      } catch (e) {
        debugPrint('Cloud Function call failed: $e. Falling back to local parser.');
      }
    }
    
    return _parseOcrTextLocally(ocrText);
  }

  Map<String, dynamic> _parseOcrTextLocally(String text) {
    final lowerText = text.toLowerCase();
    
    // Guess Category
    String category = 'Other';
    if (lowerText.contains('restaurant') || lowerText.contains('ramen') || lowerText.contains('food') || lowerText.contains('cafe') || lowerText.contains('starbucks') || lowerText.contains('coffee')) {
      category = 'Food';
    } else if (lowerText.contains('croma') || lowerText.contains('digital') || lowerText.contains('reliance') || lowerText.contains('electronics')) {
      category = 'Electronics';
    } else if (lowerText.contains('zara') || lowerText.contains('fashion')) {
      category = 'Fashion';
    } else if (lowerText.contains('grocery') || lowerText.contains('zepto') || lowerText.contains('bigbasket')) {
      category = 'Grocery';
    } else if (lowerText.contains('uber') || lowerText.contains('travel') || lowerText.contains('flight')) {
      category = 'Travel';
    } else if (lowerText.contains('health') || lowerText.contains('medical') || lowerText.contains('pharmacy')) {
      category = 'Health';
    }

    // Replace the local total extraction:
    double totalAmount = 0;
    final money = RegExp(r'(\d{1,3}(?:,\d{2,3})+(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?)');
    for (final line in text.split('\n').reversed) {
      final l = line.toLowerCase();
      if (l.contains('subtotal') || l.contains('sub total')) continue;
      if (RegExp(r'total|net amount|amount due|amt due').hasMatch(l)) {
        final all = money.allMatches(line).toList();
        if (all.isNotEmpty) {
          totalAmount = double.tryParse(all.last.group(1)!.replaceAll(',', '')) ?? 0;
          break;
        }
      }
    }

    final currency = lowerText.contains('\$') ? '\$' : '₹';
    final invRegex = RegExp(r'(?:bill\s*no|inv|invoice|receipt\s*#?)[:\s]+([a-zA-Z0-9\-]+)', caseSensitive: false);
    final invMatch = invRegex.firstMatch(text);
    int? warrantyMonths;

    return {
      'source': 'local',
      'merchant': '',
      'category': category,
      'purchaseDate': null,
      'currency': currency,
      'subtotal': totalAmount,
      'tax': 0.0,
      'totalAmount': totalAmount,
      'paymentMethod': lowerText.contains('card') ? 'Credit Card' : 'UPI',
      'invoiceNumber': invMatch?.group(1) ?? '',
      'warrantyMonths': warrantyMonths,
      'products': [],
    };
  }
}
