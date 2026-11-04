import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme/app_colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/spacing.dart';

/// 3-page onboarding carousel that matches the design guidelines.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _controller = PageController();
  int _current = 0;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded', true);
    if (mounted) context.go('/login');
  }

  void _next() {
    if (_current < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 340),
        curve: Curves.easeInOut);
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _showSplash
            ? _buildSplashContent()
            : PageView(
                key: const ValueKey('onboarding_pageview'),
                controller: _controller,
                onPageChanged: (i) => setState(() => _current = i),
                children: [
                  _Slide1(onNext: _next, onSkip: _completeOnboarding),
                  _Slide2(onNext: _next, onSkip: _completeOnboarding),
                  _Slide3(onStart: _completeOnboarding, onLater: _completeOnboarding),
                ])));
  }

  Widget _buildSplashContent() {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      key: const ValueKey('splash_content'),
      color: const Color(0xFFF8F9FA),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain),
            const SizedBox(height: spaceLg),
            Text(
              'Slipo',
              style: textTheme.displayLarge?.copyWith(
                color: Colors.black)),
            const SizedBox(height: spaceSm),
            Text(
              'Never lose a receipt again',
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.grey)),
          ])));
  }
}

class _Slide1 extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _Slide1({required this.onNext, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Expanded(
          flex: 52,
          child: Container(
            width: double.infinity,
            color: AppColors.surfaceVariantLight,
            child: const Center(
              child: _VaultHeroIllustration()))),
        Expanded(
          flex: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: spaceLg),
            child: Column(
              children: [
                const SizedBox(height: spaceXl),
                Text(
                  'Track Every Purchase',
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimaryLight,
                    letterSpacing: -0.3),
                  textAlign: TextAlign.center),
                const SizedBox(height: spaceSm),
                Text(
                  'Scan, store, and organize all your\nreceipts in one secure vault.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondaryLight,
                    height: 1.5),
                  textAlign: TextAlign.center),
                const SizedBox(height: spaceLg),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Dot(active: true),
                    SizedBox(width: 6),
                    _Dot(active: false),
                    SizedBox(width: 6),
                    _Dot(active: false),
                  ]),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.r14))),
                    onPressed: onNext,
                    child: Text(
                      'Get Started',
                      style: textTheme.labelLarge?.copyWith(color: Colors.white)))),
                const SizedBox(height: spaceSm),
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Skip',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.textSecondaryLight))),
                const SizedBox(height: spaceMd),
              ]))),
      ]);
  }
}

class _Slide2 extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _Slide2({required this.onNext, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Expanded(
          flex: 52,
          child: Container(
            width: double.infinity,
            color: AppColors.primary,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle),
                    child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 64)),
                  const SizedBox(height: spaceMd),
                  const _WarrantyMockCard(
                    icon: Icons.phone_iphone_rounded,
                    label: 'iPhone 15 Pro',
                    days: '186 days left',
                    isGreen: true),
                  const SizedBox(height: spaceSm),
                  const _WarrantyMockCard(
                    icon: Icons.laptop_mac_rounded,
                    label: 'MacBook Air M2',
                    days: '12 days left',
                    isGreen: false),
                ])))),
        Expanded(
          flex: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: spaceLg),
            child: Column(
              children: [
                const SizedBox(height: spaceXl),
                Text(
                  'Never Lose a Warranty',
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimaryLight,
                    letterSpacing: -0.3),
                  textAlign: TextAlign.center),
                const SizedBox(height: spaceSm),
                Text(
                  'Get smart alerts before your warranties\nexpire so you\'re always protected.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondaryLight,
                    height: 1.5),
                  textAlign: TextAlign.center),
                const SizedBox(height: spaceLg),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Dot(active: false),
                    SizedBox(width: 6),
                    _Dot(active: true),
                    SizedBox(width: 6),
                    _Dot(active: false),
                  ]),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r14))),
                    onPressed: onNext,
                    child: Text(
                      'Continue',
                      style: textTheme.labelLarge?.copyWith(color: Colors.white)))),
                const SizedBox(height: spaceSm),
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Skip',
                    style: textTheme.labelLarge?.copyWith(color: AppColors.textSecondaryLight))),
                const SizedBox(height: spaceMd),
              ]))),
      ]);
  }
}

class _Slide3 extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onLater;

  const _Slide3({required this.onStart, required this.onLater});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Expanded(
          flex: 52,
          child: Container(
            width: double.infinity,
            color: AppColors.bgDark,
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(spaceLg),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.r24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 32, offset: const Offset(0, 16)),
                  ]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.r24),
                  child: _PhoneMockup()))))),
        Expanded(
          flex: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: spaceLg),
            child: Column(
              children: [
                const SizedBox(height: spaceXl),
                Text(
                  "Let's add your first receipt",
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimaryLight,
                    letterSpacing: -0.3),
                  textAlign: TextAlign.center),
                const SizedBox(height: spaceSm),
                Text(
                  'Tap the + button anytime to scan,\nupload, or manually add a receipt.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondaryLight,
                    height: 1.5),
                  textAlign: TextAlign.center),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r14))),
                    onPressed: onStart,
                    child: Text(
                      'Add My First Receipt',
                      style: textTheme.labelLarge?.copyWith(color: Colors.white)))),
                const SizedBox(height: spaceSm),
                TextButton(
                  onPressed: onLater,
                  child: Text(
                    "I'll do it later",
                    style: textTheme.labelLarge?.copyWith(color: AppColors.textSecondaryLight))),
                const SizedBox(height: spaceMd),
              ]))),
      ]);
  }
}

class _VaultHeroIllustration extends StatelessWidget {
  const _VaultHeroIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.06))),
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.bgDark,
            borderRadius: BorderRadius.circular(AppDimensions.r28),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 12)),
            ]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.r28),
            child: Image.asset(
              'assets/images/logo.png',
              width: 180,
              height: 180,
              fit: BoxFit.cover))),
        Positioned(
          right: 20,
          top: 40,
          child: Transform.rotate(
            angle: 0.2,
            child: Container(
              width: 52,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.r6),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)]),
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  7,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Container(
                      height: 3,
                      width: i % 3 == 0 ? 28 : 20,
                      color: const Color(0xFFE0E0E0)))))))),
      ]);
  }
}

class _PhoneMockup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 340,
      decoration: const BoxDecoration(
        color: AppColors.bgDark),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('9:41', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                const Icon(Icons.signal_cellular_4_bar, color: Colors.white, size: 14),
              ])),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Text(
                  'Welcome to Kepto!\nLet\'s add your first receipt.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, height: 1.4)),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to get started.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70)),
              ])),
          const Spacer(),
          Container(
            height: 56,
            color: AppColors.navBarBackground,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.home_rounded, color: AppColors.primaryMid, size: 20),
                const Icon(Icons.bar_chart_rounded, color: Colors.white38, size: 20),
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 20)),
                const Icon(Icons.search_rounded, color: Colors.white38, size: 20),
                const Icon(Icons.shield_rounded, color: Colors.white38, size: 20),
              ])),
        ]));
  }
}

class _WarrantyMockCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String days;
  final bool isGreen;

  const _WarrantyMockCard({
    required this.icon,
    required this.label,
    required this.days,
    required this.isGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: spaceXl),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: spaceSm, vertical: 3),
            decoration: BoxDecoration(
              color: isGreen ? AppColors.warrantyGreenBg : AppColors.warrantyAmberBg,
              borderRadius: BorderRadius.circular(6)),
            child: Text(
              days,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700,
                color: isGreen ? AppColors.warrantyGreenFg : AppColors.warrantyAmberFg))),
        ]));
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: active ? 22 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.outlineLight,
        borderRadius: BorderRadius.circular(4)));
  }
}
