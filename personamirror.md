# TEKNİK ÜRÜN GEREKSİNİM DÖKÜMANI (TECH PRD)

**Proje Adı:** Persona Mirror  
**Aşama:** Faz 1 - MVP (Minimum Uygulanabilir Ürün)  
**Platform:** React / Next.js + Flutter (iOS & Android)  
**Hazırlayan:** Elif AY  
**Durum:** Taslak  

---

## 1. Ürün Vizyonu ve İş Hedefleri

Empati ve Müzakere Simülatörü, kullanıcıların hayatlarındaki zor konuşmaları — zam görüşmeleri, aile içi çatışmalar, sınır koyma anları — gerçek hayata geçirmeden önce yapay zeka ile güvenli bir ortamda prova etmelerine olanak tanıyan bir uygulamadır.

- **Kuzey Yıldızı Metriği:** Tamamlanan simülasyon oturumu sayısı.
- **Viralite Metriği:** Kullanıcı başına paylaşılan "Analiz Raporu" sayısı (Örn: "Empati Skorum: 7/10").

---

## 2. Teknoloji Yığını (Tech Stack) & Mimari

| Katman | Teknoloji | Gerekçe |
|---|---|---|
| **Web İstemci** | React / Next.js | SSR desteği, API Routes ile ayrı backend ihtiyacını azaltır, SEO ve paylaşım |
| **Mobil İstemci** | Flutter (iOS + Android) | Tek kod tabanı ile her iki platforma native deneyim |
| **Backend (API)** | Next.js API Routes | Claude API ve Supabase için proxy; gerekirse FastAPI'ye taşınabilir |
| **LLM Entegrasyonu** | Anthropic Claude API | Sistem prompt kontrolü, karakter canlandırma |
| **Veritabanı** | Supabase (PostgreSQL) | Gerçek zamanlı veri, auth desteği |
| **Dosya Depolama** | Supabase Storage | Paylaşılabilir analiz raporu görselleri |
| **Sunucu & Dağıtım (Web)** | Vercel | Next.js için optimize, edge functions desteği |
| **Sunucu & Dağıtım (Mobil)** | Firebase App Distribution | iOS & Android beta dağıtımı |

---

## 3. Veritabanı Şeması (Supabase / PostgreSQL)

| Tablo | Sütun | Veri Tipi | Özellikler / Kısıtlamalar | Açıklama |
|---|---|---|---|---|
| **users** | id | UUID | Primary Key, Auto-gen | Kullanıcının eşsiz kimliği |
| | google_sub_id | VARCHAR | Unique, Nullable | Google Sign-in ID |
| | email | VARCHAR | Unique, Nullable | Kullanıcı emaili |
| | created_at | TIMESTAMPTZ | Default: NOW() | Kayıt tarihi |
| **scenarios** | id | UUID | Primary Key, Auto-gen | Senaryo ID'si |
| | user_id | UUID | Foreign Key -> users(id) | Hangi kullanıcıya ait |
| | title | VARCHAR(100) | Not Null | Kısa başlık (Örn: "Patronumla zam görüşmesi") |
| | context | TEXT | Not Null | Kullanıcının tanımladığı bağlam (karşı tarafın özellikleri dahil) |
| | category | VARCHAR(50) | Not Null | "İş Hayatı", "Aile", "Arkadaşlık", "Romantik", "Diğer" |
| | created_at | TIMESTAMPTZ | Default: NOW() | Oluşturulma tarihi |
| **sessions** | id | UUID | Primary Key, Auto-gen | Simülasyon oturumu ID'si |
| | scenario_id | UUID | Foreign Key -> scenarios(id) | Hangi senaryoya ait |
| | user_id | UUID | Foreign Key -> users(id) | Oturumu başlatan kullanıcı |
| | status | VARCHAR(20) | Default: 'active' | "active", "completed", "abandoned" |
| | started_at | TIMESTAMPTZ | Default: NOW() | Başlangıç zamanı |
| | ended_at | TIMESTAMPTZ | Nullable | Bitiş zamanı |
| **messages** | id | UUID | Primary Key, Auto-gen | Mesaj ID'si |
| | session_id | UUID | Foreign Key -> sessions(id) | Hangi oturuma ait |
| | role | VARCHAR(10) | Not Null | "user" veya "assistant" |
| | content | TEXT | Not Null | Mesajın içeriği |
| | created_at | TIMESTAMPTZ | Default: NOW() | Gönderilme zamanı |
| **analyses** | id | UUID | Primary Key, Auto-gen | Analiz raporu ID'si |
| | session_id | UUID | Foreign Key -> sessions(id) | Hangi oturuma ait (1-1 ilişki) |
| | empathy_score | INT | Not Null (1-10) | AI'ın verdiği empati skoru |
| | clarity_score | INT | Not Null (1-10) | İfade netliği skoru |
| | assertiveness_score | INT | Not Null (1-10) | Kararlılık skoru |
| | summary | TEXT | Not Null | Genel değerlendirme metni |
| | strengths | TEXT[] | Nullable | İyi yapılan şeyler (array) |
| | improvements | TEXT[] | Nullable | Geliştirilebilecek alanlar (array) |
| | alternative_lines | TEXT[] | Nullable | "Şunu da diyebilirdin" önerileri |
| | share_image_url | TEXT | Nullable | Supabase Storage'daki paylaşım görseli URL'i |
| | created_at | TIMESTAMPTZ | Default: NOW() | Rapor oluşturulma tarihi |

---

## 4. API Uç Noktaları (Next.js API Routes - REST/JSON)

### Auth

**POST /api/v1/auth/google**
- **Payload:** `{ "id_token": "string" }`
- **İşlem:** Google token doğrulanır; Supabase'de kullanıcı yoksa yaratılır, varsa getirilir. Sisteme özel JWT (Access Token) döner.

### Senaryolar

**GET /api/v1/scenarios**
- **İşlem:** JWT'den tespit edilen kullanıcının senaryolarını listeler.

**POST /api/v1/scenarios**
- **Payload:** `{ "title": "string", "context": "string", "category": "string" }`
- **İşlem:** Yeni senaryo oluşturur; scenario_id döner.

### Simülasyon Oturumu

**POST /api/v1/sessions**
- **Payload:** `{ "scenario_id": "uuid" }`
- **İşlem:** Yeni oturum oluşturur. AI karakter için sistem promptu burada hazırlanır (scenario.context kullanılarak). session_id ve ilk AI mesajı döner.

**POST /api/v1/sessions/{session_id}/message**
- **Payload:** `{ "content": "string" }`
- **İşlem:**
  1. Kullanıcı mesajı messages tablosuna yazılır.
  2. Tüm oturum geçmişi (messages) Claude API'ye gönderilir. Sistem promptunda AI'ın canlandırdığı karakter ve tutum tanımı bulunur.
  3. Claude'un yanıtı messages tablosuna yazılır ve kullanıcıya döner.

**PATCH /api/v1/sessions/{session_id}/end**
- **İşlem:** Oturumu "completed" olarak işaretler; otomatik olarak /analyse endpoint'ini tetikler.

### Analiz

**POST /api/v1/sessions/{session_id}/analyse**
- **İşlem:**
  1. Tüm oturum mesajları tek bir prompt olarak Claude'a gönderilir.
  2. Claude; empathy_score, clarity_score, assertiveness_score, summary, strengths, improvements, alternative_lines alanlarını **yalnızca JSON** olarak döner.
  3. Sonuç analyses tablosuna yazılır; paylaşım görseli arka planda render edilerek Supabase Storage'a yüklenir.
  4. Analiz objesi kullanıcıya döner.

**GET /api/v1/sessions/{session_id}/analyse**
- **İşlem:** Daha önce oluşturulmuş analiz raporunu getirir.

### Kürasyon

**GET /api/v1/scenarios/templates**
- **İşlem:** Hazır senaryo şablonlarını listeler (Örn: "Zam İste", "İlişkiyi Bitir", "Sınır Koy").

---

## 5. Yapay Zeka Sistem Prompt Mimarisi

Uygulamanın kalbi sistem promptu tasarımıdır. Karakter canlandırma iki katmandan oluşur:

**Katman 1 — Sabit Çekirdek Prompt (Her oturumda değişmez):**

> Sen bir rol yapma simülatöründe kullanıcının gerçek hayatta yapacağı zor bir konuşmayı pratik etmesine yardımcı olan bir yapay zekasın. Karşı tarafı gerçekçi, insan gibi ve hafifçe dirençli canlandır. Cevaplarını kısa ve doğal tut — gerçek bir insan gibi konuş. Kullanıcıya yardımcı olmak için konuşmayı kolaylaştırma; gerçek hayatta karşılaşabileceği tepkileri ver.

**Katman 2 — Dinamik Karakter Prompt (scenario.context'ten üretilir):**

> Bu senaryoda şu kişiyi canlandırıyorsun: [context]. Adın [ad/unvan]. Tutumun [dirençli/soğuk/aceleci/savunmacı vb.].

**Analiz Promptu:**

> Aşağıdaki konuşmayı analiz et. Kullanıcının empati, netlik ve kararlılık becerilerini 1-10 arası puanla. Güçlü yanlarını ve gelişim alanlarını listele. Alternatif ifadeler öner. **Yalnızca JSON döndür**, başka hiçbir şey yazma.

---

## 6. Ekranlar ve Kullanıcı Akışı (UI/UX)

Arayüz tasarımı; gereksiz konturlardan arındırılmış, modern "glassmorphism" (buzlu cam) efektleri ve minimalist, tipografi odaklı bir yapıya sahip olacaktır. Renk paleti; güveni çağrıştıran derin lacivert ve yumuşak krem tonları üzerine kuruludur.

### 1. Splash & Login Ekranı
- Temiz, koyu/açık mod desteğine sahip arka plan. Ortada uygulama logosu ve kısa tagline: *"Zor konuşmaları prova et."*
- Alt kısımda: **Google ile Giriş** butonu.

### 2. Ana Ekran (Dashboard)
- **Üst kısım:** Kullanıcı selamı ("Merhaba, [İsim]") ve sağ üstte profil ikonu.
- **Hazır Şablonlar (Quick Start):** Yatayda kaydırılabilir, kart tasarımlı senaryolar — "Zam İste", "Sınır Koy", "Zor Haberi Ver".
- **Geçmiş Oturumlar:** Kullanıcının daha önce yaptığı simülasyonlar (başlık + tarih + ortalama skor).
- **FAB:** "+ Yeni Senaryo" butonu.

### 3. Senaryo Tanımlama Ekranı
- **Kategori Seçimi:** Chip/badge tarzı seçenekler (İş, Aile, Arkadaşlık, Romantik, Diğer).
- **Bağlam Formu:**
  - *"Bu konuşmada ne istiyorsun?"* — TextField
  - *"Karşı taraf kimdir ve nasıl biri?"* — TextField
- **"Simülasyona Başla"** butonu.

### 4. Simülasyon Ekranı (Chat)
- Mesaj balonları: Kullanıcı sağda (koyu), AI karakteri solda (açık/glassmorphic).
- Üstte: Karakter adı ve avatarı (Örn: "Ahmet Bey — Patronun").
- Altta: Metin girişi + "Gönder" butonu.
- Sağ üstte: **"Oturumu Bitir & Analizi Al"** butonu.

### 5. Analiz Raporu Ekranı
- Bottom Sheet veya tam sayfa modal.
- **Skor Kartı:** Empati, Netlik, Kararlılık — animasyonlu dairesel göstergeler.
- **Metin Bölümleri:** "Güçlü Yanların", "Gelişim Alanların", "Şunu da Diyebilirdin".
- **Paylaşım Butonu:** "Bu Analizi Paylaş" — platform paylaşım sheet'i.

---

## 7. User Stories & Acceptance Criteria (Backlog)

### EPIC 1: Kimlik Doğrulama

**US 1.1 — Google ile Giriş**
- **Hikaye:** Şifre yaratmak zorunda kalmadan Google Hesabımla giriş yapmak istiyorum.
- **Given:** Kullanıcı uygulamayı ilk kez açmıştır.
- **When:** "Google ile Giriş" butonuna basıp hesabını seçerse;
- **Then:** Token doğrulanmalı, Supabase'de yoksa kayıt oluşturulmalıdır.
- **And:** Kullanıcıya JWT verilmeli ve Ana Ekrana yönlendirilmelidir.
- **Hata Durumu:** İnternet yoksa kullanıcıya uyarı gösterilmelidir.

---

### EPIC 2: Senaryo ve Simülasyon

**US 2.1 — Yeni Senaryo Tanımlama**
- **Hikaye:** Yarın patronumla zam konuşması yapacağım; bu konuşmayı önceden prova etmek istiyorum.
- **Given:** Kullanıcı Ana Ekran'dadır ve "+" butonuna basmıştır.
- **When:** Kategori seçip bağlam formunu doldurup "Simülasyona Başla" butonuna basarsa;
- **Then:** Senaryo oluşturulmalı, ardından oturum açılmalıdır.
- **And:** AI'ın ilk mesajı ekranda görünmelidir.
- **Hata Durumu:** Bağlam alanı boşsa "Lütfen konuşmanın bağlamını açıkla" inline hata metni gösterilmelidir.

**US 2.2 — Gerçek Zamanlı Simülasyon**
- **Hikaye:** AI ile dönüşümlü konuşarak zor konuşmayı prova etmek istiyorum.
- **Given:** Simülasyon oturumu aktiftir.
- **When:** Kullanıcı mesaj yazıp gönderirse;
- **Then:** Mesaj anında görünmeli, typing indicator gösterilmeli, AI yanıtı max 5 saniye içinde ekranda olmalıdır.
- **And:** AI yanıtları robotik değil, insan gibi ve senaryoya uygun dirençli/gerçekçi olmalıdır.

---

### EPIC 3: Analiz ve Paylaşım

**US 3.1 — Oturum Sonu Analiz Raporu**
- **Hikaye:** Simülasyonu bitirdiğimde ne kadar iyi performans gösterdiğimi görmek istiyorum.
- **Given:** Kullanıcı "Oturumu Bitir & Analizi Al" butonuna basmıştır.
- **When:** Backend tüm konuşmayı analiz edip sonucu döndüğünde;
- **Then:** Analiz Raporu ekranı açılmalı; empati, netlik ve kararlılık skorları animasyonlu şekilde gösterilmelidir.
- **And:** Güçlü yanlar, gelişim alanları ve alternatif ifadeler metin olarak listelenmeli.
- **Hata Durumu:** Analiz yüklenemezse "Rapor hazırlanamadı, tekrar dene" mesajı gösterilmelidir.

**US 3.2 — Analiz Raporunu Paylaşma**
- **Hikaye:** "Empati Skorum: 7/10" sonucumu arkadaşlarımla paylaşmak istiyorum.
- **Given:** Analiz Raporu ekranı açıktır.
- **When:** Kullanıcı "Bu Analizi Paylaş" butonuna basarsa;
- **Then:** Analiz kartı görsel olarak render edilmeli.
- **And:** Platform paylaşım sheet'i açılmalı; Instagram, WhatsApp ve diğer paylaşım seçenekleri gösterilmelidir.

---

## 8. Kapsam Dışı (Out of Scope — Faz 1)

- Sesli konuşma modu (Voice simulation).
- Çoklu kullanıcı / eş zamanlı rol yapma (iki gerçek kullanıcı).
- Terapist veya koç eşleştirme altyapısı.
- Herhangi bir ödeme sistemi (In-App Purchase, Premium üyelik).
- Gelişmiş analitik paneli (haftalık/aylık gelişim grafikleri).
- Bildirim sistemi (hatırlatıcılar, streak takibi).