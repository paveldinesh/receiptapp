import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class LoadingPlaceholder extends StatelessWidget {
  final double height;
  const LoadingPlaceholder({super.key, this.height = 80});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

