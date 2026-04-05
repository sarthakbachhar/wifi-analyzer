import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wifi_network.dart';

// ─── Color palette ────────────────────────────────────────────────────────────
class AppColors {
  // Backgrounds
  static const background = Color(0xFF060B18);
  static const surface = Color(0xFF0D1526);
  static const card = Color(0xFF162033);
  static const cardElevated = Color(0xFF1C2A40);
  static const border = Color(0xFF1E3A5F);

  // Brand accent
  static const cyan = Color(0xFF00D4FF);
  static const cyanDim = Color(0xFF0099BB);
  static const purple = Color(0xFF7B3FF2);

  // Risk colors
  static const critical = Color(0xFFFF1744);
  static const high = Color(0xFFFF5252);
  static const medium = Color(0xFFFFB300);
  static const low = Color(0xFF69F0AE);
  static const secure = Color(0xFF00E676);
  static const info = Color(0xFF40C4FF);

  // Text
  static const textPrimary = Color(0xFFE8F4FD);
  static const textSecondary = Color(0xFF7B9CB5);
  static const textMuted = Color(0xFF3D5A73);
}

// ─── Risk-aware color helpers ─────────────────────────────────────────────────
Color riskLevelColor(RiskLevel level) {
  switch (level) {
    case RiskLevel.critical:
      return AppColors.critical;
    case RiskLevel.high:
      return AppColors.high;
    case RiskLevel.medium:
      return AppColors.medium;
    case RiskLevel.low:
      return AppColors.low;
    case RiskLevel.secure:
      return AppColors.secure;
    case RiskLevel.unknown:
      return AppColors.textSecondary;
  }
}

Color scoreColor(int score) {
  if (score >= 85) return AppColors.secure;
  if (score >= 65) return AppColors.low;
  if (score >= 45) return AppColors.medium;
  if (score >= 25) return AppColors.high;
  return AppColors.critical;
}

Color severityColor(Severity severity) {
  switch (severity) {
    case Severity.info:
      return AppColors.info;
    case Severity.low:
      return AppColors.low;
    case Severity.medium:
      return AppColors.medium;
    case Severity.high:
      return AppColors.high;
    case Severity.critical:
      return AppColors.critical;
  }
}

// ─── Theme ────────────────────────────────────────────────────────────────────
ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.cyan,
      secondary: AppColors.purple,
      surface: AppColors.surface,
      background: AppColors.background,
      error: AppColors.critical,
      onPrimary: AppColors.background,
      onSurface: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.surface,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.card,
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        final isSelected = states.contains(MaterialState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isSelected ? AppColors.cyan : AppColors.textMuted,
        );
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        final isSelected = states.contains(MaterialState.selected);
        return IconThemeData(
          color: isSelected ? AppColors.cyan : AppColors.textMuted,
          size: 22,
        );
      }),
    ),
    cardTheme: CardTheme(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
      displayMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800),
      headlineLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textSecondary),
      bodySmall: TextStyle(color: AppColors.textMuted),
      labelLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 0,
    ),
    useMaterial3: true,
  );
}
