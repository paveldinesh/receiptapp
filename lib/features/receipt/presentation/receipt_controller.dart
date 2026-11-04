import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../data/receipt_repository.dart';
import '../domain/receipt_model.dart';
import '../domain/product_model.dart';
import '../../../core/services/ocr_service.dart';
import '../../../core/services/cloud_functions_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/merchant_extractor.dart';
import '../../../core/constants/app_constants.dart';

enum ReceiptScanStage {
  idle,
  readingText,      // "Reading receipt..." (while ML Kit runs)
  enhancingWithAi,  // "Enhancing with AI..." (if Gemini/cloud parser runs)
  organizingDetails // "Organizing details..." (during parsing/field mapping)
}

final receiptScanStageProvider = StateProvider<ReceiptScanStage>((ref) => ReceiptScanStage.idle);

class ReceiptProcessingException implements Exception {
  final String code;
  final String message;
  ReceiptProcessingException(this.code, this.message);
  @override
  String toString() => message;
}

class ReceiptController extends StateNotifier<AsyncValue<ReceiptModel?>> {
  final ReceiptRepository _receiptRepository;
  final AuthRepository _authRepository;
  final Ref _ref;

  bool _isProcessingLock = false;
  int _scanCounter = 0;

  static const _mlKitTimeout = Duration(seconds: 15);

  ReceiptController(this._receiptRepository, this._authRepository, this._ref)
      : super(const AsyncValue.data(null));

  Future<Map<String, dynamic>> processReceiptImage(File file, bool isFirebaseAvailable) async {
    if (_isProcessingLock) {
      throw ReceiptProcessingException(
        'ALREADY_PROCESSING',
        'A scan is already in progress. Please wait.',
      );
    }

    final myScanId = ++_scanCounter;
    _isProcessingLock = true;
    state = const AsyncValue.loading();

    try {
      _ref.read(receiptScanStageProvider.notifier).state = ReceiptScanStage.readingText;
      final recognizedText = await OcrService.recognizeReceiptText(file).timeout(
        _mlKitTimeout,
        onTimeout: () => throw ReceiptProcessingException(
          'MLKIT_TIMEOUT',
          'Text recognition took too long. Retake the photo with better lighting, or enter details manually.',
        ),
      );

      final rawText = recognizedText.text;

      if (rawText.trim().isEmpty) {
        throw ReceiptProcessingException(
          'EMPTY_OCR_TEXT',
          'We could not read any text from this image. Enter the details manually instead.',
        );
      }

      // Check if Gemini/AI processing will run (Firebase available)
      if (isFirebaseAvailable) {
        _ref.read(receiptScanStageProvider.notifier).state = ReceiptScanStage.enhancingWithAi;
      } else {
        _ref.read(receiptScanStageProvider.notifier).state = ReceiptScanStage.organizingDetails;
      }

      final parsedData = await CloudFunctionsService().parseReceiptText(
        rawText,
        isFirebaseAvailable: isFirebaseAvailable,
      );

      final guess = MerchantExtractor.extract(recognizedText);
      final remembered = await MerchantMemory.lookup(guess.key);
      final gemini = parsedData['source'] == 'gemini' ? parsedData['merchant'] as String? : null;
      parsedData['merchant'] = remembered ??
          (gemini?.trim().isNotEmpty == true ? gemini : guess.name) ?? '';
      parsedData['merchantCandidates'] = guess.candidates;
      parsedData['merchantKey'] = guess.key;

      // Transition to final details organization if we came from Gemini
      if (isFirebaseAvailable) {
        _ref.read(receiptScanStageProvider.notifier).state = ReceiptScanStage.organizingDetails;
      }

      parsedData['ocrText'] = rawText;

      if (myScanId == _scanCounter) {
        state = const AsyncValue.data(null);
        _ref.read(receiptScanStageProvider.notifier).state = ReceiptScanStage.idle;
      }
      return parsedData;
    } catch (e, st) {
      if (myScanId == _scanCounter) {
        state = AsyncValue.error(e, st);
        _ref.read(receiptScanStageProvider.notifier).state = ReceiptScanStage.idle;
      }
      rethrow;
    } finally {
      if (myScanId == _scanCounter) {
        _isProcessingLock = false;
      }
    }
  }

  Future<void> saveReceipt({
    required String merchant,
    required String category,
    required DateTime purchaseDate,
    required String currency,
    required double subtotal,
    required double tax,
    required double totalAmount,
    required String paymentMethod,
    required String invoiceNumber,
    required List<Map<String, dynamic>> products,
    required String ocrText,
    int? warrantyMonths,
    File? imageFile,
    bool isFirebaseAvailable = false,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _authRepository.currentUser;
      final userId = user?.uid ?? AppConstants.mockUserId;

      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await StorageService().uploadReceiptImage(
          imageFile,
          userId,
          isFirebaseAvailable: isFirebaseAvailable,
        );
      }

      final productModels = products.map((p) {
        return ProductModel.fromJson(p);
      }).toList();

      final now = DateTime.now();
      final newReceipt = ReceiptModel(
        id: now.millisecondsSinceEpoch.toString(),
        merchant: merchant,
        category: category,
        purchaseDate: purchaseDate,
        currency: currency,
        subtotal: subtotal,
        tax: tax,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        invoiceNumber: invoiceNumber,
        products: productModels,
        imageUrl: imageUrl,
        ocrText: ocrText,
        warrantyMonths: warrantyMonths,
        createdAt: now,
        updatedAt: now,
        userId: userId,
      );

      await _receiptRepository.addReceipt(newReceipt);
      state = AsyncValue.data(newReceipt);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateReceipt(ReceiptModel receipt) async {
    state = const AsyncValue.loading();
    try {
      await _receiptRepository.updateReceipt(receipt);
      state = AsyncValue.data(receipt);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteReceipt(String receiptId) async {
    state = const AsyncValue.loading();
    try {
      await _receiptRepository.deleteReceipt(receiptId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final receiptControllerProvider =
    StateNotifierProvider<ReceiptController, AsyncValue<ReceiptModel?>>((ref) {
  final receiptRepo = ref.watch(receiptRepositoryProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  return ReceiptController(receiptRepo, authRepo, ref);
});
