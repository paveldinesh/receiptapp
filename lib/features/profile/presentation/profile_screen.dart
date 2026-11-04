import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_repository.dart';
import '../../home/presentation/dashboard_controller.dart';
import '../../../theme/app_colors.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/spacing.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final stats = ref.watch(dashboardStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSec = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final rupee = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(spaceLg, spaceMd, spaceLg, spaceXxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Text('Profile', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: textPrimary, letterSpacing: -0.3)),
              const SizedBox(height: spaceLg),

              // ── Avatar + info ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(spaceLg),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? AppColors.outlineDark : AppColors.outlineLight)),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: NetworkImage(
                        user?.photoUrl ??
                            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=150&q=80')),
                    const SizedBox(width: spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.displayName ?? 'Sarah Kapur',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: textPrimary)),
                          const SizedBox(height: spaceXs),
                          Text(user?.email ?? 'sarah.kapur@gmail.com',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textSec)),
                        ])),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 18)),
                  ])),
              const SizedBox(height: spaceMd),

              // ── Stats row ─────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(spaceLg),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Expanded(
                      child: _ProfileStat(
                        label: 'Receipts',
                        value: '${stats.totalCount}')),
                    Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.25)),
                    Expanded(
                      child: _ProfileStat(
                        label: 'Warranties',
                        value: '${stats.activeWarranties}')),
                    Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.25)),
                    Expanded(
                      child: _ProfileStat(
                        label: 'This month',
                        value: rupee.format(stats.totalSpendMonth))),
                  ])),
              const SizedBox(height: spaceMd),

              // ── Menu sections ─────────────────────────────────────────────
              _Section(
                title: 'Account',
                textSec: textSec,
                children: [
                  _MenuItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Personal Information',
                    isDark: isDark,
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSec: textSec,
                    onTap: () {}),
                  _MenuItem(
                    icon: Icons.notifications_none_rounded,
                    label: 'Notifications',
                    isDark: isDark,
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSec: textSec,
                    onTap: () {}),
                  _MenuItem(
                    icon: Icons.cloud_outlined,
                    label: 'Backup & Sync',
                    isDark: isDark,
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSec: textSec,
                    onTap: () {}),
                ]),
              const SizedBox(height: spaceMd),

              _Section(
                title: 'Preferences',
                textSec: textSec,
                children: [
                  _MenuItem(
                    icon: Icons.dark_mode_outlined,
                    label: 'Appearance',
                    isDark: isDark,
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSec: textSec,
                    onTap: () => context.push('/settings')),
                  _MenuItem(
                    icon: Icons.security_outlined,
                    label: 'Privacy & Security',
                    isDark: isDark,
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSec: textSec,
                    onTap: () {}),
                ]),
              const SizedBox(height: spaceMd),

              _Section(
                title: 'Support',
                textSec: textSec,
                children: [
                  _MenuItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help Center',
                    isDark: isDark,
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSec: textSec,
                    onTap: () {}),
                  _MenuItem(
                    icon: Icons.info_outline_rounded,
                    label: 'About ReceiptVault',
                    isDark: isDark,
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSec: textSec,
                    onTap: () {}),
                ]),
              const SizedBox(height: spaceMd),

              // ── Sign out ──────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.outlineDark : AppColors.outlineLight)),
                child: _MenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Sign Out',
                  isDark: isDark,
                  cardBg: Colors.transparent,
                  textPrimary: AppColors.error,
                  textSec: AppColors.error,
                  iconColor: AppColors.error,
                  isLast: true,
                  onTap: () {
                    ref.read(authRepositoryProvider).signOut();
                    context.go('/login');
                  })),
              const SizedBox(height: spaceXl),

              // ── Version ───────────────────────────────────────────────────
              Center(
                child: Text('ReceiptVault v1.0.0', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSec))),
            ]))));
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
        const SizedBox(height: spaceXs),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
      ]);
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color textSec;

  const _Section({required this.title, required this.children, required this.textSec});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: spaceXs, bottom: spaceSm),
          child: Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: textSec, letterSpacing: 0.3))),
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16)),
          child: Column(children: children)),
      ]);
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSec;
  final Color? iconColor;
  final bool isLast;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSec,
    required this.onTap,
    this.trailing,
    this.iconColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.outlineDark : AppColors.outlineLight)),
      margin: const EdgeInsets.only(bottom: spaceSm),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceMd),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                  borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor ?? AppColors.primary, size: 19)),
              const SizedBox(width: spaceMd),
              Expanded(
                child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: textPrimary))),
              trailing ?? Icon(Icons.chevron_right_rounded, color: textSec, size: 20),
            ]))));
  }
}
