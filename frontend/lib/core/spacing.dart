/// Design system spacing & layout sabitleri.
/// Kullanım: AppSpacing.lg, AppLayout.cardPadding
library;

class AppSpacing {
  AppSpacing._();

  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 12.0;
  static const double lg  = 16.0;
  static const double xl  = 20.0;
  static const double xxl = 24.0;
  static const double x3l = 32.0;
  static const double x4l = 40.0;
  static const double x5l = 48.0;
}

class AppLayout {
  AppLayout._();

  /// Ekran yatay kenar boşluğu
  static const double screenPaddingH  = 20.0;

  /// Ekran dikey kenar boşluğu
  static const double screenPaddingV  = 16.0;

  /// Section'lar arası boşluk
  static const double sectionGap      = 16.0;

  /// Kart iç padding
  static const double cardPadding     = 16.0;

  /// Liste öğesi yüksekliği (Android min touch target: 48dp)
  static const double listItemHeight  = 52.0;

  /// Bottom NavigationBar toplam yüksekliği (safe area dahil)
  static const double bottomNavHeight = 80.0;

  /// Material 3 AppBar yüksekliği
  static const double appBarHeight    = 56.0;
}
