import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persona_mirror/core/spacing.dart';
import 'package:persona_mirror/core/radius.dart';

class AppTheme {
  // ── Backgrounds ───────────────────────────────────────────
  static const Color bgPrimary   = Color(0xFFFAF7F4); // Krem-beyaz ana arka plan
  static const Color bgSecondary = Color(0xFFF5EFE9); // Section / kart arka planı
  static const Color bgCard      = Color(0xFFFFFFFF); // Beyaz kart yüzeyi
  static const Color bgOverlay   = Color(0x0A000000); // Hover overlay

  // ── Brand / Persona Accents (vibrant) ─────────────────────
  static const Color accentViolet = Color(0xFF7C4DFF); // Primary — psikoloji/kişilik
  static const Color accentCoral  = Color(0xFFFF6B6B); // Enerji, dikkat
  static const Color accentGold   = Color(0xFFFFB300); // Başarı, sıcaklık
  static const Color accentTeal   = Color(0xFF00BFA5); // Huzur, denge
  static const Color accentSky    = Color(0xFF29B6F6); // Keşif, açıklık
  static const Color accentPurple = Color(0xFFAB47BC); // Yaratıcılık
  static const Color accentGreen  = Color(0xFF66BB6A); // Tamamlandı

  // ── Persona Type Colors ───────────────────────────────────
  static const Color personaAnalyst  = Color(0xFF5C6BC0);
  static const Color personaDiplomat = Color(0xFF26A69A);
  static const Color personaSentinel = Color(0xFFEF5350);
  static const Color personaExplorer = Color(0xFFFFB300);

  // ── Text ─────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF7A7A7A);
  static const Color textTertiary  = Color(0xFFABABAB);
  static const Color textInverse   = Color(0xFFFFFFFF);

  // ── Borders ──────────────────────────────────────────────
  static const Color borderLight  = Color(0xFFEFEFEF);
  static const Color borderMedium = Color(0xFFE0D9D2);

  // ── Status ───────────────────────────────────────────────
  static const Color statusSuccess = Color(0xFF66BB6A);
  static const Color statusWarning = Color(0xFFFFB300);
  static const Color statusError   = Color(0xFFFF6B6B);

  // ── Legacy aliases (backward compat) ─────────────────────
  static const Color deepNavy  = textPrimary;
  static const Color softCream = bgPrimary;

  // ── Shadows ──────────────────────────────────────────────
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get shadowCard => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get glowViolet => [
    BoxShadow(
      color: accentViolet.withValues(alpha: 0.35),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get glowCoral => [
    BoxShadow(
      color: accentCoral.withValues(alpha: 0.35),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  // ── Theme ─────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgPrimary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentViolet,
        primary: accentViolet,
        secondary: accentCoral,
        surface: bgCard,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontSize: 34,
        ),
        titleLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.w700,
          color: textPrimary,
          fontSize: 22,
        ),
        titleMedium: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontSize: 17,
        ),
        bodyLarge: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 15,
        ),
        bodySmall: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 13,
        ),
        labelSmall: GoogleFonts.inter(
          color: textTertiary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: AppLayout.appBarHeight,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCard,
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.xl,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide: const BorderSide(color: accentViolet, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide: const BorderSide(color: statusError, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide: const BorderSide(color: statusError, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textTertiary, fontSize: 15),
        errorStyle: const TextStyle(color: statusError, fontSize: 12),
        prefixIconColor: textTertiary,
      ),
    );
  }
}
