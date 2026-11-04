import 'package:flutter_test/flutter_test.dart';
import 'package:receiptvault_flutter/core/services/ocr_service.dart';

void main() {
  group('LocalReceiptParser', () {
    test('isUsableReceiptText returns true for text containing total amount', () {
      const text = 'WALMART SUPERCENTER\nItem 1  \$12.99\nTotal: \$12.99';
      expect(LocalReceiptParser.isUsableReceiptText(text), isTrue);
    });

    test('isUsableReceiptText returns false for short or irrelevant text', () {
      const text = 'Hello world';
      expect(LocalReceiptParser.isUsableReceiptText(text), isFalse);
    });

    test('parseReceiptLocally parses merchant name, date, and total correctly', () {
      const rawText = '''BEST BUY #1420
Date: 12/25/2024
Headphones: \$89.99
Grand Total: 89.99
Thank you for shopping!''';

      final receiptData = LocalReceiptParser.parseReceiptLocally(rawText);

      expect(receiptData.merchantName, equals('BEST BUY #1420'));
      expect(receiptData.purchaseDate, equals('12/25/2024'));
      expect(receiptData.total, equals(89.99));
    });
  });

  group('ReceiptItem and ReceiptData serialization', () {
    test('ReceiptItem.fromJson handles valid map', () {
      final json = {'name': 'Wireless Mouse', 'quantity': 2, 'price': 24.99};
      final item = ReceiptItem.fromJson(json);

      expect(item.name, equals('Wireless Mouse'));
      expect(item.quantity, equals(2));
      expect(item.price, equals(24.99));
    });

    test('ReceiptData.fromJson and copyWith work correctly', () {
      final json = {
        'merchantName': 'Target',
        'purchaseDate': '01/15/2025',
        'total': 45.50,
        'tax': 3.50,
        'items': [
          {'name': 'Shampoo', 'quantity': 1, 'price': 8.99},
        ],
      };

      final data = ReceiptData.fromJson(json);
      expect(data.merchantName, equals('Target'));
      expect(data.total, equals(45.50));
      expect(data.items.length, equals(1));
      expect(data.items.first.name, equals('Shampoo'));

      final updated = data.copyWith(total: 50.00);
      expect(updated.total, equals(50.00));
      expect(updated.merchantName, equals('Target'));
    });
  });
}
