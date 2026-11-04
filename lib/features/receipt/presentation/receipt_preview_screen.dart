import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'receipt_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/line_item_model.dart';
import '../domain/receipt_model.dart';
import '../../../core/services/merchant_extractor.dart';
import '../../../theme/app_colors.dart';
import '../../../core/constants/spacing.dart';

class ReceiptPreviewScreen extends ConsumerStatefulWidget {
  final String? imagePath;
  final String? ocrText;
  final List<String>? imagePaths;
  final String? initialPaymentMethod;
  final Map<String, dynamic>? parsedData;
  final ReceiptModel? existingReceipt;

  const ReceiptPreviewScreen({
    super.key,
    this.imagePath,
    this.ocrText,
    this.imagePaths,
    this.initialPaymentMethod,
    this.parsedData,
    this.existingReceipt,
  });

  @override
  ConsumerState<ReceiptPreviewScreen> createState() => _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends ConsumerState<ReceiptPreviewScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _merchantController;
  late final TextEditingController _amountController;
  late final TextEditingController _dateController;
  late final TextEditingController _taxController;
  late final TextEditingController _invoiceController;

  List<String> _candidates = [];
  String? _merchantKey;
  
  DateTime _purchaseDate = DateTime.now();
  String _selectedCategory = 'Other';
  String _paymentMethod = 'UPI';
  bool _hasWarranty = false;
  int _warrantyMonths = 12;
  bool _hasAppliedParsedData = false;

  // ── Items Section State ──────────────────────────────────────────────────
  final List<LineItemModel> _lineItems = [];
  bool _itemsExpanded = false;

  final List<String> _categories = ['Food', 'Electronics', 'Fashion', 'Grocery', 'Travel', 'Health', 'Other'];
  final List<String> _paymentMethods = ['UPI', 'Credit Card', 'Cash', 'Debit Card'];

  String? get _effectiveImagePath => widget.imagePath ?? (widget.imagePaths != null && widget.imagePaths!.isNotEmpty ? widget.imagePaths!.first : null);
  List<String> get _allImagePaths => widget.imagePaths != null && widget.imagePaths!.isNotEmpty ? widget.imagePaths! : (widget.imagePath != null ? [widget.imagePath!] : []);

  @override
  void initState() {
    super.initState();

    if (widget.initialPaymentMethod != null && _paymentMethods.contains(widget.initialPaymentMethod!)) {
      _paymentMethod = widget.initialPaymentMethod!;
    }

    if (widget.existingReceipt != null) {
      final r = widget.existingReceipt!;
      _merchantController = TextEditingController(text: r.merchant);
      _amountController = TextEditingController(text: r.totalAmount.toStringAsFixed(2));
      _purchaseDate = r.purchaseDate;
      _dateController = TextEditingController(text: DateFormat('d MMMM yyyy').format(_purchaseDate));
      _taxController = TextEditingController(text: r.tax.toStringAsFixed(2));
      _invoiceController = TextEditingController(text: r.invoiceNumber);
      _selectedCategory = r.category;
      _paymentMethod = r.paymentMethod;
      _hasWarranty = (r.warrantyMonths ?? 0) > 0;
      _warrantyMonths = r.warrantyMonths ?? 12;
      _hasAppliedParsedData = true;
    } else {
      _merchantController = TextEditingController();
      _amountController = TextEditingController();
      _dateController = TextEditingController(text: DateFormat('d MMMM yyyy').format(_purchaseDate));
      _taxController = TextEditingController(text: '0.00');
      _invoiceController = TextEditingController();
    }

    _merchantController.addListener(() {
      if (mounted) {
        final text = _merchantController.text.trim().toLowerCase();
        if ((text.contains('hotel') || text.contains('restaurant')) && _selectedCategory != 'Food') {
          setState(() {
            _selectedCategory = 'Food';
          });
        }
      }
    });

    if (widget.existingReceipt == null) {
      if (widget.parsedData != null) {
        _applyParsedData(widget.parsedData!);
      } else if (widget.ocrText != null && _effectiveImagePath != null) {
        _runParserSimulation();
      }
    }
  }

  void _applyParsedData(Map<String, dynamic> data) {
    setState(() {
      _hasAppliedParsedData = true;
      _candidates = List<String>.from(data['merchantCandidates'] ?? []);
      _merchantKey = data['merchantKey'] as String?;
      _selectedCategory = data['category'] ?? 'Other';
      
      String merchantVal = data['merchant'] ?? '';
      if (_selectedCategory.toLowerCase() == 'food' && (merchantVal.isEmpty || merchantVal.toLowerCase() == 'merchant' || merchantVal.toLowerCase() == 'standard' || merchantVal.toLowerCase() == 'unknown')) {
        merchantVal = 'Restaurant';
      }
      _merchantController.text = merchantVal;

      final double total = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
      _amountController.text = total > 0 ? total.toStringAsFixed(2) : '';

      final double taxVal = (data['tax'] as num?)?.toDouble() ?? 0.0;
      _taxController.text = taxVal.toStringAsFixed(2);

      _invoiceController.text = data['invoiceNumber'] ?? '';
      _paymentMethod = data['paymentMethod'] ?? _paymentMethod;

      final dateStr = data['purchaseDate'] as String?;
      if (dateStr != null) {
        _purchaseDate = DateTime.tryParse(dateStr) ?? DateTime.now();
        _dateController.text = DateFormat('d MMMM yyyy').format(_purchaseDate);
      }

      final wMonths = data['warrantyMonths'] as int?;
      if (wMonths != null && wMonths > 0) {
        _hasWarranty = true;
        _warrantyMonths = wMonths;
      }

      // ── Populate line items ────────────────────────────────────────────
      _lineItems.clear();
      // Prefer the richer line_items array from Gemini
      final geminiItems = data['line_items'] as List<dynamic>?;
      if (geminiItems != null && geminiItems.isNotEmpty) {
        for (final item in geminiItems) {
          final m = Map<String, dynamic>.from(item as Map);
          final li = LineItemModel.fromGeminiMap(m);
          if (li.name.isNotEmpty) _lineItems.add(li);
        }
      }
      // Fallback: use legacy products array if line_items absent/empty
      if (_lineItems.isEmpty) {
        final itemsList = data['products'] as List<dynamic>?;
        if (itemsList != null) {
          for (final item in itemsList) {
            final m = Map<String, dynamic>.from(item as Map);
            final li = LineItemModel.fromProductMap(m);
            // Skip generic 'Items Summary' placeholder rows
            if (li.name.isNotEmpty &&
                li.name.toLowerCase() != 'items summary' &&
                li.name.toLowerCase() != 'general purchase') {
              _lineItems.add(li);
            }
          }
        }
      }
    });
  }

  void _runParserSimulation() {
    if (_effectiveImagePath == null) return;
    final parsed = ref.read(receiptControllerProvider.notifier).processReceiptImage(
      File(_effectiveImagePath!),
      ref.read(firebaseAvailableProvider));

    parsed.then((data) {
      if (!mounted) return;
      _applyParsedData(data);
    }).catchError((err) {
      debugPrint('Parsing error in preview initialization: $err');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not auto-fill details. Please enter them manually.'),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 4)));
    });
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _taxController.dispose();
    _invoiceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now());
    if (picked != null && picked != _purchaseDate) {
      setState(() {
        _purchaseDate = picked;
        _dateController.text = DateFormat('d MMMM yyyy').format(_purchaseDate);
      });
    }
  }

  // ── Line Item Operations ─────────────────────────────────────────────────

  void _addLineItem() {
    setState(() {
      _lineItems.add(const LineItemModel(name: '', quantity: 1, rate: 0.0, amount: 0.0));
      _itemsExpanded = true; // always show new item
    });
    // Open edit dialog for the newly added (last) item
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openEditDialog(_lineItems.length - 1);
    });
  }

  void _removeLineItem(int index) {
    setState(() {
      _lineItems.removeAt(index);
    });
  }

  void _openEditDialog(int index) {
    final item = _lineItems[index];
    final nameCtrl = TextEditingController(text: item.name);
    final qtyCtrl = TextEditingController(text: item.quantity.toString());
    final rateCtrl = TextEditingController(text: item.rate > 0 ? item.rate.toStringAsFixed(2) : '');
    final amountCtrl = TextEditingController(text: item.amount > 0 ? item.amount.toStringAsFixed(2) : '');

    // Auto-recalculate amount when qty or rate change
    void recalc() {
      final qty = int.tryParse(qtyCtrl.text) ?? 1;
      final rate = double.tryParse(rateCtrl.text) ?? 0.0;
      if (qty > 0 && rate > 0) {
        amountCtrl.text = (qty * rate).toStringAsFixed(2);
      }
    }
    qtyCtrl.addListener(recalc);
    rateCtrl.addListener(recalc);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.surfaceDark : Colors.white;
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: spaceLg, right: spaceLg, top: spaceMd,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                    borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: spaceMd),
              Text('Edit Item', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: spaceMd),

              // Name
              Text('Item Name', style: labelStyle),
              const SizedBox(height: spaceSm),
              TextField(
                controller: nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'e.g. Cappuccino'),
              ),
              const SizedBox(height: spaceMd),

              // Qty + Rate row
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Qty', style: labelStyle),
                      const SizedBox(height: spaceSm),
                      TextField(
                        controller: qtyCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(hintText: '1'),
                      ),
                    ])),
                const SizedBox(width: spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rate (₹)', style: labelStyle),
                      const SizedBox(height: spaceSm),
                      TextField(
                        controller: rateCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(hintText: '0.00'),
                      ),
                    ])),
              ]),
              const SizedBox(height: spaceMd),

              // Amount
              Text('Amount (₹)', style: labelStyle),
              const SizedBox(height: spaceSm),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: '0.00',
                  helperText: 'Auto-calculated from Qty × Rate — or override manually'),
              ),
              const SizedBox(height: spaceLg),

              // Action buttons
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Cancel'))),
                const SizedBox(width: spaceMd),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final updated = LineItemModel(
                        name: nameCtrl.text.trim(),
                        quantity: int.tryParse(qtyCtrl.text) ?? 1,
                        rate: double.tryParse(rateCtrl.text) ?? 0.0,
                        amount: double.tryParse(amountCtrl.text) ?? 0.0,
                      );
                      setState(() => _lineItems[index] = updated);
                      Navigator.of(ctx).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Save'))),
              ]),
            ]));
      },
    ).then((_) {
      nameCtrl.dispose();
      qtyCtrl.dispose();
      rateCtrl.dispose();
      amountCtrl.dispose();
    });
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      final total = double.parse(_amountController.text.trim());
      final tax = double.parse(_taxController.text.trim());
      final subtotal = total - tax;
      final isFirebase = ref.read(firebaseAvailableProvider);

      // Convert LineItemModel list → legacy products map format
      final productsForSave = _lineItems.isNotEmpty
          ? _lineItems.map((li) => li.toProductMap()).toList()
          : [{'name': 'General Purchase', 'quantity': 1, 'price': subtotal}];

      try {
        if (widget.existingReceipt != null) {
          final updated = widget.existingReceipt!.copyWith(
            merchant: _merchantController.text.trim(),
            category: _selectedCategory,
            purchaseDate: _purchaseDate,
            currency: '₹',
            subtotal: subtotal,
            tax: tax,
            totalAmount: total,
            paymentMethod: _paymentMethod,
            invoiceNumber: _invoiceController.text.trim().isNotEmpty
                ? _invoiceController.text.trim()
                : widget.existingReceipt!.invoiceNumber,
            warrantyMonths: _hasWarranty ? _warrantyMonths : null,
            updatedAt: DateTime.now(),
          );
          await ref.read(receiptControllerProvider.notifier).updateReceipt(updated);
        } else {
          await ref.read(receiptControllerProvider.notifier).saveReceipt(
            merchant: _merchantController.text.trim(),
            category: _selectedCategory,
            purchaseDate: _purchaseDate,
            currency: '₹',
            subtotal: subtotal,
            tax: tax,
            totalAmount: total,
            paymentMethod: _paymentMethod,
            invoiceNumber: _invoiceController.text.trim().isNotEmpty
                ? _invoiceController.text.trim()
                : 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
            products: productsForSave,
            ocrText: widget.ocrText ?? 'Manual entry',
            warrantyMonths: _hasWarranty ? _warrantyMonths : null,
            imageFile: _effectiveImagePath != null ? File(_effectiveImagePath!) : null,
            isFirebaseAvailable: isFirebase);
        }

        await MerchantMemory.remember(_merchantKey, _merchantController.text.trim());

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt saved successfully!'), backgroundColor: AppColors.success));
        context.go('/home');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save receipt: $e'), backgroundColor: AppColors.error));
        }
      }
    }
  }

  // ── Items Section Widget ─────────────────────────────────────────────────

  Widget _buildItemsSection(bool isDark) {
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final outline = isDark ? AppColors.outlineDark : AppColors.outlineLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSec = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final surfaceVariant = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;

    // How many items to show before truncating
    const collapseThreshold = 3;
    final totalCount = _lineItems.length;
    final displayCount = (_itemsExpanded || totalCount <= collapseThreshold)
        ? totalCount
        : collapseThreshold;
    final hiddenCount = totalCount - collapseThreshold;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outline, width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(spaceMd, spaceMd, spaceSm, 0),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: spaceSm),
                Text(
                  'Items',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textPrimary)),
                if (totalCount > 0) ...[
                  const SizedBox(width: spaceSm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      '$totalCount',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary))),
                ],
                const Spacer(),
                TextButton.icon(
                  onPressed: _addLineItem,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: spaceSm, vertical: spaceXs),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  icon: const Icon(Icons.add_rounded, size: 15),
                  label: Text(
                    'Add item',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary))),
              ])),

          // ── Divider ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceSm),
            child: Divider(height: 1, thickness: 1, color: outline)),

          // ── Empty state ──────────────────────────────────────────────────
          if (totalCount == 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(spaceMd, 0, spaceMd, spaceMd),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: spaceLg),
                    decoration: BoxDecoration(
                      color: surfaceVariant,
                      borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 28, color: textSec.withValues(alpha: 0.5)),
                        const SizedBox(height: spaceSm),
                        Text(
                          'No items detected',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600, color: textSec)),
                        const SizedBox(height: 4),
                        Text(
                          'Tap "+ Add item" above to add manually',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: textSec)),
                      ])),
                  const SizedBox(height: spaceSm),
                  // Prominent CTA when truly empty
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _addLineItem,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12)),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add Item',
                          style: TextStyle(fontWeight: FontWeight.w700)))),
                ]))

          // ── Item rows ────────────────────────────────────────────────────
          else ...[
            // Column header row
            Padding(
              padding: const EdgeInsets.fromLTRB(spaceMd, 0, spaceMd, spaceSm),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text('Item',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: textSec))),
                  Expanded(
                    flex: 3,
                    child: Text('Qty × Rate',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: textSec))),
                  Expanded(
                    flex: 2,
                    child: Text('Amount',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: textSec))),
                  const SizedBox(width: 28), // placeholder for delete icon
                ])),

            // Item rows (up to displayCount)
            ...List.generate(displayCount, (idx) {
              final item = _lineItems[idx];
              final amountStr = item.amount > 0
                  ? '₹${item.amount.toStringAsFixed(2)}'
                  : '—';
              final qtyRateStr = '${item.quantity} × ₹${item.rate.toStringAsFixed(2)}';

              return InkWell(
                onTap: () => _openEditDialog(idx),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(spaceMd, 6, spaceSm, 6),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text(
                          item.name.isNotEmpty ? item.name : 'Unnamed item',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: item.name.isNotEmpty ? textPrimary : textSec,
                                fontStyle: item.name.isEmpty ? FontStyle.italic : null),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis)),
                      Expanded(
                        flex: 3,
                        child: Text(
                          qtyRateStr,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: textSec))),
                      Expanded(
                        flex: 2,
                        child: Text(
                          amountStr,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: textPrimary))),
                      // Delete button
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 16,
                          icon: const Icon(Icons.close_rounded, color: AppColors.error),
                          onPressed: () => _removeLineItem(idx))),
                    ])),
              );
            }),

            // ── "Show more" pill ─────────────────────────────────────────
            if (!_itemsExpanded && hiddenCount > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(spaceMd, 0, spaceMd, spaceMd),
                child: GestureDetector(
                  onTap: () => setState(() => _itemsExpanded = true),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: surfaceVariant,
                      borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '+$hiddenCount more',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 14, color: AppColors.primary),
                      ]))))
            else
              const SizedBox(height: spaceSm),
          ],
        ]));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(receiptControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;

    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop())),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Receipt image(s) ─────────────────────────────────────
                  if (_allImagePaths.isNotEmpty) ...[
                    if (_allImagePaths.length == 1)
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: FileImage(File(_allImagePaths.first)),
                            fit: BoxFit.cover)))
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_allImagePaths.length} Pages Captured (Long Bill)',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                              const Icon(Icons.collections_bookmark_rounded, color: AppColors.primary, size: 16),
                            ]),
                          const SizedBox(height: spaceSm),
                          SizedBox(
                            height: 180,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _allImagePaths.length,
                              separatorBuilder: (_, __) => const SizedBox(width: spaceSm),
                              itemBuilder: (context, idx) {
                                return Stack(
                                  children: [
                                    Container(
                                      width: 130,
                                      height: 180,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: AppColors.outlineLight),
                                        image: DecorationImage(
                                          image: FileImage(File(_allImagePaths[idx])),
                                          fit: BoxFit.cover))),
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(6)),
                                        child: Text('P${idx + 1}', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)))),
                                  ]);
                              })),
                        ]),
                    const SizedBox(height: spaceMd),
                  ],

                  // ── AI-parsed banner ─────────────────────────────────────
                  if (_hasAppliedParsedData) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceSm),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                          const SizedBox(width: spaceSm),
                          Expanded(
                            child: Text(
                              'Parsed with Gemini AI — please verify values.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))),
                        ])),
                    const SizedBox(height: spaceMd),
                  ],

                  // ── Items section (ALWAYS shown, position fixed) ──────────
                  _buildItemsSection(isDark),
                  const SizedBox(height: spaceMd),

                  // ── Merchant Name ─────────────────────────────────────────
                  Text('Merchant Name', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  const SizedBox(height: spaceSm),
                  TextFormField(
                    controller: _merchantController,
                    decoration: const InputDecoration(hintText: 'e.g. Apple Store'),
                    validator: (val) => val == null || val.isEmpty ? 'Merchant name is required' : null),
                  if (_candidates.isNotEmpty) ...[
                    const SizedBox(height: spaceSm),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final c in _candidates)
                          ActionChip(
                            label: Text(c),
                            onPressed: () => setState(() => _merchantController.text = c),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: spaceMd),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Amount (₹)', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                            const SizedBox(height: spaceSm),
                            TextFormField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(hintText: '0.00'),
                              validator: (val) {
                                if (val == null || val.isEmpty || double.tryParse(val) == null) {
                                  return 'Invalid amount';
                                }
                                return null;
                              }),
                          ])),
                      const SizedBox(width: spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tax Included (₹)', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                            const SizedBox(height: spaceSm),
                            TextFormField(
                              controller: _taxController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(hintText: '0.00')),
                          ])),
                    ]),
                  const SizedBox(height: spaceMd),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Purchase Date', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                            const SizedBox(height: spaceSm),
                            TextFormField(
                              controller: _dateController,
                              readOnly: true,
                              onTap: _selectDate,
                              decoration: const InputDecoration(
                                suffixIcon: Icon(Icons.calendar_today_outlined, size: 18))),
                          ])),
                      const SizedBox(width: spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Invoice Number', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                            const SizedBox(height: spaceSm),
                            TextFormField(
                              controller: _invoiceController,
                              decoration: const InputDecoration(hintText: 'INV-XXXX')),
                          ])),
                    ]),
                  const SizedBox(height: spaceLg),

                  Text('Category', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  const SizedBox(height: spaceSm),
                  Wrap(
                    spacing: spaceSm,
                    runSpacing: spaceSm,
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat;
                            if (cat == 'Food') {
                              final text = _merchantController.text.trim();
                              if (text.isEmpty || text.toLowerCase() == 'merchant' || text.toLowerCase() == 'standard' || text.toLowerCase() == 'unknown') {
                                _merchantController.text = 'Restaurant';
                              }
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceSm),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight),
                            borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            cat,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isSelected ? Colors.white : textColor,
                              fontWeight: FontWeight.bold))));
                    }).toList()),
                  const SizedBox(height: spaceLg),

                  Text('Payment Method', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  const SizedBox(height: spaceSm),
                  Wrap(
                    spacing: spaceSm,
                    runSpacing: spaceSm,
                    children: _paymentMethods.map((pm) {
                      final isSelected = _paymentMethod == pm;
                      return ChoiceChip(
                        label: Text(pm),
                        selected: isSelected,
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        onSelected: (_) => setState(() => _paymentMethod = pm));
                    }).toList()),
                  const SizedBox(height: spaceLg),

                  Container(
                    padding: const EdgeInsets.all(spaceMd),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                        width: 1)),
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Includes Warranty', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                          subtitle: Text('Track warranty remaining duration', style: Theme.of(context).textTheme.bodySmall),
                          value: _hasWarranty,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) => setState(() => _hasWarranty = val)),
                        if (_hasWarranty) ...[
                          const SizedBox(height: spaceSm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Warranty Duration:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                              DropdownButton<int>(
                                value: _warrantyMonths,
                                underline: const SizedBox(),
                                items: const [
                                  DropdownMenuItem(value: 6, child: Text('6 Months')),
                                  DropdownMenuItem(value: 12, child: Text('1 Year (12m)')),
                                  DropdownMenuItem(value: 24, child: Text('2 Years (24m)')),
                                  DropdownMenuItem(value: 36, child: Text('3 Years (36m)')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _warrantyMonths = val);
                                }),
                            ]),
                        ]
                      ])),
                  const SizedBox(height: spaceLg),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                      onPressed: authState.isLoading ? null : _save,
                      child: Text('Save Receipt', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)))),
                  const SizedBox(height: spaceLg),
                ]))),

          if (authState.isLoading)
            Container(
              color: Colors.black54,
              width: double.infinity,
              height: double.infinity,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary))),
        ]));
  }
}
