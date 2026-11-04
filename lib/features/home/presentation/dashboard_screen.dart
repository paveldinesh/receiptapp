import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dashboard_controller.dart';
import '../../receipt/domain/receipt_model.dart';
import '../../../core/theme/colors.dart';
import '../../../widgets/receipt_ui.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardReceiptsProvider);
    final s = ref.watch(dashboardStatsProvider);
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final sheet = theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: AppColors.heroDark,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (_, __) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(dashboardReceiptsProvider),
            child: const Text('Could not load receipts. Tap to retry.'),
          ),
        ),
        data: (_) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardReceiptsProvider),
          child: CustomScrollView(slivers: [
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: sheet,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: SafeArea(
                  bottom: false,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text('ReceiptVault', style: t.titleLarge),
                      const Spacer(),
                      IconButton.filledTonal(
                        tooltip: 'Profile',
                        onPressed: () => context.go('/profile'),
                        icon: const Icon(Icons.person_outline_rounded),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    Text('Spent in ${DateFormat('MMMM').format(DateTime.now())}', style: t.bodyMedium),
                    const SizedBox(height: 8),
                    AmountText(s.totalSpendMonth, style: t.displayLarge!),
                    const SizedBox(height: 24),
                    Row(children: [
                      _Stat('Receipts', '${s.totalCount}', () => context.go('/search')),
                      const SizedBox(width: 8),
                      _Stat('Warranties', '${s.activeWarranties}', () => context.go('/warranty')),
                      const SizedBox(width: 8),
                      _Stat('Expiring', '${s.expiringWarranties.length}', () => context.go('/warranty'),
                          alert: s.expiringWarranties.isNotEmpty),
                    ]),
                  ]),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(children: [
                  _Pill(Icons.upload_rounded, 'Upload', () => context.push('/scan?source=gallery')),
                  const SizedBox(width: 8),
                  _Pill(Icons.edit_outlined, 'Manual', () => context.push('/preview')),
                  const SizedBox(width: 8),
                  _Pill(Icons.bar_chart_rounded, 'Stats', () => context.go('/analytics')),
                ]),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                decoration: BoxDecoration(
                  color: sheet,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text('Recent receipts', style: t.titleLarge),
                    const Spacer(),
                    TextButton(onPressed: () => context.go('/search'), child: const Text('View all')),
                  ]),
                  const SizedBox(height: 8),
                  if (s.recentReceipts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(children: [
                          const Icon(Icons.receipt_long_rounded, size: 40),
                          const SizedBox(height: 12),
                          Text('Your vault is empty', style: t.titleMedium),
                          const SizedBox(height: 4),
                          Text('Scan a receipt to get started', style: t.bodyMedium),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => context.push('/scan'),
                            child: const Text('Scan a receipt'),
                          ),
                        ]),
                      ),
                    )
                  else
                    ...s.recentReceipts.map((r) => _Row(r)),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final VoidCallback onTap;
  final bool alert;
  const _Stat(this.label, this.value, this.onTap, {this.alert = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Material(
        color: alert ? AppColors.warrantyAmberBg : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: theme.textTheme.bodySmall?.copyWith(color: alert ? AppColors.warning : null),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 16),
              Text(value,
                  style: theme.textTheme.titleLarge?.copyWith(color: alert ? AppColors.warning : null)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Pill(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) => Expanded(
        child: SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(icon, size: 18, color: Colors.white),
            label: FittedBox(child: Text(label, style: const TextStyle(color: Colors.white))),
            style: OutlinedButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              side: const BorderSide(color: Colors.white24),
              shape: const StadiumBorder(),
            ),
          ),
        ),
      );
}

class _Row extends StatelessWidget {
  final ReceiptModel r;
  const _Row(this.r);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final hasWarranty = (r.warrantyMonths ?? 0) > 0;
    final days = hasWarranty ? warrantyExpiry(r).difference(DateTime.now()).inDays : -1;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push('/receipt/${r.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          ReceiptThumb(r),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(receiptTitle(r), style: t.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text('${r.category} • ${DateFormat('d MMM').format(r.purchaseDate)}', style: t.bodySmall),
            ]),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            AmountText(r.totalAmount, style: t.titleMedium!),
            if (days >= 0) ...[
              const SizedBox(height: 4),
              Text('${days}d left',
                  style: t.labelSmall?.copyWith(color: days <= 30 ? AppColors.warning : null)),
            ],
          ]),
        ]),
      ),
    );
  }
}
