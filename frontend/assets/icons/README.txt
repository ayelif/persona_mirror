Bu klasöre uygulama ikonunu ekleyin:

- app_icon.png      → 1024x1024 piksel, PNG formatı, şeffaf arka plan OLMADAN
                      (hem Android hem iOS için kullanılır)

- splash_logo.png   → 288x288 piksel, PNG formatı, şeffaf arka plan ile
                      (splash screen için kullanılır)

Dosyaları ekledikten sonra aşağıdaki komutları frontend/ klasöründe çalıştırın:

  flutter pub get
  flutter pub run flutter_launcher_icons
  flutter pub run flutter_native_splash:create
