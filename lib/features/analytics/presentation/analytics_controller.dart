import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/presentation/dashboard_controller.dart';

class AnalyticsData {
  final double totalSpendYear;
  final double averageMonthlySpend;
  final Map<String, double> categoryDistribution;
  final Map<String, double> merchantDistribution;
  final List<MonthlySpendPoint> monthlyTrend;

  AnalyticsData({
    required this.totalSpendYear,
    required this.averageMonthlySpend,
    required this.categoryDistribution,
    required this.merchantDistribution,
    required this.monthlyTrend,
  });
}

class MonthlySpendPoint {
  final String label;
  final double amount;
  MonthlySpendPoint(this.label, this.amount);
}

final analyticsDataProvider = Provider.family<AnalyticsData, int>((ref, selectedYear) {
  final receipts = ref.watch(dashboardReceiptsProvider).value ?? [];

  double totalSpend = 0.0;
  Map<String, double> categoryDistribution = {};
  Map<String, double> merchantDistribution = {};
  
  final Map<int, double> monthAmountMap = {
    1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0, 5: 0.0, 6: 0.0,
    7: 0.0, 8: 0.0, 9: 0.0, 10: 0.0, 11: 0.0, 12: 0.0
  };

  for (final r in receipts) {
    if (r.purchaseDate.year == selectedYear) {
      totalSpend += r.totalAmount;
      categoryDistribution[r.category] = (categoryDistribution[r.category] ?? 0.0) + r.totalAmount;
      merchantDistribution[r.merchant.split(' | ').last] = (merchantDistribution[r.merchant.split(' | ').last] ?? 0.0) + r.totalAmount;
      
      final month = r.purchaseDate.month;
      monthAmountMap[month] = (monthAmountMap[month] ?? 0.0) + r.totalAmount;
    }
  }

  final List<String> monthLabels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  final List<MonthlySpendPoint> trend = [];
  
  int monthsWithSpend = 0;
  monthAmountMap.forEach((month, amount) {
    trend.add(MonthlySpendPoint(monthLabels[month - 1], amount));
    if (amount > 0.0) {
      monthsWithSpend++;
    }
  });

  final averageMonthlySpend = monthsWithSpend > 0 ? totalSpend / monthsWithSpend : 0.0;

  return AnalyticsData(
    totalSpendYear: totalSpend,
    averageMonthlySpend: averageMonthlySpend,
    categoryDistribution: categoryDistribution,
    merchantDistribution: merchantDistribution,
    monthlyTrend: trend,
  );
});
