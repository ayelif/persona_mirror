# 🧠 Persona Mirror

**Zor konuşmaları prova et, yapay zeka ile kendini ayna gibi gör.**  
Persona Mirror, sosyal ve profesyonel hayatınızdaki zorlu konuşmaları simüle etmenize ve yapay zeka desteğiyle geri bildirim alarak gelişmenize yardımcı olan bir mobil uygulamadır.

---

---

## 🚀 Özellikler

- **AI Simülasyonu**: Gerçekçi persona'lar (Patron, Eş, Müşteri vb.) ile dinamik chat.
- **Detaylı Analiz**: Konuşma sonrası Empati, Netlik ve Kararlılık metrikleri.
- **Senaryo Keşfi**: Farklı hayat senaryoları için hazır şablonlar.
- **Gelişim Takibi**: Geçmiş provaların ve skorların takibi.
- **Premium Tasarım**: Modern, yumuşak ve kullanıcı dostu arayüz.

---

## 🛠 Teknoloji Yığını

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (Edge Functions, Auth, PostgreSQL)
- **AI**: Anthropic Claude API (LLM)
- **Tasarım**: Modern Soft UI & Glassmorphism

---

## 🏗 Proje Yapısı & Zorunlu Dokümantasyon

Proje, gereksinim duyulan modüler yapıyı ve geliştirme referans dökümanlarını eksiksiz şekilde barındırmaktadır:

- **`/frontend`**: Flutter (Dart) mobil uygulaması arayüz ve istemci kodları.
- **`/backend`**: Supabase Edge Functions (Deno & TypeScript) API kodları.
- **`/supabase`**: PostgreSQL veritabanı şeması, RLS politikaları ve migrations klasörü.
- **`/prodocs`**: Yapay zeka ajanları ve proje kabul jürisi için hazırlanan **Zorunlu Geliştirme Referans Dosyaları**:
  - [📄 PRD.md](./prodocs/PRD.md) — Çözülen problem, hedef kullanıcı ve özellik yol haritası.
  - [📄 tech-stack.md](./prodocs/tech-stack.md) — Teknoloji seçimleri, API mimarisi ve AI entegrasyonu.
  - [📄 Plan.md](./prodocs/Plan.md) — PRD'den türetilen, kullanıcı hikayelerine bölünmüş teknik adımlar.
  - [📄 DesignSystem.md](./prodocs/DesignSystem.md) — Soft & Professional renk paleti, tipografi ve component kuralları.
  - [📄 Progress.md](./prodocs/Progress.md) — Geliştirme günlüğü, alınan kararlar ve çözülen hatalar listesi.

---

## 🏁 Başlangıç

### Mobil Uygulamayı Çalıştırın
```bash
cd frontend
flutter pub get
flutter run
```

### Backend Yapılandırması
1. `backend/.env.local` dosyasını oluşturun.
2. Gerekli anahtarları (`ANTHROPIC_API_KEY`, `SUPABASE_URL` vb.) ekleyin.
3. Supabase CLI ile fonksiyonları deploy edin.

---
*Developed with ❤️ for personal growth.*
