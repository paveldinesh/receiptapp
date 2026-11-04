import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    Widget item(IconData icon, String label, String path) {
      final active = loc.startsWith(path);
      return Tooltip(
        message: label,
        child: InkResponse(
          onTap: () => context.go(path),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? Colors.white : Colors.transparent,
            ),
            child: Icon(icon, color: active ? AppColors.primary : AppColors.navBarInactiveIcon),
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.navBarBackground,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            item(Icons.home_rounded, 'Home', '/home'),
            item(Icons.bar_chart_rounded, 'Stats', '/analytics'),
            Tooltip(
              message: 'Scan receipt',
              child: InkResponse(
                onTap: () => context.push('/scan'),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(color: AppColors.dotYellow, shape: BoxShape.circle),
                  child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 28),
                ),
              ),
            ),
            item(Icons.search_rounded, 'Search', '/search'),
            item(Icons.shield_rounded, 'Warranty', '/warranty'),
          ]),
        ),
      ),
    );
  }
}
