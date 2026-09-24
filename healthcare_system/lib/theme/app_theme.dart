import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for the "Clinical Report" visual identity.
///
/// The palette and type system are chosen to feel like a diagnostic
/// read-out rather than a generic wellness app: an ink-navy primary,
/// a cool alabaster canvas, hairline borders instead of soft shadows,
/// and muted (not neon) risk colors.
class AppColors {
  AppColors._();

  static const ink = Color(0xFF14213D); // headlines, primary actions
  static const inkMuted = Color(0xFF3C4A6B); // secondary ink
  static const canvas = Color(0xFFF5F6F3); // page background
  static const surface = Color(0xFFFFFFFF); // cards
  static const hairline = Color(0xFFDDE1DE); // borders/dividers
  static const textPrimary = Color(0xFF1B2130);
  static const textMuted = Color(0xFF5C6470);

  // Risk bands — muted, clinical, not alarm colors.
  static const riskLow = Color(0xFF2D6A4F);
  static const riskLowBg = Color(0xFFE7F0EA);
  static const riskModerate = Color(0xFFB9762F);
  static const riskModerateBg = Color(0xFFF6EBDC);
  static const riskHigh = Color(0xFFA83A3A);
  static const riskHighBg = Color(0xFFF5E4E3);

  static Color riskColor(String band) {
    switch (band) {
      case 'Low':
        return riskLow;
      case 'Moderate':
        return riskModerate;
      case 'High':
        return riskHigh;
      default:
        return inkMuted;
    }
  }

  static Color riskBg(String band) {
    switch (band) {
      case 'Low':
        return riskLowBg;
      case 'Moderate':
        return riskModerateBg;
      case 'High':
        return riskHighBg;
      default:
        return canvas;
    }
  }
}

class AppType {
  AppType._();

  /// Editorial serif for headlines — gives the app an authored,
  /// "report" weight rather than a default SaaS sans-serif look.
  static TextStyle display({
    double size = 28,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.ink,
    double? height,
  }) =>
      GoogleFonts.fraunces(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: -0.3,
      );

  /// Body / UI text.
  static TextStyle body({
    double size = 15,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color);

  /// Monospace for numeric read-outs (percentages, stats) — makes
  /// data feel measured rather than decorative.
  static TextStyle data({
    double size = 15,
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.ibmPlexMono(
          fontSize: size, fontWeight: weight, color: color);
}

ThemeData buildAppTheme() {
  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.canvas,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.ink,
      surface: AppColors.surface,
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.canvas,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.ink,
      titleTextStyle: AppType.display(size: 19, weight: FontWeight.w600),
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      labelStyle: AppType.body(size: 13, color: AppColors.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.ink, width: 1.4),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: AppType.body(size: 15, weight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: AppColors.hairline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: AppType.body(size: 15, weight: FontWeight.w600),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.hairline,
      thickness: 1,
      space: 32,
    ),
  );
}
