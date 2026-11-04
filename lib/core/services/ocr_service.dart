import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class OcrService {
  /// Runs Google ML Kit local OCR pipeline after pre-processing low contrast images
  static Future<RecognizedText> recognizeReceiptText(File imageFile) async {
    // 1. Image preprocessing (Sharpen / Convert grayscale to improve ML Kit recognition accuracy)
    final File processedFile = await _preprocessImage(imageFile);

    // 2. Instantiate local ML Kit text recognizer
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final InputImage inputImage = InputImage.fromFile(processedFile);
    
    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText;
    } finally {
      await textRecognizer.close();
    }
  }

  static Future<File> _preprocessImage(File originalFile) async {
    try {
      final bytes = await originalFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return originalFile;

      // Apply Grayscale and Contrast enhancement filter
      img.grayscale(image);
      img.adjustColor(image, contrast: 1.2);

      final processedBytes = img.encodeJpg(image, quality: 85);
      final String tempPath = '${originalFile.path}_processed.jpg';
      final File tempFile = File(tempPath);
      await tempFile.writeAsBytes(processedBytes);
      return tempFile;
    } catch (_) {
      return originalFile;
    }
  }
}

class ReceiptProcessingError implements Exception {
  final String code;
  final String message;
  final bool isTransient;

  ReceiptProcessingError({
    required this.code,
    required this.message,
    this.isTransient = false,
  });

  @override
  String toString() => 'ReceiptProcessingError[$code]: $message';
}

enum ReceiptProcessingState {
  idle,
  capturing,
  preparingImage,
  readingText,
  analysingReceipt,
  validating,
  completed,
  failed,
  cancelled,
}

class ReceiptItem {
  final String name;
  final int quantity;
  final double price;

  ReceiptItem({required this.name, this.quantity = 1, required this.price});

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      name: json['name'] as String? ?? 'Unknown Item',
      quantity: json['quantity'] as int? ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ReceiptData {
  final String? merchantName;
  final String? purchaseDate;
  final double? total;
  final double? tax;
  final List<ReceiptItem> items;

  ReceiptData({
    this.merchantName,
    this.purchaseDate,
    this.total,
    this.tax,
    this.items = const [],
  });

  factory ReceiptData.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return ReceiptData(
      merchantName: json['merchantName'] as String?,
      purchaseDate: json['purchaseDate'] as String?,
      total: (json['total'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
      items: rawItems.map((e) => ReceiptItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  ReceiptData copyWith({
    String? merchantName,
    String? purchaseDate,
    double? total,
    double? tax,
    List<ReceiptItem>? items,
  }) {
    return ReceiptData(
      merchantName: merchantName ?? this.merchantName,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      total: total ?? this.total,
      tax: tax ?? this.tax,
      items: items ?? this.items,
    );
  }
}

class LocalReceiptParser {
  static bool isUsableReceiptText(String text) {
    final normalized = text.trim();
    if (normalized.length < 20) return false;
    
    final containsAmount = RegExp(r'\d+[.,]\d{2}').hasMatch(normalized);
    final containsKeyword = RegExp(
      r'(total|subtotal|tax|amount|invoice|receipt|bill|gst|vat)', 
      caseSensitive: false
    ).hasMatch(normalized);

    return containsAmount || containsKeyword;
  }

  static ReceiptData parseReceiptLocally(String rawText) {
    final lines = rawText.split('\n');
    double? detectedTotal;
    String? detectedDate;

    final dateRegex = RegExp(r'(\d{2}[-/.]\d{2}[-/.]\d{2,4})');
    final totalRegex = RegExp(r'(?:total|grand\s+total|amt\s+due)[:\s$]+(\d+[.,]\d{2})', caseSensitive: false);

    for (final line in lines) {
      if (detectedDate == null) {
        final dateMatch = dateRegex.firstMatch(line);
        if (dateMatch != null) detectedDate = dateMatch.group(1);
      }
      if (detectedTotal == null) {
        final totalMatch = totalRegex.firstMatch(line);
        if (totalMatch != null) {
          final matchedStr = totalMatch.group(1)!.replaceAll(',', '.');
          detectedTotal = double.tryParse(matchedStr);
        }
      }
    }

    return ReceiptData(
      total: detectedTotal,
      purchaseDate: detectedDate,
      merchantName: lines.isNotEmpty ? lines.first.trim() : null,
      items: const [],
    );
  }
}

class ReceiptProcessingManager {
  ReceiptProcessingState _state = ReceiptProcessingState.idle;
  String? _errorMessage;
  String? _warningMessage;
  bool _isProcessingLock = false;
  String? _currentScanId;

  // Configuration parameters
  final Duration ocrTimeout = const Duration(seconds: 15);
  final Duration geminiTimeout = const Duration(seconds: 30);
  
  // Callbacks hooked to your Flutter State management notifier
  void Function(ReceiptProcessingState state)? onStateChanged;
  void Function(String? error, String? warning)? onMessagesChanged;
  void Function(ReceiptData data)? onScanSuccess;

  ReceiptProcessingState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get warningMessage => _warningMessage;

  void _updateState(ReceiptProcessingState newState) {
    _state = newState;
    onStateChanged?.call(_state);
  }

  void _updateMessages({String? error, String? warning}) {
    _errorMessage = error;
    _warningMessage = warning;
    onMessagesChanged?.call(_errorMessage, _warningMessage);
  }

  Future<void> processReceipt({
    required String? imageUri,
    required Future<String> Function(String) ocrEngine,
    required bool Function() isMountedCheck,
  }) async {
    // 1. Strict concurrency block check
    if (_isProcessingLock) return;

    final scanId = Random().nextInt(1000000).toString();
    _currentScanId = scanId;
    _isProcessingLock = true;

    _updateState(ReceiptProcessingState.preparingImage);
    _updateMessages(error: null, warning: null);

    ReceiptData localFallback = ReceiptData();

    try {
      // 2. Preprocessing verification stage
      if (imageUri == null || imageUri.isEmpty) {
        throw ReceiptProcessingError(code: 'MISSING_URI', message: 'Target image locator reference is invalid');
      }

      if (!isMountedCheck()) return;

      // 3. Document text extraction stage
      _updateState(ReceiptProcessingState.readingText);
      final String ocrText = await ocrEngine(imageUri).timeout(
        ocrTimeout,
        onTimeout: () => throw ReceiptProcessingError(
          code: 'MLKIT_TIMEOUT', 
          message: 'Local machine character scanning exceeded performance threshold',
          isTransient: true,
        ),
      );

      if (_currentScanId != scanId || !isMountedCheck()) return;

      if (!LocalReceiptParser.isUsableReceiptText(ocrText)) {
        throw ReceiptProcessingError(
          code: 'INSUFFICIENT_OCR_TEXT', 
          message: 'Insufficient transaction validation parameters found within raw document data',
        );
      }

      localFallback = LocalReceiptParser.parseReceiptLocally(ocrText);

      // 4. Cloud Enrichment Layer
      _updateState(ReceiptProcessingState.analysingReceipt);
      ReceiptData? enhancedResult;

      try {
        final response = await http.post(
          Uri.parse('https://your-backend.api/api/receipts/extract'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'scanId': scanId,
            'ocrText': ocrText,
            'currencyHint': 'INR',
          }),
        ).timeout(geminiTimeout);

        if (response.statusCode == 200) {
          final decodedBody = jsonDecode(response.body) as Map<String, dynamic>;
          if (decodedBody['receipt'] != null) {
            enhancedResult = ReceiptData.fromJson(decodedBody['receipt'] as Map<String, dynamic>);
          }
        } else {
          throw Exception('Http Server Error Status: ${response.statusCode}');
        }
      } catch (geminiException) {
        // Safe contextual recovery fallthrough handling
        if (isMountedCheck() && _currentScanId == scanId) {
          _updateMessages(warning: 'Advanced structural inference was unavailable. Populating standard data matrices.');
        }
      }

      if (_currentScanId != scanId || !isMountedCheck()) return;

      // 5. Context Merging & Finalization State
      _updateState(ReceiptProcessingState.validating);
      
      final finalData = localFallback.copyWith(
        merchantName: enhancedResult?.merchantName ?? localFallback.merchantName,
        purchaseDate: enhancedResult?.purchaseDate ?? localFallback.purchaseDate,
        total: enhancedResult?.total ?? localFallback.total,
        tax: enhancedResult?.tax ?? localFallback.tax,
        items: enhancedResult?.items != null && enhancedResult!.items.isNotEmpty 
            ? enhancedResult.items 
            : localFallback.items,
      );

      _updateState(ReceiptProcessingState.completed);
      onScanSuccess?.call(finalData);

    } on ReceiptProcessingError catch (customError) {
      if (_currentScanId == scanId && isMountedCheck()) {
        _updateState(ReceiptProcessingState.failed);
        _updateMessages(error: customError.message);
      }
    } catch (genericException) {
      if (_currentScanId == scanId && isMountedCheck()) {
        _updateState(ReceiptProcessingState.failed);
        _updateMessages(error: 'System core execution faulted during asset conversion pipelines');
      }
    } finally {
      // 6. Mandatory processing safety release ring
      if (_currentScanId == scanId) {
        _isProcessingLock = false;
      }
    }
  }

  void cancelProcessing() {
    _currentScanId = null;
    _isProcessingLock = false;
    _updateState(ReceiptProcessingState.cancelled);
  }
}
