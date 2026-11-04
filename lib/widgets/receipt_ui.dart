import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/colors.dart';
import '../features/receipt/domain/receipt_model.dart';

(Color, Color, IconData) categoryStyle(String c) => switch (c) {
  'Electronics' => (AppColors.catElectrBg, AppColors.catElectrFg, Icons.devices),
  'Food' => (AppColors.catFoodBg, AppColors.catFoodFg, Icons.restaurant),
  'Grocery' => (AppColors.catGroceryBg, AppColors.catGroceryFg, Icons.local_grocery_store),
  'Fashion' => (AppColors.catFashionBg, AppColors.catFashionFg, Icons.checkroom),
  'Travel' => (AppColors.catTravelBg, AppColors.catTravelFg, Icons.flight),
  'Health' => (AppColors.catHealthBg, AppColors.catHealthFg, Icons.favorite),
  _ => (AppColors.catOtherBg, AppColors.catOtherFg, Icons.receipt_long),
};

String receiptTitle(ReceiptModel r) {
  final store = r.merchant.split(' | ').last.trim();
  return store.isEmpty ? '${r.category} purchase' : store;
}

DateTime warrantyExpiry(ReceiptModel r) => DateTime(
    r.purchaseDate.year, r.purchaseDate.month + (r.warrantyMonths ?? 0), r.purchaseDate.day);

class AmountText extends StatelessWidget {
  final double amount;
  final TextStyle style;
  const AmountText(this.amount, {super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    final parts = NumberFormat('#,##,##0.00', 'en_IN').format(amount).split('.');
    final faded = style.copyWith(color: style.color?.withValues(alpha: 0.4));
    return Text.rich(TextSpan(style: style, children: [
      TextSpan(text: '₹', style: faded.copyWith(fontSize: (style.fontSize ?? 16) * 0.6)),
      TextSpan(text: parts[0]),
      TextSpan(text: '.${parts[1]}', style: faded),
    ]));
  }
}

class ReceiptThumb extends StatelessWidget {
  final ReceiptModel receipt;
  const ReceiptThumb(this.receipt, {super.key});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = categoryStyle(receipt.category);
    final fallback = Container(width: 48, height: 48, color: bg, child: Icon(icon, color: fg, size: 22));
    final url = receipt.imageUrl;
    Widget child = fallback;
    if (url != null) {
      child = url.startsWith('http')
          ? Image.network(url, width: 48, height: 48, fit: BoxFit.cover,
              alignment: Alignment.topCenter, cacheWidth: 144,
              errorBuilder: (_, __, ___) => fallback)
          : Image.file(File(url), width: 48, height: 48, fit: BoxFit.cover,
              alignment: Alignment.topCenter, cacheWidth: 144,
              errorBuilder: (_, __, ___) => fallback);
    }
    return ClipRRect(borderRadius: BorderRadius.circular(14), child: child);
  }
}

