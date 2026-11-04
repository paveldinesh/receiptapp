import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/product_model.dart';
import '../domain/receipt_model.dart';

abstract class ReceiptRepository {
  Stream<List<ReceiptModel>> streamReceipts(String userId);
  Future<void> addReceipt(ReceiptModel receipt);
  Future<void> updateReceipt(ReceiptModel receipt);
  Future<void> deleteReceipt(String receiptId);
  Future<void> seedInitialData(String userId);
}

class FirestoreReceiptRepository implements ReceiptRepository {
  final FirebaseFirestore? _firestore;
  final bool _isFirebaseAvailable;
  
  // Local cache/fallback
  final List<ReceiptModel> _localCache = [];
  final StreamController<List<ReceiptModel>> _localStreamController =
      StreamController<List<ReceiptModel>>.broadcast();

  FirestoreReceiptRepository(this._firestore, this._isFirebaseAvailable) {
    if (_isFirebaseAvailable && _firestore == null) {
      throw Exception("FirebaseFirestore is required when Firebase is available.");
    }
    if (!_isFirebaseAvailable) {
      _loadLocalCache();
    }
  }

  Future<void> _loadLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString('cached_receipts');
      if (dataStr != null) {
        final List<dynamic> decoded = jsonDecode(dataStr);
        _localCache.clear();
        _localCache.addAll(decoded.map((item) => ReceiptModel.fromJson(item)));
      } else if (kDebugMode) {
        // Seed initial mock list if empty in debug mode only
        _seedMockData();
      }
      _localStreamController.add(List.unmodifiable(_localCache));
    } catch (e) {
      debugPrint('Error loading receipt cache: $e');
    }
  }

  Future<void> _saveLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = jsonEncode(_localCache.map((r) => r.toJson()).toList());
      await prefs.setString('cached_receipts', dataStr);
      _localStreamController.add(List.unmodifiable(_localCache));
    } catch (e) {
      debugPrint('Error saving receipt cache: $e');
    }
  }

  void _seedMockData() {
    final now = DateTime.now();
    final sampleReceipts = [
      ReceiptModel(
        id: 'mock_1',
        merchant: 'Coffee Maker | Croma',
        category: 'Electronics',
        purchaseDate: DateTime(2026, 7, 12),
        currency: '₹',
        subtotal: 8193.33,
        tax: 409.67,
        totalAmount: 8603.00,
        paymentMethod: 'Credit Card',
        invoiceNumber: 'INV-738210',
        products: [const ProductModel(name: 'Coffee Maker', quantity: 1, price: 8603.00)],
        imageUrl: null,
        ocrText: 'CROMA STORE\nCOFFEE MAKER\nTOTAL ₹8,603\nDATE 12 JUL 2026',
        warrantyMonths: 12,
        createdAt: now,
        updatedAt: now,
        userId: 'sarah_kapur_mock_id',
      ),
      ReceiptModel(
        id: 'mock_2',
        merchant: 'Zepto',
        category: 'Grocery',
        purchaseDate: DateTime(2026, 7, 10),
        currency: '₹',
        subtotal: 3333.33,
        tax: 166.67,
        totalAmount: 3500.00,
        paymentMethod: 'UPI',
        invoiceNumber: 'ZPT-93821',
        products: [const ProductModel(name: 'Organic Grocery Items', quantity: 1, price: 3500.0)],
        createdAt: now,
        updatedAt: now,
        userId: 'sarah_kapur_mock_id',
      ),
      ReceiptModel(
        id: 'mock_3',
        merchant: 'BigBasket',
        category: 'Grocery',
        purchaseDate: DateTime(2026, 7, 13),
        currency: '₹',
        subtotal: 3221.33,
        tax: 161.07,
        totalAmount: 3382.40,
        paymentMethod: 'UPI',
        invoiceNumber: 'BB-9871A',
        products: [const ProductModel(name: 'Fruits & Veggies', quantity: 1, price: 3382.4)],
        createdAt: now,
        updatedAt: now,
        userId: 'sarah_kapur_mock_id',
      ),
      ReceiptModel(
        id: 'mock_4',
        merchant: 'Zomato',
        category: 'Food',
        purchaseDate: DateTime(2026, 7, 14),
        currency: '₹',
        subtotal: 2308.95,
        tax: 115.45,
        totalAmount: 2424.40,
        paymentMethod: 'UPI',
        invoiceNumber: 'ZMT-92731',
        products: [const ProductModel(name: 'Meal Delivery', quantity: 1, price: 2424.40)],
        createdAt: now,
        updatedAt: now,
        userId: 'sarah_kapur_mock_id',
      ),
      ReceiptModel(
        id: 'mock_5',
        merchant: 'Starbucks Coffee',
        category: 'Food',
        purchaseDate: DateTime(2026, 7, 15),
        currency: '₹',
        subtotal: 1904.76,
        tax: 95.24,
        totalAmount: 2000.00,
        paymentMethod: 'Credit Card',
        invoiceNumber: 'SBC-9817',
        products: [const ProductModel(name: 'Java Chip Frappuccino', quantity: 2, price: 1000.0)],
        createdAt: now,
        updatedAt: now,
        userId: 'sarah_kapur_mock_id',
      ),
      ReceiptModel(
        id: 'mock_6',
        merchant: 'Amazon Fashion',
        category: 'Fashion',
        purchaseDate: DateTime(2026, 7, 8),
        currency: '₹',
        subtotal: 2809.14,
        tax: 140.46,
        totalAmount: 2949.60,
        paymentMethod: 'Credit Card',
        invoiceNumber: 'AMZ-FASH-92',
        products: [const ProductModel(name: 'Designer Shirt', quantity: 1, price: 2949.6)],
        createdAt: now,
        updatedAt: now,
        userId: 'sarah_kapur_mock_id',
      ),
      ReceiptModel(
        id: 'mock_7',
        merchant: 'Uber',
        category: 'Other',
        purchaseDate: DateTime(2026, 7, 5),
        currency: '₹',
        subtotal: 1638.67,
        tax: 81.93,
        totalAmount: 1720.60,
        paymentMethod: 'UPI',
        invoiceNumber: 'UBR-9382',
        products: [const ProductModel(name: 'Ride fare', quantity: 1, price: 1720.6)],
        createdAt: now,
        updatedAt: now,
        userId: 'sarah_kapur_mock_id',
      ),
      
      // Expiring active warranties (14 days left from July 16, 2026 -> expiry July 30, 2026)
      ReceiptModel(
        id: 'mock_w1',
        merchant: 'iPhone 15 Pro | Reliance Digital',
        category: 'Electronics',
        purchaseDate: DateTime(2025, 7, 14),
        currency: '₹',
        subtotal: 136180.95,
        tax: 6809.05,
        totalAmount: 142990.00,
        paymentMethod: 'Credit Card',
        invoiceNumber: 'RD-9283-11',
        products: [const ProductModel(name: 'iPhone 15 Pro Max', quantity: 1, price: 142990.0)],
        warrantyMonths: 12,
        imageUrl: null,
        createdAt: now.subtract(const Duration(days: 365)),
        updatedAt: now.subtract(const Duration(days: 365)),
        userId: 'sarah_kapur_mock_id',
      ),
      ReceiptModel(
        id: 'mock_w2',
        merchant: 'AirPods Pro | Apple Store',
        category: 'Electronics',
        purchaseDate: DateTime(2025, 8, 10),
        currency: '₹',
        subtotal: 23714.28,
        tax: 1185.72,
        totalAmount: 24900.00,
        paymentMethod: 'Credit Card',
        invoiceNumber: 'APL-83921',
        products: [const ProductModel(name: 'AirPods Pro 2', quantity: 1, price: 24900.0)],
        warrantyMonths: 12,
        createdAt: now.subtract(const Duration(days: 340)),
        updatedAt: now.subtract(const Duration(days: 340)),
        userId: 'sarah_kapur_mock_id',
      ),
      ReceiptModel(
        id: 'mock_w3',
        merchant: 'MacBook Air | Apple Store',
        category: 'Electronics',
        purchaseDate: DateTime(2025, 12, 15),
        currency: '₹',
        subtotal: 95142.86,
        tax: 4757.14,
        totalAmount: 99900.00,
        paymentMethod: 'Credit Card',
        invoiceNumber: 'APL-92731',
        products: [const ProductModel(name: 'MacBook Air M2', quantity: 1, price: 99900.0)],
        warrantyMonths: 24, // 2 years warranty
        createdAt: now.subtract(const Duration(days: 200)),
        updatedAt: now.subtract(const Duration(days: 200)),
        userId: 'sarah_kapur_mock_id',
      ),
      ReceiptModel(
        id: 'mock_w4',
        merchant: 'Leather Jacket | Zara',
        category: 'Fashion',
        purchaseDate: DateTime(2026, 5, 5),
        currency: '₹',
        subtotal: 9522.86,
        tax: 476.14,
        totalAmount: 9999.00,
        paymentMethod: 'Credit Card',
        invoiceNumber: 'ZR-938210',
        products: [const ProductModel(name: 'Leather Jacket', quantity: 1, price: 9999.0)],
        warrantyMonths: 12,
        createdAt: now.subtract(const Duration(days: 70)),
        updatedAt: now.subtract(const Duration(days: 70)),
        userId: 'sarah_kapur_mock_id',
      ),
      ReceiptModel(
        id: 'mock_w5',
        merchant: 'Microwave | LG Store',
        category: 'Electronics',
        purchaseDate: DateTime(2026, 2, 20),
        currency: '₹',
        subtotal: 11904.76,
        tax: 595.24,
        totalAmount: 12500.00,
        paymentMethod: 'UPI',
        invoiceNumber: 'LG-839210',
        products: [const ProductModel(name: 'LG Smart Microwave', quantity: 1, price: 12500.0)],
        warrantyMonths: 24,
        createdAt: now.subtract(const Duration(days: 145)),
        updatedAt: now.subtract(const Duration(days: 145)),
        userId: 'sarah_kapur_mock_id',
      ),
      ReceiptModel(
        id: 'mock_w6',
        merchant: 'Office Chair | IKEA',
        category: 'Other',
        purchaseDate: DateTime(2026, 3, 10),
        currency: '₹',
        subtotal: 14285.71,
        tax: 714.29,
        totalAmount: 15000.00,
        paymentMethod: 'Credit Card',
        invoiceNumber: 'IK-928311',
        products: [const ProductModel(name: 'Ergonomic Office Chair', quantity: 1, price: 15000.0)],
        warrantyMonths: 36, // 3 years warranty
        createdAt: now.subtract(const Duration(days: 128)),
        updatedAt: now.subtract(const Duration(days: 128)),
        userId: 'sarah_kapur_mock_id',
      ),
    ];
    _localCache.addAll(sampleReceipts);
    _saveLocalCache();
  }

  @override
  Stream<List<ReceiptModel>> streamReceipts(String userId) {
    if (_isFirebaseAvailable) {
      return _firestore!
          .collection('receipts')
          .where('userId', isEqualTo: userId)
          .orderBy('purchaseDate', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return ReceiptModel.fromJson(data);
        }).toList();
      });
    } else {
      Future.microtask(() => _localStreamController.add(List.unmodifiable(_localCache)));
      return _localStreamController.stream.map((list) {
        return list.where((r) => r.userId == userId).toList()
          ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
      });
    }
  }

  @override
  Future<void> addReceipt(ReceiptModel receipt) async {
    if (_isFirebaseAvailable) {
      await _firestore!.collection('receipts').add(receipt.toJson());
    } else {
      _localCache.insert(0, receipt);
      await _saveLocalCache();
    }
  }

  @override
  Future<void> updateReceipt(ReceiptModel receipt) async {
    if (_isFirebaseAvailable) {
      await _firestore!.collection('receipts').doc(receipt.id).update(receipt.toJson());
    } else {
      final index = _localCache.indexWhere((r) => r.id == receipt.id);
      if (index != -1) {
        _localCache[index] = receipt;
        await _saveLocalCache();
      }
    }
  }

  @override
  Future<void> deleteReceipt(String receiptId) async {
    if (_isFirebaseAvailable) {
      await _firestore!.collection('receipts').doc(receiptId).delete();
    } else {
      _localCache.removeWhere((r) => r.id == receiptId);
      await _saveLocalCache();
    }
  }

  @override
  Future<void> seedInitialData(String userId) async {
    if (!kDebugMode) return;
    if (_isFirebaseAvailable) {
      final snapshot = await _firestore!
          .collection('receipts')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
          
      if (snapshot.docs.isEmpty) {
        // Seed mock data to Firestore
        final tempRepo = FirestoreReceiptRepository(_firestore, false);
        tempRepo._seedMockData();
        for (final r in tempRepo._localCache) {
          final mapped = r.copyWith(userId: userId);
          await _firestore.collection('receipts').add(mapped.toJson());
        }
      }
    }
  }
}

// Providers
final firestoreProvider = Provider<FirebaseFirestore?>((ref) {
  final isAvailable = ref.watch(firebaseAvailableProvider);
  if (isAvailable) {
    return FirebaseFirestore.instance;
  }
  return null;
});

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final isAvailable = ref.watch(firebaseAvailableProvider);
  return FirestoreReceiptRepository(firestore, isAvailable);
});
