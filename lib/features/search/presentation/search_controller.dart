import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/presentation/dashboard_controller.dart';
import '../../receipt/domain/receipt_model.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final searchFilterProvider = StateProvider<String>((ref) => 'All');

final searchResultsProvider = Provider<List<ReceiptModel>>((ref) {
  final receipts = ref.watch(dashboardReceiptsProvider).value ?? [];
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final filter = ref.watch(searchFilterProvider);

  return receipts.where((r) {
    final matchesFilter = switch (filter) {
      'All' => true,
      'Warranty' => (r.warrantyMonths ?? 0) > 0,
      _ => r.category.toLowerCase() == filter.toLowerCase(),
    };
    if (!matchesFilter) return false;

    if (query.isEmpty) return true;

    final matchesMerchant = r.merchant.toLowerCase().contains(query);
    final matchesCategory = r.category.toLowerCase().contains(query);
    final matchesInvoice = r.invoiceNumber.toLowerCase().contains(query);
    final matchesProducts = r.products.any((p) => p.name.toLowerCase().contains(query));

    bool matchesAmount = false;
    final parsedQueryVal = double.tryParse(query);
    if (parsedQueryVal != null) {
      matchesAmount = (r.totalAmount - parsedQueryVal).abs() < 10.0;
    }

    return matchesMerchant || matchesCategory || matchesInvoice || matchesProducts || matchesAmount;
  }).toList();
});
