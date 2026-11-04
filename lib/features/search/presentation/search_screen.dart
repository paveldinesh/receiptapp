import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'search_controller.dart';
import '../../../widgets/receipt_ui.dart';
import '../../../theme/app_colors.dart';
import '../../../core/constants/spacing.dart';


class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _textCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(searchQueryProvider.notifier).state = '';
        ref.read(searchFilterProvider.notifier).state = 'All';
      }
    });
    _textCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);
    final filter = ref.watch(searchFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSec = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final inputBg = isDark ? AppColors.surfaceVariantDark : Colors.white;

    final rupee = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(spaceLg, spaceMd, spaceLg, spaceSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Search and filter your receipts',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSec),
                  ),
                ],
              ),
            ),

            // ── Search bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: spaceLg),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: inputBg,
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
                child: TextField(
                  controller: _textCtrl,
                  onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search merchant, category, amount…',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textSec),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: isDark ? AppColors.neonCyan : AppColors.obsidianBlack,
                      size: 22,
                    ),
                    suffixIcon: _textCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, color: textSec, size: 20),
                            onPressed: () {
                              _textCtrl.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                            })
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14))))),
            const SizedBox(height: spaceSm),

            // ── Filter chips ───────────────────────────────────────────────
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: spaceLg),
                children: ['All', 'Warranty', 'Electronics', 'Food', 'Fashion', 'Grocery', 'Travel', 'Health', 'Other'].map((f) {
                  final sel = filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: spaceSm),
                    child: GestureDetector(
                      onTap: () => ref.read(searchFilterProvider.notifier).state = f,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel
                              ? (isDark ? AppColors.neonCyan : AppColors.obsidianBlack)
                              : (isDark ? AppColors.surfaceVariantDark : AppColors.softLightFill),
                          borderRadius: BorderRadius.circular(20),
                        ),
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
                }).toList())),
            const SizedBox(height: spaceMd),

            // ── Result count ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: spaceLg),
              child: Text(
                '${results.length} results',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSec, fontWeight: FontWeight.w500))),
            const SizedBox(height: spaceSm),

            // ── Result list ────────────────────────────────────────────────
            Expanded(
              child: results.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 52, color: textSec.withValues(alpha: 0.3)),
                        const SizedBox(height: spaceMd),
                        Text('No receipts found', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textSec)),
                        const SizedBox(height: spaceXs),
                        Text('Try a different search term', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textSec.withValues(alpha: 0.6))),
                      ])
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(spaceLg, 0, spaceLg, 80),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: spaceSm),
                      itemBuilder: (context, index) {
                        final r = results[index];
                        final parts = r.merchant.split(' | ');
                        final storeName = parts.last;
                        final (catBg, catFg, _) = categoryStyle(r.category);

                        String? warrantyLabel;
                        Color? wBg, wFg;
                        if (r.warrantyMonths != null && r.warrantyMonths! > 0) {
                          final exp = warrantyExpiry(r);
                          final diff = exp.difference(DateTime.now()).inDays;
                          if (diff > 0) {
                            warrantyLabel = '${diff}D LEFT';
                            wBg = diff <= 30 ? AppColors.warningLight : AppColors.warrantyGreenBg;
                            wFg = diff <= 30 ? AppColors.warning : AppColors.warrantyGreenFg;
                          }
                        }

                        return GestureDetector(
                          onTap: () => context.push('/receipt/${r.id}'),
                          child: Container(
                            padding: const EdgeInsets.all(spaceMd),
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
                            child: Row(
                              children: [
                                Container(
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
                                    storeName.isNotEmpty ? storeName.substring(0, 1).toUpperCase() : '?',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppColors.obsidianBlack,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: spaceMd),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        storeName.length > 14 ? '${storeName.substring(0, 14)}...' : storeName,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, color: textPrimary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: spaceXs),
                                      Row(
                                        children: [
                                          Text(
                                            DateFormat('d MMM yyyy').format(r.purchaseDate),
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSec)),
                                          const SizedBox(width: spaceSm),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(color: catBg, borderRadius: BorderRadius.circular(5)),
                                            child: Text(
                                              r.category.toUpperCase(),
                                              style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500, color: catFg))),
                                        ]),
                                    ])),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '-${rupee.format(r.totalAmount)}',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.error)),
                                    if (warrantyLabel != null) ...[
                                      const SizedBox(height: spaceXs),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: wBg, borderRadius: BorderRadius.circular(5)),
                                        child: Text(warrantyLabel, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: wFg))),
                                    ],
                                  ]),
                                const SizedBox(width: spaceSm),
                                Icon(Icons.chevron_right_rounded, color: textSec, size: 18),
                              ])));
                      })),
          ])));
  }
}
