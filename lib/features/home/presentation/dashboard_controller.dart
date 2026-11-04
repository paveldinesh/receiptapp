import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../../receipt/data/receipt_repository.dart';
import '../../receipt/domain/receipt_model.dart';
import '../../../widgets/receipt_ui.dart';
import '../../../core/constants/app_constants.dart';

final dashboardReceiptsProvider = StreamProvider<List<ReceiptModel>>((ref) {
  final userState = ref.watch(authStateChangesProvider).value;
  final userId = userState?.uid ?? AppConstants.mockUserId;
  final repository = ref.watch(receiptRepositoryProvider);
  
  return repository.streamReceipts(userId);
});

class DashboardStats {
  final double totalSpendMonth;
  final double totalSpendAllTime;
  final int totalCount;
  final int activeWarranties;
  final List<ReceiptModel> recentReceipts;
  final List<ReceiptModel> expiringWarranties;
  final Map<String, double> categoryDistribution;

  DashboardStats({
    required this.totalSpendMonth,
    required this.totalSpendAllTime,
    required this.totalCount,
    required this.activeWarranties,
    required this.recentReceipts,
    required this.expiringWarranties,
    required this.categoryDistribution,
  });
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final receipts = ref.watch(dashboardReceiptsProvider).value ?? [];
  final now = DateTime.now();
  final currentMonth = now.month;
  final currentYear = now.year;

  double totalSpend = 0.0;
  double totalAllTime = 0.0;
  int activeWarranties = 0;
  List<ReceiptModel> expiringWarranties = [];
  Map<String, double> categoryMap = {};

  for (final r in receipts) {
    totalAllTime += r.totalAmount;
    if (r.purchaseDate.month == currentMonth && r.purchaseDate.year == currentYear) {
      totalSpend += r.totalAmount;
      categoryMap[r.category] = (categoryMap[r.category] ?? 0.0) + r.totalAmount;
    }

    if (r.warrantyMonths != null && r.warrantyMonths! > 0) {
      final expiryDate = warrantyExpiry(r);
      if (expiryDate.isAfter(now)) {
        activeWarranties++;
        final diffDays = expiryDate.difference(now).inDays;
        if (diffDays <= 30) {
          expiringWarranties.add(r);
        }
      }
    }
  }

  final recent = receipts.take(5).toList();

  return DashboardStats(
    totalSpendMonth: totalSpend,
    totalSpendAllTime: totalAllTime,
    totalCount: receipts.length,
    activeWarranties: activeWarranties,
    recentReceipts: recent,
    expiringWarranties: expiringWarranties,
    categoryDistribution: categoryMap,
  );
});
