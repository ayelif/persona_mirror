# Flutter için ProGuard Kuralları
# Flutter wrapper sınıflarını koru
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

# Supabase / Realtime için
-keep class io.github.jan.supabase.** { *; }
-dontwarn io.github.jan.supabase.**

# Kotlin coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}

# Google Sign-In
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# JSON (Gson)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**

# Uygulama modeli sınıflarını koru
-keep class com.personamirror.app.** { *; }
