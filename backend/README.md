# 🖥️ Persona Mirror - Backend API

Bu dizin, Persona Mirror uygulamasının backend katmanına ait yapılandırmaları ve yardımcı betikleri barındırmaktadır.

## Mimarimiz

Persona Mirror, sunucusuz (serverless) ve tamamen bağımsız (**decoupled**) bir API mimarisine sahiptir. Backend mantığının tamamı TypeScript ve Deno runtime'ı üzerinde çalışan **Supabase Edge Functions** kullanılarak yazılmıştır.

Supabase CLI standartları gereği, asıl backend kodları projenin kök dizinindeki [`/supabase/functions`](../supabase/functions) klasöründe yer almaktadır.

### Klasör Yapısı & Endpoint'ler
*   [`/supabase/functions/auth`](../supabase/functions/auth) - Google Sign-In doğrulama ve kullanıcı senkronizasyon API'si.
*   [`/supabase/functions/scenarios`](../supabase/functions/scenarios) - Özel senaryo ekleme ve hazır şablonları çekme API'si.
*   [`/supabase/functions/sessions`](../supabase/functions/sessions) - AI simülasyon odası, stres/duygu durum hesaplama motoru ve canlı mentor ipucu API'si.
*   [`/supabase/functions/analyses`](../supabase/functions/analyses) - Prova sonu empati, netlik, kararlılık metriklerini hesaplayan yapay zeka analiz API'si.

---

## 🛠️ Yerel Çalıştırma (Development)

Backend fonksiyonlarını yerel ortamınızda test etmek için öncelikle projenin kök dizininde veya bu dizinde bir `.env.local` oluşturup gerekli API anahtarlarını girmelisiniz.

Daha sonra bu dizinde (`/backend`) aşağıdaki komutları kullanabilirsiniz:

```bash
# Bağımlılıkları yükleyin
npm install

# Yerel Edge Function sunucusunu başlatın
npm run dev
```

Bu komut, yerel fonksiyonları `http://127.0.0.1:54321/functions/v1/` adresi altında dinlemeye başlar.

---

## 🚀 Canlıya Alma (Deployment)

Supabase Edge Function'ları canlıya göndermek için:

```bash
# Tüm fonksiyonları Supabase Cloud üzerine deploy eder
npm run deploy
```
