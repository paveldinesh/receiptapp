import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/receipt/domain/receipt_model.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/dashboard_screen.dart';
import '../../features/receipt/presentation/scan_receipt_screen.dart';
import '../../features/receipt/presentation/receipt_preview_screen.dart';
import '../../features/receipt/presentation/receipt_details_screen.dart';
import '../../features/warranty/presentation/warranty_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../widgets/bottom_nav_bar.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) async {
      final user = authState.value;
      final path = state.uri.path;
      final prefs = await SharedPreferences.getInstance();
      final onboarded = prefs.getBool('onboarded') ?? false;

      final isAuthRoute = path == '/login' || path == '/register';
      final isSplash = path == '/splash';

      if (user == null) {
        if (!onboarded && isSplash) return null;
        if (isSplash) return '/login';
        if (isAuthRoute) return null;
        return '/login';
      }

      // Logged in
      if (isSplash || isAuthRoute) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOutCubic).animate(animation),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.02),
                      end: Offset.zero,
                    ).chain(CurveTween(curve: Curves.easeInOutCubic)).animate(animation),
                    child: child,
                  ),
                );
              },
            ),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SearchScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOutCubic).animate(animation),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.02),
                      end: Offset.zero,
                    ).chain(CurveTween(curve: Curves.easeInOutCubic)).animate(animation),
                    child: child,
                  ),
                );
              },
            ),
          ),
          GoRoute(
            path: '/warranty',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const WarrantyScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOutCubic).animate(animation),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.02),
                      end: Offset.zero,
                    ).chain(CurveTween(curve: Curves.easeInOutCubic)).animate(animation),
                    child: child,
                  ),
                );
              },
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOutCubic).animate(animation),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.02),
                      end: Offset.zero,
                    ).chain(CurveTween(curve: Curves.easeInOutCubic)).animate(animation),
                    child: child,
                  ),
                );
              },
            ),
          ),
          GoRoute(
            path: '/analytics',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const AnalyticsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOutCubic).animate(animation),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.02),
                      end: Offset.zero,
                    ).chain(CurveTween(curve: Curves.easeInOutCubic)).animate(animation),
                    child: child,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/scan',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ScanReceiptScreen(
          startInGallery: state.uri.queryParameters['source'] == 'gallery',
        ),
      ),
      GoRoute(
        path: '/preview',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ReceiptPreviewScreen(
            imagePath: extra?['imagePath'] as String?,
            ocrText: extra?['ocrText'] as String?,
            imagePaths: (extra?['imagePaths'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
            initialPaymentMethod: extra?['paymentMethod'] as String?,
            parsedData: extra?['parsedData'] as Map<String, dynamic>?,
            existingReceipt: extra?['receipt'] as ReceiptModel?,
          );
        },
      ),
      GoRoute(
        path: '/receipt/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ReceiptDetailsScreen(receiptId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),

    ],
  );
});
