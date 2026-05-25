import 'package:flutter/material.dart';

class AppColors {
  // Sidebar - slate-800/900 gradient (sama persis dengan PHP)
  static const Color sidebarDark = Color(0xFF1E293B); // slate-800
  static const Color sidebarDeep = Color(0xFF0F172A); // slate-900
  static const Color sidebarHover = Color(0xFF334155); // slate-700
  static const Color sidebarBorder = Color(0xFF334155); // slate-700

  // Primary accent - blue-600 (tombol PHP)
  static const Color primary = Color(0xFF2563EB); // blue-600
  static const Color primaryHover = Color(0xFF1D4ED8); // blue-700
  static const Color primaryLight = Color(0xFFDBEAFE); // blue-100

  // Background - gray-50 (sama dengan PHP)
  static const Color background = Color(0xFFF9FAFB); // gray-50
  static const Color surface = Color(0xFFFFFFFF); // white
  static const Color surfaceVariant = Color(0xFFF3F4F6); // gray-100

  // Text
  static const Color textPrimary = Color(0xFF1F2937); // gray-800
  static const Color textSecondary = Color(0xFF6B7280); // gray-500
  static const Color textHint = Color(0xFF9CA3AF); // gray-400
  static const Color textMuted = Color(0xFF374151); // gray-700

  // Border
  static const Color border = Color(0xFFE5E7EB); // gray-200
  static const Color borderLight = Color(0xFFF3F4F6); // gray-100
  static const Color divider = Color(0xFFE5E7EB);

  // Status badges (sama dengan PHP)
  static const Color success = Color(0xFF16A34A); // green-600
  static const Color successBg = Color(0xFFDCFCE7); // green-100
  static const Color successText = Color(0xFF15803D); // green-700

  static const Color error = Color(0xFFDC2626); // red-600
  static const Color errorBg = Color(0xFFFEE2E2); // red-100
  static const Color errorText = Color(0xFFB91C1C); // red-700

  static const Color warning = Color(0xFFD97706); // amber-600
  static const Color warningBg = Color(0xFFFEF3C7); // yellow-100
  static const Color warningText = Color(0xFFB45309); // amber-700

  static const Color info = Color(0xFF2563EB); // blue-600
  static const Color infoBg = Color(0xFFDBEAFE); // blue-100
  static const Color infoText = Color(0xFF1D4ED8); // blue-700

  // Badge colors (PHP style)
  static const Color badgeBlue = Color(0xFFDBEAFE);
  static const Color badgeBlueText = Color(0xFF1D4ED8);
  static const Color badgeGreen = Color(0xFFDCFCE7);
  static const Color badgeGreenText = Color(0xFF15803D);
  static const Color badgeRed = Color(0xFFFEE2E2);
  static const Color badgeRedText = Color(0xFFB91C1C);
  static const Color badgeOrange = Color(0xFFFFEDD5);
  static const Color badgeOrangeText = Color(0xFFC2410C);
  static const Color badgePurple = Color(0xFFF3E8FF);
  static const Color badgePurpleText = Color(0xFF7E22CE);
  static const Color badgeGray = Color(0xFFF3F4F6);
  static const Color badgeGrayText = Color(0xFF374151);

  // Header white (PHP header)
  static const Color headerBg = Color(0xFFFFFFFF);
  static const Color headerBorder = Color(0xFFE5E7EB);

  // Chart colors
  static const List<Color> chartColors = [
    Color(0xFF2563EB), // blue
    Color(0xFF16A34A), // green
    Color(0xFFDC2626), // red
    Color(0xFF9333EA), // purple
    Color(0xFFD97706), // amber
  ];

  // Tambahan agar error hilang
  static const Color cardBorder = Color(0xFFE0E0E0); // abu-abu terang
  static const Color infoLight = Color(0xFFD1ECF1); // biru muda
  static const Color successLight = Color(0xFFD4EDDA); // hijau muda
  static const Color errorLight = Color(0xFFF8D7DA); // merah muda
  static const Color warningLight = Color(0xFFFFF3CD); // kuning muda
  static const Color secondaryLight = Color(0xFFE2E3E5); // abu-abu muda
  static const Color secondary = Color(0xFF6C757D); // abu-abu gelap
  static const Color primaryDark = Color(0xFF004085); // biru gelap
}
