# 📅 Geliştirme Planı (Plan.md)

**Proje:** Persona Mirror  
**Metodoloji:** Kullanıcı Hikayesi Odaklı Çevik Planlama (User Story-Driven Agile Plan)

---

## US-1: Google ile Kimlik Doğrulama & Oturum Yönetimi

> **Kullanıcı Hikayesi:**  
> *"Bir kullanıcı olarak, uygulamaya Google hesabımla güvenli ve şifresiz bir şekilde giriş yapabilmek, oturumumun açık kalmasını ve geçmiş verilerimin her cihazda senkronize olmasını istiyorum."*

### 🛠 Teknik Adımlar:
1. **Veritabanı Kurulumu (Backend):**
   - `users` tablosunu oluştur (`id`, `google_sub_id`, `email`, `created_at`).
   - Row Level Security (RLS) politikalarını aktif et.
2. **Google Auth Endpoint (Backend):**
   - `POST /api/v1/auth/google` endpoint'inin TypeScript Deno ile yazılması.
   - Google `id_token` doğrulama entegrasyonu.
   - Kullanıcı mevcutsa verisinin getirilmesi, ilk kez giriyorsa otomatik kayıt (`upsert`).
3. **Auth Servisi & Riverpod (Frontend):**
   - `google_sign_in` ve `supabase_flutter` paketlerinin entegrasyonu.
   - `AuthRepository` ve `authProvider` (Riverpod notifier) yazılması.
4. ** Splash & Login Ekranları (Frontend):**
   - Splash ekranında otomatik session kontrolü.
   - Giriş ekranında premium, minimalist, koyu lacivert temalı Google Sign-in butonu.

---

## US-2: Senaryo Oluşturma & Şablon Keşfi

> **Kullanıcı Hikayesi:**  
> *"Bir kullanıcı olarak, pratik yapmak istediğim konuşmaya göre kendi özel senaryomu (karşımdaki kim, durum ne) yazabilmek veya en sık karşılaşılan hazır şablonlardan birini seçerek hızlıca başlamak istiyorum."*

### 🛠 Teknik Adımlar:
1. **Senaryo CRUD API (Backend):**
   - `scenarios` tablosunu veritabanında oluştur (`id`, `user_id`, `title`, `context`, `category`).
   - `GET /api/v1/scenarios` (Kullanıcının geçmiş senaryoları).
   - `POST /api/v1/scenarios` (Yeni senaryo kaydetme).
   - `GET /api/v1/scenarios/templates` (İş, İlişki, Aile şablonları listesi).
2. **Dashboard Arayüzü (Frontend):**
   - Glassmorphic şablon kartlarının yatay listelenmesi.
   - Geçmiş oturumların alt alta listelenmesi (ortalama performans skorlarıyla).
3. **Senaryo Oluşturma Formu (Frontend):**
   - Kategori seçimi için dinamik `ChoiceChip` listesi.
   - Başlık ve detaylı karakter bağlamı için multiline `TextField` girişleri.
   - Boş veri kontrolü ve buton loading animasyonları.

---

## US-3: AI ile Rol Yapma & Simülasyon Odası

> **Kullanıcı Hikayesi:**  
> *"Bir kullanıcı olarak, seçtiğim zorluk derecesine göre (kolay/orta/zor) AI karakteriyle doğal, samimi bir dille mesajlaşabilmek, onun duygularını ve stres durumunu görebilmek ve tıkandığım anlarda mentor ipucu alabilmek istiyorum."*

### 🛠 Teknik Adımlar:
1. **Simülasyon & Mesaj API (Backend):**
   - `sessions` ve `messages` tablolarının oluşturulması.
   - `POST /api/v1/sessions` (Senaryo ve zorluk seçimiyle yeni simülasyon başlatma).
   - `POST /api/v1/sessions/{id}/message` (Kullanıcı mesajını alıp geçmişle birlikte LLM'e gönderme).
2. **Dinamik Sistem Prompt Tasarımı (Backend/LLM):**
   - Karakterin yapay zekavari dilden uzaklaşıp günlük Türkçe (`colloquial`) ünlem ve duraksamalarla konuşmasının sağlanması.
   - LLM'in her mesajda `reply`, `mood` ve `stress_level` içeren bir JSON dönmesinin zorunlu kılınması.
   - Gemini 2.5 Flash ve Groq Llama 3.3 entegrasyonlarının ve fallback mimarisinin kodlanması.
3. **Canlı Mentor İpucu Entegrasyonu (Backend/LLM):**
   - `POST /api/v1/sessions/{id}/hint` endpoint'i. Konuşma geçmişine göre kullanıcıya bir tüyo ve örnek cümle sunulması.
4. **Chat Ekranı Arayüzü (Frontend):**
   - Mesajlaşma baloncukları (kullanıcı sağda, AI solda modern cam efektiyle).
   - AI'ın o anki ruh halini gösteren emoji indikatörü (`neutral`, `defensive`, `frustrated` vb.).
   - AI yazarken aktif olan animasyonlu `TypingIndicator` ve "İpucu Al" butonu.

---

## US-4: Yapay Zeka Destekli İletişim Analizi & Raporlama

> **Kullanıcı Hikayesi:**  
> *"Bir kullanıcı olarak, simülasyonu bitirdiğimde konuşmadaki performansımı Empati, Netlik ve Kararlılık açılarından nesnel puanlarla görmek, güçlü yönlerimi, hatalarımı ve söylenebilecek ideal cümleleri inceleyerek kendimi geliştirmek istiyorum."*

### 🛠 Teknik Adımlar:
1. **Analiz Analiz API (Backend/LLM):**
   - `analyses` tablosunun veritabanında oluşturulması (`session_id`, `empathy_score`, `clarity_score`, `assertiveness_score`, `summary`, `strengths`, `improvements`, `alternative_lines`).
   - `POST /api/v1/sessions/{id}/analyse` (Geçmiş mesajları analiz edip skor ve önerileri içeren JSON çıktısını DB'ye kaydetme).
2. **Analiz Ekranı Arayüzü (Frontend):**
   - `CustomPainter` veya grafik kütüphaneleriyle sıfırdan skor değerine doğru dönerek animasyon yapan 3 adet dairesel gösterge.
   - Güçlü yanlar (yeşil/mavi), gelişim alanları (mor) ve alternatif cümleler (krem) için premium glassmorphism kart tasarımları.
3. **Paylaşım Entegrasyonu (Frontend):**
   - `RepaintBoundary` ile analiz kartının görüntüsünü yakalayıp native paylaşım paneliyle (`share_plus`) paylaşılabilir kılma.
