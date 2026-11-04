import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/receipt_repository.dart';
import '../domain/receipt_model.dart';
import '../../home/presentation/dashboard_controller.dart';
import '../../../widgets/receipt_ui.dart';
import '../../../theme/app_colors.dart';
import '../../../core/constants/spacing.dart';


class ReceiptDetailsScreen extends ConsumerStatefulWidget {
  final String receiptId;

  const ReceiptDetailsScreen({super.key, required this.receiptId});

  @override
  ConsumerState<ReceiptDetailsScreen> createState() => _ReceiptDetailsScreenState();
}

class _ReceiptDetailsScreenState extends ConsumerState<ReceiptDetailsScreen> {
  bool _isFavorited = false;

  @override
  Widget build(BuildContext context) {
    final receiptId = widget.receiptId;
    final receipts = ref.watch(dashboardReceiptsProvider).value ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSec = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final outline = isDark ? AppColors.outlineDark : AppColors.outlineLight;

    final receiptOrNull = receipts.cast<ReceiptModel?>().firstWhere(
      (r) => r?.id == receiptId,
      orElse: () => null);

    if (receiptOrNull == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
            onPressed: () => context.pop()),
          title: Text('Receipt Details', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: textPrimary))),
        body: Center(child: Text('Receipt not found', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textSec))));
    }

    // After null guard, receipt is promoted to non-nullable ReceiptModel
    final receipt = receiptOrNull;
    final parts = receipt.merchant.split(' | ');
    final displayMerchant = parts.last;
    final displayItem = parts.length > 1 ? parts.first : null;

    final rupeeFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final now = DateTime.now();
    int daysRemaining = 0;
    bool isExpired = true;
    DateTime? expiryDate;

    if (receipt.warrantyMonths != null && receipt.warrantyMonths! > 0) {
      expiryDate = warrantyExpiry(receipt);
      daysRemaining = expiryDate.difference(now).inDays;
      isExpired = expiryDate.isBefore(now);
    }

    Future<void> onDelete() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Delete Receipt', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: textPrimary)),
          content: Text('Are you sure you want to permanently delete this receipt?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textSec)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textSec, fontWeight: FontWeight.w600))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Delete', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white))),
          ]));
      if (confirm == true && context.mounted) {
        await ref.read(receiptRepositoryProvider).deleteReceipt(receiptId);
        ref.invalidate(dashboardReceiptsProvider);
        if (context.mounted) context.pop();
      }
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => context.pop()),
        title: Text('Receipt Details',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: textPrimary)),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: textPrimary),
            onSelected: (val) {
              if (val == 'delete') onDelete();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ]),
      // ── Pinned bottom action row ──────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardBg,
          border: Border(top: BorderSide(color: outline)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.07), blurRadius: 16, offset: const Offset(0, -4)),
          ]),
        padding: EdgeInsets.only(
          left: spaceSm,
          right: spaceSm,
          top: spaceSm,
          bottom: MediaQuery.of(context).padding.bottom + spaceSm),
        child: Row(
          children: [
            // Share as PDF
            Expanded(
              child: _ActionButton(
                icon: Icons.picture_as_pdf_outlined,
                label: 'Share PDF',
                color: AppColors.primary,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PDF export coming soon'), duration: Duration(seconds: 2)));
                })),
            // Edit
            Expanded(
              child: _ActionButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                color: textPrimary,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/preview', extra: {
                    'receipt': receipt,
                    'imagePath': receipt.imageUrl,
                    'ocrText': receipt.ocrText,
                  });
                })),
            // Favorite
            Expanded(
              child: _ActionButton(
                icon: _isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                label: 'Favorite',
                color: _isFavorited ? AppColors.error : textPrimary,
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isFavorited = !_isFavorited);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isFavorited ? 'Added to favorites' : 'Removed from favorites'),
                      duration: const Duration(seconds: 1)));
                })),
          ])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(spaceLg, spaceSm, spaceLg, spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header card ─────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(spaceMd),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: outline)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store name + category chip
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayMerchant,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                                letterSpacing: -0.2)),
                            if (displayItem != null) ...[
                              const SizedBox(height: spaceXs),
                              Text(
                                displayItem,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textSec)),
                            ],
                          ])),
                      const SizedBox(width: spaceSm),
                      Builder(
                        builder: (context) {
                          final (catBg, catFg, _) = categoryStyle(receipt.category);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: catBg,
                              borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              receipt.category.toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: catFg,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5)));
                        },
                      ),
                    ]),
                  const SizedBox(height: spaceMd),

                  // ── Amount ─────────────────────────────────────────────────
                  Text(
                    rupeeFormat.format(receipt.totalAmount),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.primary,
                      letterSpacing: -0.5)),
                  const SizedBox(height: spaceMd),

                  // ── Meta row ───────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(spaceMd),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                      borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        Expanded(child: _MetaItem(label: 'Invoice', value: receipt.invoiceNumber, textPrimary: textPrimary, textSec: textSec)),
                        Container(width: 1, height: 32, color: outline),
                        Expanded(child: _MetaItem(label: 'Date', value: DateFormat('d MMM yyyy').format(receipt.purchaseDate), textPrimary: textPrimary, textSec: textSec)),
                        Container(width: 1, height: 32, color: outline),
                        Expanded(child: _MetaItem(label: 'Payment', value: receipt.paymentMethod, textPrimary: textPrimary, textSec: textSec)),
                      ])),
                ])),
            const SizedBox(height: spaceMd),

            // ── Items ────────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(spaceMd),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: outline)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Items', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: textPrimary)),
                  const SizedBox(height: spaceSm),
                  // Column headers
                  Row(
                    children: [
                      Expanded(child: Text('ITEM', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: textSec, letterSpacing: 0.5))),
                      Text('TOTAL', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: textSec, letterSpacing: 0.5)),
                    ]),
                  const SizedBox(height: spaceSm),
                  Divider(color: outline, thickness: 1, height: 1),
                  const SizedBox(height: spaceSm),

                  // Items
                  ...receipt.products.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: spaceSm),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: textPrimary)),
                              Text('Qty: ${item.quantity}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSec)),
                            ])),
                        Text(
                          rupeeFormat.format(item.price * item.quantity),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: textPrimary)),
                      ]))),

                  Divider(color: outline, thickness: 1, height: 1),
                  const SizedBox(height: spaceSm),

                  // Subtotal / Tax / Total
                  _InvoiceRow(label: 'Subtotal', value: rupeeFormat.format(receipt.subtotal), textPrimary: textPrimary, textSec: textSec),
                  const SizedBox(height: spaceSm),
                  _InvoiceRow(label: 'Tax', value: rupeeFormat.format(receipt.tax), textPrimary: textPrimary, textSec: textSec),
                  const SizedBox(height: spaceSm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: textPrimary)),
                      Text(
                        rupeeFormat.format(receipt.totalAmount),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ]),
                ])),
            const SizedBox(height: spaceMd),

            // ── Warranty card ────────────────────────────────────────────────
            if (receipt.warrantyMonths != null && receipt.warrantyMonths! > 0) ...[
              Container(
                padding: const EdgeInsets.all(spaceMd),
                decoration: BoxDecoration(
                  // High-contrast opaque fills — no more translucent blending into page bg
                  color: isExpired
                      ? (isDark ? const Color(0xFF3B1515) : const Color(0xFFFFEBEB))
                      : (isDark ? const Color(0xFF0E3024) : const Color(0xFFD6F0E8)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isExpired ? AppColors.error.withValues(alpha: 0.55) : AppColors.primary.withValues(alpha: 0.55),
                    width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: (isExpired ? AppColors.error : AppColors.primary).withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                  ]),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isExpired ? AppColors.error.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.18),
                        shape: BoxShape.circle),
                      child: Icon(
                        isExpired ? Icons.cancel_outlined : Icons.verified_user_rounded,
                        color: isExpired ? AppColors.error : AppColors.primary,
                        size: 24)),
                    const SizedBox(width: spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isExpired ? 'Warranty Expired' : 'Active Warranty',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isExpired ? AppColors.error : AppColors.primary)),
                          const SizedBox(height: spaceXs),
                          Text(
                            isExpired
                                ? 'Cover expired on ${DateFormat('d MMM yyyy').format(expiryDate!)}'
                                : 'Expires ${DateFormat('d MMM yyyy').format(expiryDate!)} • $daysRemaining days left',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isExpired
                                  ? AppColors.error
                                  : AppColors.primary,
                              fontWeight: FontWeight.w500)),
                        ])),
                  ])),
              const SizedBox(height: spaceMd),
            ],

            // ── Receipt image ────────────────────────────────────────────────
            if (receipt.imageUrl != null) ...[
              Container(
                padding: const EdgeInsets.all(spaceMd),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: outline)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Receipt Image', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: textPrimary)),
                    const SizedBox(height: spaceSm),
                    GestureDetector(
                      onTap: () {
                        final url = receipt.imageUrl!;
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.all(8),
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: InteractiveViewer(
                                    child: url.startsWith('http')
                                        ? Image.network(url)
                                        : Image.file(File(url)))),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                                      child: const Icon(Icons.close, color: Colors.white, size: 20)))),
                              ])));
                      },
                      child: Builder(
                        builder: (context) {
                          final imgUrl = receipt.imageUrl!;
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: imgUrl.startsWith('http')
                                ? Image.network(imgUrl, width: double.infinity, height: 300, fit: BoxFit.cover)
                                : Image.file(File(imgUrl), width: double.infinity, height: 300, fit: BoxFit.cover));
                        })),
                  ])),
            ],
          ])));
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _MetaItem extends StatelessWidget {
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSec;

  const _MetaItem({required this.label, required this.value, required this.textPrimary, required this.textSec});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: textSec, letterSpacing: 0.4)),
        const SizedBox(height: spaceXs),
        Text(value, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: textPrimary), textAlign: TextAlign.center),
      ]);
  }
}

class _InvoiceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSec;

  const _InvoiceRow({required this.label, required this.value, required this.textPrimary, required this.textSec});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textSec)),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: textPrimary)),
      ]);
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: spaceSm, horizontal: spaceXs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: spaceXs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, color: color),
              textAlign: TextAlign.center),
          ])));
  }
}
