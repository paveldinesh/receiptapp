import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'analytics_controller.dart';
import '../../home/presentation/dashboard_controller.dart';
import '../../../widgets/receipt_ui.dart';
import '../../../theme/app_colors.dart';
import '../../../core/constants/spacing.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> with TickerProviderStateMixin {
  int? _selectedMonthIndex;
  int _selectedYear = DateTime.now().year;
  late AnimationController _graphAnimController;
  late AnimationController _waveAnimController;

  @override
  void initState() {
    super.initState();
    _graphAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _graphAnimController.forward();

    _waveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _waveAnimController.repeat();
  }

  @override
  void dispose() {
    _graphAnimController.dispose();
    _waveAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(analyticsDataProvider(_selectedYear));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSec = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final rupee = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    double maxBar = 1.0;
    for (final p in data.monthlyTrend) {
      if (p.amount > maxBar) maxBar = p.amount;
    }



    // Sparkline wave details
    final List<double> sparklinePoints = data.monthlyTrend.map((m) => m.amount).toList();

    // Top merchants calculation from Riverpod state
    final receipts = ref.watch(dashboardReceiptsProvider).value ?? [];
    final Map<String, int> merchantCounts = {};
    for (final r in receipts) {
      merchantCounts[r.merchant] = (merchantCounts[r.merchant] ?? 0) + 1;
    }
    final sortedMerchants = merchantCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topMerchants = sortedMerchants.take(5).toList();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(spaceLg, spaceMd, spaceLg, spaceXxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Section ───────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overview',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track your spending insights',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSec),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: spaceLg),

              // ── Side-by-side Sparkline Cards ──────────────────────────────
              AnimatedBuilder(
                animation: _waveAnimController,
                builder: (context, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          label: 'Yearly Spend',
                          value: rupee.format(data.totalSpendYear),
                          icon: Icons.account_balance_wallet_outlined,
                          iconColor: AppColors.electricBlue,
                          iconBg: AppColors.electricBlue.withValues(alpha: 0.1),
                          cardBg: cardBg,
                          textPrimary: textPrimary,
                          textSec: textSec,
                          isDark: isDark,
                          trendText: '↑ 12% vs last year',
                          trendColor: AppColors.electricBlue,
                          trendBgColor: AppColors.electricBlue.withValues(alpha: 0.1),
                          sparklineData: sparklinePoints,
                          sparklineLineColor: AppColors.electricBlue,
                          sparklineFillColor: AppColors.electricBlue.withValues(alpha: 0.05),
                          animationValue: _waveAnimController.value,
                        ),
                      ),
                      const SizedBox(width: spaceSm),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Monthly Avg',
                          value: rupee.format(data.averageMonthlySpend),
                          icon: Icons.trending_up_rounded,
                          iconColor: AppColors.neonCyan,
                          iconBg: AppColors.neonCyan.withValues(alpha: 0.1),
                          cardBg: cardBg,
                          textPrimary: textPrimary,
                          textSec: textSec,
                          isDark: isDark,
                          trendText: '↓ 8% vs last month',
                          trendColor: AppColors.neonCyan,
                          trendBgColor: AppColors.neonCyan.withValues(alpha: 0.1),
                          sparklineData: sparklinePoints,
                          sparklineLineColor: AppColors.neonCyan,
                          sparklineFillColor: AppColors.neonCyan.withValues(alpha: 0.05),
                          animationValue: _waveAnimController.value,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: spaceMd),

              // ── Monthly Spending card (Bar Chart) ──────────────────────────
              Container(
                padding: const EdgeInsets.all(spaceLg),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (isDark)
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      )
                    else
                      BoxShadow(
                        color: AppColors.obsidianBlack.withValues(alpha: 0.07),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Monthly Spending',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceVariantDark : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedYear--;
                                    _selectedMonthIndex = null;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Icon(Icons.chevron_left_rounded, size: 18, color: textPrimary),
                                ),
                              ),
                              Text(
                                '$_selectedYear',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              if (_selectedYear < DateTime.now().year)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedYear++;
                                      _selectedMonthIndex = null;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: Icon(Icons.chevron_right_rounded, size: 18, color: textPrimary),
                                  ),
                                )
                              else
                                const SizedBox(width: 30),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: spaceLg),
                    SizedBox(
                      height: 140,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(data.monthlyTrend.length, (i) {
                          final p = data.monthlyTrend[i];
                          final ratio = (p.amount / maxBar).clamp(0.04, 1.0);
                          
                          final isSelected = _selectedMonthIndex == i;
                          final hasSelection = _selectedMonthIndex != null;
                          
                          final double barOpacity = hasSelection ? (isSelected ? 1.0 : 0.4) : 1.0;
                          final Color barColor = isSelected
                              ? AppColors.neonCyan
                              : AppColors.electricBlue.withValues(alpha: 0.2);

                          return Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                setState(() {
                                  _selectedMonthIndex = isSelected ? null : i;
                                });
                              },
                              child: Opacity(
                                opacity: barOpacity,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: AnimatedBuilder(
                                            animation: _graphAnimController,
                                            builder: (context, child) {
                                              return Container(
                                                width: isSelected ? 16 : 12,
                                                height: 110 * ratio * _graphAnimController.value,
                                                decoration: BoxDecoration(
                                                  color: barColor,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: spaceSm),
                                      Text(
                                        p.label,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                          color: isSelected ? AppColors.neonCyan : textSec,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: spaceMd),

              // ── Selected Month Detail Panel (Slide+Fade Animated) ───────────
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                sizeCurve: Curves.fastOutSlowIn,
                firstCurve: Curves.easeIn,
                secondCurve: Curves.easeIn,
                firstChild: const SizedBox(width: double.infinity, height: 0),
                secondChild: _selectedMonthIndex == null
                    ? const SizedBox(width: double.infinity, height: 0)
                    : _AnimatedDetailPanel(
                        key: ValueKey<int>(_selectedMonthIndex!),
                        child: _buildDetailPanel(context, data, cardBg, textPrimary, textSec, isDark, rupee),
                      ),
                crossFadeState: _selectedMonthIndex == null
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
              ),

              // ── Category Breakdown Card ────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(spaceLg),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (isDark)
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      )
                    else
                      BoxShadow(
                        color: AppColors.obsidianBlack.withValues(alpha: 0.07),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Category Breakdown',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'View All',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.electricBlue,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.electricBlue, size: 14),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: spaceLg),
                    if (data.categoryDistribution.isEmpty)
                      Center(child: Text('No data yet', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textSec)))
                    else
                      ...(() {
                        final sorted = data.categoryDistribution.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value));
                        return sorted.map((entry) {
                          final pct = data.totalSpendYear > 0 ? entry.value / data.totalSpendYear : 0.0;
                          final (catBg, catFg, catIcon) = categoryStyle(entry.key);
                          final barColor = catFg;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: spaceMd),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(color: catBg, borderRadius: BorderRadius.circular(10)),
                                  child: Icon(catIcon, color: catFg, size: 16),
                                ),
                                const SizedBox(width: spaceSm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(2),
                                        child: SizedBox(
                                          width: 140,
                                          child: LinearProgressIndicator(
                                            value: pct,
                                            minHeight: 4,
                                            backgroundColor: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                                            valueColor: AlwaysStoppedAnimation<Color>(barColor),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          rupee.format(entry.value),
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${(pct * 100).round()}%',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: catFg,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.chevron_right_rounded, color: textSec, size: 16),
                              ],
                            ),
                          );
                        });
                      })(),
                  ],
                ),
              ),
              const SizedBox(height: spaceMd),

              // ── Top Merchants Card ─────────────────────────────────────────
              if (topMerchants.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(spaceLg),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      if (isDark)
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        )
                      else
                        BoxShadow(
                          color: AppColors.obsidianBlack.withValues(alpha: 0.07),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Top Merchants',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'View All',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.electricBlue,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(Icons.chevron_right_rounded, color: AppColors.electricBlue, size: 14),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: spaceLg),
                      Row(
                        children: [
                          ...topMerchants.map((m) {
                            final name = m.key;
                            final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.outlineLight),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                initial,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.obsidianBlack,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceVariantDark : AppColors.primaryLight,
                              shape: BoxShape.circle,
                              border: Border.all(color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'more',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: textSec,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildDetailPanel(
    BuildContext context,
    AnalyticsData data,
    Color cardBg,
    Color textPrimary,
    Color textSec,
    bool isDark,
    NumberFormat rupee,
  ) {
    if (_selectedMonthIndex == null) return const SizedBox.shrink();
    
    final receipts = ref.watch(dashboardReceiptsProvider).value ?? [];
    final selectedMonthNum = _selectedMonthIndex! + 1;
    final currentYear = DateTime.now().year;
    
    final receiptsForMonth = receipts.where((r) => r.purchaseDate.year == currentYear && r.purchaseDate.month == selectedMonthNum).toList();
    final double monthTotal = receiptsForMonth.fold(0.0, (sum, r) => sum + r.totalAmount);
    final int monthReceiptsCount = receiptsForMonth.length;
    
    final prevMonthNum = selectedMonthNum - 1;
    final prevYear = prevMonthNum < 1 ? currentYear - 1 : currentYear;
    final prevMonthVal = prevMonthNum < 1 ? 12 : prevMonthNum;
    final double prevMonthTotal = receipts
        .where((r) => r.purchaseDate.year == prevYear && r.purchaseDate.month == prevMonthVal)
        .fold(0.0, (sum, r) => sum + r.totalAmount);
        
    double pctChange = 0.0;
    if (prevMonthTotal > 0.0) {
      pctChange = ((monthTotal - prevMonthTotal) / prevMonthTotal) * 100;
    }
    
    final Map<String, double> catMap = {};
    for (final r in receiptsForMonth) {
      catMap[r.category] = (catMap[r.category] ?? 0.0) + r.totalAmount;
    }
    final sortedCats = catMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3Cats = sortedCats.take(3).toList();
    
    final monthLabels = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    final monthName = monthLabels[_selectedMonthIndex!];
    final prevMonthName = monthLabels[prevMonthVal - 1];

    final isPositiveTrend = pctChange < 0; 
    final trendColor = isPositiveTrend 
        ? (isDark ? const Color(0xFF30D158) : const Color(0xFF248A3D)) 
        : textSec; 
    final trendIcon = isPositiveTrend ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final trendText = isPositiveTrend
        ? "${pctChange.abs().toStringAsFixed(0)}% less vs $prevMonthName"
        : "${pctChange.abs().toStringAsFixed(0)}% more vs $prevMonthName";

    return Container(
      margin: const EdgeInsets.only(bottom: spaceMd),
      padding: const EdgeInsets.all(spaceLg),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$monthName Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedMonthIndex = null),
                child: Icon(Icons.close_rounded, color: textSec, size: 20),
              ),
            ],
          ),
          const SizedBox(height: spaceMd),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Spent', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSec)),
                    const SizedBox(height: 4),
                    _CountUpText(
                      value: monthTotal,
                      formatter: (val) => rupee.format(val),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
              ),
              const SizedBox(width: spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Receipts Logged', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSec)),
                    const SizedBox(height: 4),
                    _CountUpText(
                      value: monthReceiptsCount.toDouble(),
                      formatter: (val) => val.toInt().toString(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: spaceMd),
          if (prevMonthTotal > 0.0)
            Row(
              children: [
                Icon(trendIcon, color: trendColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  trendText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: trendColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          else
            Text(
              'No previous month data to compare',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSec),
            ),
          const SizedBox(height: spaceLg),
          Text(
            'Top Categories',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: spaceSm),
          if (top3Cats.isEmpty)
            Text('No transactions this month', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSec))
          else
            ...top3Cats.map((entry) {
              final (catBg, catFg, catIcon) = categoryStyle(entry.key);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(color: catBg, borderRadius: BorderRadius.circular(7)),
                      child: Icon(catIcon, color: catFg, size: 14),
                    ),
                    const SizedBox(width: spaceSm),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    _CountUpText(
                      value: entry.value,
                      formatter: (val) => rupee.format(val),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _AnimatedDetailPanel extends StatefulWidget {
  final Widget child;
  const _AnimatedDetailPanel({required this.child, super.key});
  @override
  State<_AnimatedDetailPanel> createState() => _AnimatedDetailPanelState();
}

class _AnimatedDetailPanelState extends State<_AnimatedDetailPanel> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut)
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0.0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic)
    );
    _fadeController.forward();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: widget.child,
      ),
    );
  }
}

class _CountUpText extends StatefulWidget {
  final double value;
  final TextStyle? style;
  final String Function(double) formatter;
  
  const _CountUpText({
    required this.value,
    this.style,
    required this.formatter,
  });
  
  @override
  State<_CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<_CountUpText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldValue = 0.0;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0.0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }
  
  @override
  void didUpdateWidget(_CountUpText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _animation = Tween<double>(begin: _oldValue, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          widget.formatter(_animation.value),
          style: widget.style,
        );
      },
    );
  }
}

// ── Custom Painters ──────────────────────────────────────────────────────────



class _SparklinePainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;
  final Color fillColor;
  final double animationValue;

  _SparklinePainter({
    required this.dataPoints,
    required this.lineColor,
    required this.fillColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final path = Path();
    final fillPath = Path();

    final widthStep = size.width / (dataPoints.length - 1);
    final minVal = dataPoints.reduce((a, b) => a < b ? a : b);
    final maxVal = dataPoints.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    double getY(int index, double val) {
      final normalized = (val - minVal) / range;
      final baseHeight = size.height - (normalized * (size.height * 0.4) + (size.height * 0.1));
      final waveOffset = 4.0 * math.sin(index * 0.6 + animationValue * 2 * math.pi);
      return baseHeight + waveOffset;
    }

    path.moveTo(0, getY(0, dataPoints[0]));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, getY(0, dataPoints[0]));

    for (int i = 1; i < dataPoints.length; i++) {
      final x = i * widthStep;
      final y = getY(i, dataPoints[i]);
      
      final prevX = (i - 1) * widthStep;
      final prevY = getY(i - 1, dataPoints[i - 1]);
      final controlX1 = prevX + widthStep / 2;
      final controlY1 = prevY;
      final controlX2 = prevX + widthStep / 2;
      final controlY2 = y;
      
      path.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);


  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => true;
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color cardBg;
  final Color textPrimary;
  final Color textSec;
  final bool isDark;
  final String trendText;
  final Color trendColor;
  final Color trendBgColor;
  final List<double> sparklineData;
  final Color sparklineLineColor;
  final Color sparklineFillColor;
  final double animationValue;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.cardBg,
    required this.textPrimary,
    required this.textSec,
    required this.isDark,
    required this.trendText,
    required this.trendColor,
    required this.trendBgColor,
    required this.sparklineData,
    required this.sparklineLineColor,
    required this.sparklineFillColor,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 155,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (isDark)
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: AppColors.obsidianBlack.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Stack(
        children: [
          // Sparkline waves along bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 50,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(19),
                bottomRight: Radius.circular(19),
              ),
              child: CustomPaint(
                painter: _SparklinePainter(
                  dataPoints: sparklineData,
                  lineColor: sparklineLineColor,
                  fillColor: sparklineFillColor,
                  animationValue: animationValue,
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                      child: Icon(icon, color: iconColor, size: 18)),
                    Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, color: textSec)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: textPrimary)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trendBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendText.startsWith('↑') ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        size: 10,
                        color: trendColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trendText.replaceAll('↑ ', '').replaceAll('↓ ', ''),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: trendColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
