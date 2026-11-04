import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../home/presentation/dashboard_controller.dart';
import '../../../widgets/receipt_ui.dart';
import '../../../theme/app_colors.dart';
import '../../../core/constants/spacing.dart';

final warrantyFilterProvider = StateProvider<String>((ref) => 'All');

class WarrantyScreen extends ConsumerStatefulWidget {
  const WarrantyScreen({super.key});

  @override
  ConsumerState<WarrantyScreen> createState() => _WarrantyScreenState();
}

class _AnalyticsSparklinePainter extends CustomPainter {
  final List<double> dataPoints;
  final Color fillColor;
  final double animationValue;

  _AnalyticsSparklinePainter({
    required this.dataPoints,
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
      final waveOffset = 3.0 * math.sin(index * 0.8 + animationValue * 2 * math.pi);
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
  bool shouldRepaint(covariant _AnalyticsSparklinePainter oldDelegate) => true;
}

class _WarrantyScreenState extends ConsumerState<WarrantyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _waveAnimController;

  @override
  void initState() {
    super.initState();
    _waveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _waveAnimController.repeat();
  }

  @override
  void dispose() {
    _waveAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final receipts = ref.watch(dashboardReceiptsProvider).value ?? [];
    final filter = ref.watch(warrantyFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSec = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final now = DateTime.now();
    final warrantyItems = receipts.where((r) => r.warrantyMonths != null && r.warrantyMonths! > 0).toList();

    int activeCount = 0;
    int expiringCount = 0;
    int expiredCount = 0;
    final List<double> activePoints = [];
    final List<double> expiringPoints = [];
    final List<double> expiredPoints = [];

    for (int i = 0; i < warrantyItems.length; i++) {
      final r = warrantyItems[i];
      final exp = warrantyExpiry(r);
      if (exp.isBefore(now)) {
        expiredCount++;
        expiredPoints.add(r.totalAmount);
      } else {
        activeCount++;
        activePoints.add(r.totalAmount);
        final diff = exp.difference(now).inDays;
        if (diff <= 30) {
          expiringCount++;
          expiringPoints.add(r.totalAmount);
        }
      }
    }

    // Fallbacks if data points list is too small
    if (activePoints.length < 2) activePoints.addAll([100.0, 150.0, 80.0, 200.0]);
    if (expiringPoints.length < 2) expiringPoints.addAll([50.0, 60.0, 45.0, 80.0]);
    if (expiredPoints.length < 2) expiredPoints.addAll([120.0, 90.0, 110.0, 70.0]);

    final filtered = warrantyItems.where((r) {
      final exp = warrantyExpiry(r);
      final isExp = exp.isBefore(now);
      final diff = exp.difference(now).inDays;
      switch (filter) {
        case 'Active': return !isExp;
        case 'Expiring': return !isExp && diff <= 30;
        case 'Expired': return isExp;
        default: return true;
      }
    }).toList()
      ..sort((a, b) {
        final expA = warrantyExpiry(a);
        final expB = warrantyExpiry(b);
        final isExpA = expA.isBefore(now);
        final isExpB = expB.isBefore(now);
        if (isExpA != isExpB) return isExpA ? 1 : -1;
        return expA.compareTo(expB);
      });

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header Section ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(spaceLg, spaceMd, spaceLg, spaceSm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Warranty',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage all your product warranties and receipts',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSec),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.go('/search'),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceVariantDark : AppColors.softLightFill,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.search_rounded, color: textPrimary, size: 18),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceVariantDark : AppColors.softLightFill,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.tune_rounded, color: textPrimary, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Stats row (Three Summary Cards) ───────────────────────────
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _waveAnimController,
                builder: (context, child) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(spaceLg, spaceMd, spaceLg, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Active',
                            count: activeCount,
                            subtitle: 'Items covered',
                            icon: Icons.shield_rounded,
                            iconColor: AppColors.neonCyan,
                            iconBg: AppColors.neonCyan.withValues(alpha: 0.15),
                            cardBg: cardBg,
                            textPrimary: textPrimary,
                            textSec: textSec,
                            isDark: isDark,
                            waveColor: AppColors.neonCyan.withValues(alpha: 0.05),
                            wavePoints: activePoints,
                            animationValue: _waveAnimController.value,
                          ),
                        ),
                        const SizedBox(width: spaceSm),
                        Expanded(
                          child: _StatCard(
                            label: 'Expiring',
                            count: expiringCount,
                            subtitle: expiringCount > 0 ? '$expiringCount expiring soon' : 'No items expiring',
                            icon: Icons.access_time_filled_rounded,
                            iconColor: AppColors.warning,
                            iconBg: AppColors.warning.withValues(alpha: 0.15),
                            cardBg: cardBg,
                            textPrimary: textPrimary,
                            textSec: textSec,
                            isDark: isDark,
                            waveColor: AppColors.warning.withValues(alpha: 0.05),
                            wavePoints: expiringPoints,
                            animationValue: _waveAnimController.value,
                          ),
                        ),
                        const SizedBox(width: spaceSm),
                        Expanded(
                          child: _StatCard(
                            label: 'Expired',
                            count: expiredCount,
                            subtitle: 'Action required',
                            icon: Icons.warning_rounded,
                            iconColor: AppColors.error,
                            iconBg: AppColors.error.withValues(alpha: 0.15),
                            cardBg: cardBg,
                            textPrimary: textPrimary,
                            textSec: textSec,
                            isDark: isDark,
                            waveColor: AppColors.error.withValues(alpha: 0.05),
                            wavePoints: expiredPoints,
                            animationValue: _waveAnimController.value,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Filter pills ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(spaceLg, spaceLg, spaceLg, 0),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark : AppColors.softLightFill,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: ['All', 'Active', 'Expiring', 'Expired'].map((f) {
                      final sel = f == filter;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => ref.read(warrantyFilterProvider.notifier).state = f,
                          child: Container(
                            decoration: BoxDecoration(
                              color: sel
                                  ? (isDark ? Colors.white : AppColors.obsidianBlack)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              f,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: sel
                                    ? (isDark ? Colors.black : Colors.white)
                                    : textSec,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // ── List ──────────────────────────────────────────────────────
            if (filtered.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.only(top: 60),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Icon(Icons.shield_outlined, size: 52, color: textSec.withValues(alpha: 0.3)),
                      const SizedBox(height: spaceMd),
                      Text('No $filter warranties', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textSec)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(spaceLg, spaceMd, spaceLg, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final r = filtered[index];
                      final exp = warrantyExpiry(r);
                      final isExp = exp.isBefore(now);
                      final diff = exp.difference(now).inDays;
                      final parts = r.merchant.split(' | ');
                      final title = parts.first;
                      final store = parts.length > 1 ? parts.last : '';

                      Color badgeBg, badgeFg;
                      String badgeLabel;
                      if (isExp) {
                        badgeBg = AppColors.errorLight;
                        badgeFg = AppColors.error;
                        badgeLabel = 'EXPIRED';
                      } else {
                        badgeBg = AppColors.neonCyan.withValues(alpha: 0.12);
                        badgeFg = isDark ? AppColors.neonCyan : AppColors.obsidianBlack;
                        badgeLabel = '${diff}D LEFT';
                      }

                      final (catBg, catFg, catIcon) = categoryStyle(r.category);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: spaceSm),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
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
                          child: InkWell(
                            onTap: () => context.push('/receipt/${r.id}'),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: spaceMd, vertical: 12),
                              child: Row(
                                children: [
                                  // Category square icon badge (rounded)
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: catBg,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(catIcon, color: catFg, size: 20),
                                  ),
                                  const SizedBox(width: spaceMd),
                                  // Title + subtitle
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title.length > 14 ? '${title.substring(0, 14)}...' : title,
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${store.isNotEmpty ? '$store • ' : ''}Expires ${DateFormat('d MMM yyyy').format(exp)}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSec),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: spaceSm),
                                  // Countdown badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(8)),
                                    child: Text(
                                      badgeLabel,
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: badgeFg,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  // ⋮ Quick actions
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert_rounded, color: textSec, size: 20),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    color: cardBg,
                                    elevation: 6,
                                    padding: EdgeInsets.zero,
                                    onSelected: (value) {
                                      if (value == 'view') {
                                        context.push('/receipt/${r.id}');
                                      } else if (value == 'pdf') {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('PDF export coming soon'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      PopupMenuItem(
                                        value: 'view',
                                        child: Row(
                                          children: [
                                            Icon(Icons.receipt_long_outlined, size: 18, color: textPrimary),
                                            const SizedBox(width: spaceSm),
                                            Text('View Full Receipt', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textPrimary)),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'pdf',
                                        child: Row(
                                          children: [
                                            const Icon(Icons.picture_as_pdf_outlined, size: 18, color: AppColors.primary),
                                            const SizedBox(width: spaceSm),
                                            Text('Share PDF', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color cardBg;
  final Color textPrimary;
  final Color textSec;
  final bool isDark;
  final Color waveColor;
  final List<double> wavePoints;
  final double animationValue;

  const _StatCard({
    required this.label,
    required this.count,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.cardBg,
    required this.textPrimary,
    required this.textSec,
    required this.isDark,
    required this.waveColor,
    required this.wavePoints,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
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
          // Wave graphic
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 38,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              child: CustomPaint(
                painter: _AnalyticsSparklinePainter(
                  dataPoints: wavePoints,
                  fillColor: waveColor,
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
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                      child: Icon(icon, color: iconColor, size: 14),
                    ),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textSec,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: (label == 'Expiring' && count > 0)
                        ? AppColors.warning
                        : ((label == 'Expired' && count > 0) ? AppColors.error : textPrimary),
                  ),
                ),
                const Spacer(),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: textSec,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
