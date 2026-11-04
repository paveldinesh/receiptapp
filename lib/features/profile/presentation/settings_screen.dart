import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app.dart';
import '../../../theme/app_colors.dart';
import '../../../core/constants/spacing.dart';

final darkModeProvider = StateProvider<bool>((ref) => false);
final notificationsProvider = StateProvider<bool>((ref) => true);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final darkMode = themeMode == ThemeMode.dark;
    final notifications = ref.watch(notificationsProvider);
    final isDark = themeMode == ThemeMode.dark;

    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSec = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => context.pop()),
        title: Text('Settings', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: textPrimary))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(spaceLg, spaceSm, spaceLg, spaceXxl),
        children: [
          // ── Appearance ────────────────────────────────────────────────────
          _SettingsSection(title: 'Appearance', textSec: textSec, children: [
            _ToggleTile(
              icon: Icons.dark_mode_outlined,
              label: 'Dark Mode',
              sub: 'Switch to dark theme',
              value: darkMode,
              onChanged: (v) => ref.read(themeModeProvider.notifier).toggle(v),
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSec: textSec),
          ]),
          const SizedBox(height: spaceMd),

          // ── Notifications ─────────────────────────────────────────────────
          _SettingsSection(title: 'Notifications', textSec: textSec, children: [
            _ToggleTile(
              icon: Icons.notifications_outlined,
              label: 'Push Notifications',
              sub: 'Warranty expiry alerts',
              value: notifications,
              onChanged: (v) => ref.read(notificationsProvider.notifier).state = v,
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSec: textSec),
          ]),
          const SizedBox(height: spaceMd),

          // ── Storage ───────────────────────────────────────────────────────
          _SettingsSection(title: 'Storage & Sync', textSec: textSec, children: [
            _NavTile(
              icon: Icons.folder_outlined,
              label: 'Storage Provider',
              sub: 'Manage where receipts are stored',
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSec: textSec,
              onTap: () {}),
            _NavTile(
              icon: Icons.cloud_sync_outlined,
              label: 'Sync Settings',
              sub: 'Auto-sync to Google Drive',
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSec: textSec,
              onTap: () {}),
          ]),
          const SizedBox(height: spaceMd),

          // ── About ─────────────────────────────────────────────────────────
          _SettingsSection(title: 'About', textSec: textSec, children: [
            _NavTile(
              icon: Icons.info_outline_rounded,
              label: 'App Version',
              sub: 'v1.0.0',
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSec: textSec,
              onTap: () {}),
            _NavTile(
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy Policy',
              sub: 'How we handle your data',
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSec: textSec,
              onTap: () {}),
          ]),
        ]));
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color textSec;

  const _SettingsSection({required this.title, required this.children, required this.textSec});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: spaceXs, bottom: spaceSm),
          child: Text(title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: textSec, letterSpacing: 0.3))),
        ...children,
      ]);
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSec;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.value,
    required this.onChanged,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: spaceSm),
      padding: const EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.outlineDark : AppColors.outlineLight)),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primary, size: 18)),
          const SizedBox(width: spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: textPrimary)),
                Text(sub, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSec)),
              ])),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary),
        ]));
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textSec;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textSec,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: spaceSm),
        padding: const EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceMd),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.outlineDark : AppColors.outlineLight)),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: AppColors.primary, size: 18)),
            const SizedBox(width: spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: textPrimary)),
                  Text(sub, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSec)),
                ])),
            Icon(Icons.chevron_right_rounded, color: textSec, size: 20),
          ])));
  }
}
