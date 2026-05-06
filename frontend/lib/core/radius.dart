import 'package:flutter/material.dart';

/// Design system border radius sabitleri.
/// Kullanım: AppRadius.cardRadius, AppRadius.buttonRadius
class AppRadius {
  AppRadius._();

  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;   // Kart varsayılanı
  static const double xl   = 20.0;
  static const double xxl  = 28.0;   // Modal / BottomSheet
  static const double full = 999.0;  // Pill buton / badge

  /// Tüm kart bileşenleri için → 16dp
  static BorderRadius get cardRadius =>
      BorderRadius.circular(lg);

  /// Butonlar için → 12dp
  static BorderRadius get buttonRadius =>
      BorderRadius.circular(md);

  /// Pill badge / tag için → tam yuvarlak
  static BorderRadius get badgeRadius =>
      BorderRadius.circular(full);

  /// BottomSheet ve modal için → sadece üst köşeler yuvarlanır
  static const BorderRadius sheetRadius = BorderRadius.vertical(
    top: Radius.circular(xxl),
  );

  /// Küçük bileşenler (chip, input) için → 8dp
  static BorderRadius get smallRadius =>
      BorderRadius.circular(sm);
}
