import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;

  const AppBadge({
    super.key,
    required this.label,
    this.color,
    this.textColor,
  });

  factory AppBadge.success(String label) =>
      AppBadge(label: label, color: AppColors.successBg, textColor: AppColors.success);

  factory AppBadge.warning(String label) =>
      AppBadge(label: label, color: AppColors.warningBg, textColor: Color(0xFF856404));

  factory AppBadge.error(String label) =>
      AppBadge(label: label, color: AppColors.errorBg, textColor: AppColors.error);

  factory AppBadge.info(String label) =>
      AppBadge(label: label, color: AppColors.infoBg, textColor: AppColors.info);

  factory AppBadge.primary(String label) =>
      AppBadge(label: label, color: AppColors.infoBg.withValues(alpha: 0.2), textColor: AppColors.primary);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor ?? AppColors.textSecondary,
        ),
      ),
    );
  }
}



