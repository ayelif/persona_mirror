# TEKNİK ÜRÜN GEREKSİNİM DÖKÜMANI (TECH PRD)

**Proje Adı:** Persona Mirror  
**Aşama:** Faz 1 - MVP (Minimum Uygulanabilir Ürün)  
**Platform:** Flutter (iOS & Android)  
**Hazırlayan:** Elif AY  
**Durum:** Güncel (Mobil Odaklı)

---

## 1. Ürün Vizyonu ve İş Hedefleri

Empati ve Müzakere Simülatörü, kullanıcıların hayatlarındaki zor konuşmaları — zam görüşmeleri, aile içi çatışmalar, sınır koyma anları — gerçek hayata geçirmeden önce yapay zeka ile güvenli bir ortamda prova etmelerine olanak tanıyan bir uygulamadır.

- **Kuzey Yıldızı Metriği:** Tamamlanan simülasyon oturumu sayısı.
- **Viralite Metriği:** Kullanıcı başına paylaşılan "Analiz Raporu" sayısı (Örn: "Empati Skorum: 7/10").

---

## 2. Teknoloji Yığını (Tech Stack) & Mimari

| Katman | Teknoloji | Gerekçe |
|---|---|---|
| **Mobil İstemci** | Flutter (iOS + Android) | Tek kod tabanı ile her iki platforma native deneyim, hızlı UI iterasyonu |
| **Backend (BaaS)** | Supabase | Auth, PostgreSQL, Storage ve Edge Functions ile hepsi bir arada çözüm |
| **Logic (Backend)** | Supabase Edge Functions | Claude API proxy ve analiz mantığı (TypeScript/Deno) |
| **LLM Entegrasyonu** | Anthropic Claude API | Üstün sistem prompt kontrolü, nüanslı karakter canlandırma |
| **Veritabanı** | PostgreSQL (Supabase) | İlişkisel veri, RLS (Row Level Security) ile güvenlik |
| **Dosya Depolama** | Supabase Storage | Analiz raporu görselleri ve kullanıcı avatarları |
| **Dağıtım (Mobil)** | Firebase App Distribution | iOS & Android beta dağıtımı ve test süreci |

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
| | context | TEXT | Not Null | Kullanıcının tanımladığı bağlam |
| | category | VARCHAR(50) | Not Null | "İş Dünyası", "Aile", "İlişkiler", "Sosyal", "Diğer" |
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
| | session_id | UUID | Foreign Key -> sessions(id) | Hangi oturuma ait |
| | empathy_score | INT | Not Null (1-10) | Empati skoru |
| | clarity_score | INT | Not Null (1-10) | Netlik skoru |
| | assertiveness_score | INT | Not Null (1-10) | Kararlılık skoru |
| | summary | TEXT | Not Null | Genel değerlendirme |
| | strengths | TEXT[] | Nullable | Güçlü yanlar |
| | improvements | TEXT[] | Nullable | Gelişim alanları |
| | alternative_lines | TEXT[] | Nullable | Alternatif öneriler |
| | created_at | TIMESTAMPTZ | Default: NOW() | Rapor tarihi |

---

## 4. API & Backend Servisleri (Supabase Edge Functions)

Uygulama, doğrudan Supabase client'ı üzerinden DB ve Auth işlemlerini yaparken, LLM entegrasyonu için Edge Functions kullanır.

### Chat & Simulation
**Edge Function: `process-chat`**
- **Payload:** `{ "session_id": "uuid", "message": "string" }`
- **İşlem:** 
  1. Mesajı DB'ye kaydeder.
  2. Claude API'ye geçmişle birlikte gönderir.
  3. Yanıtı DB'ye yazar ve mobil uygulamaya döner.

### Analysis
**Edge Function: `generate-analysis`**
- **Payload:** `{ "session_id": "uuid" }`
- **İşlem:**
  1. Oturumdaki tüm mesajları çeker.
  2. Claude'dan JSON formatında analiz talep eder.
  3. `analyses` tablosuna kaydeder.
  4. Paylaşılabilir bir özet görseli tetikler (isteğe bağlı).

---

## 5. Yapay Zeka Sistem Prompt Mimarisi

**Karakter Canlandırma (Chat Prompt):**
> Sen profesyonel bir rol yapma simülatörüsün. Kullanıcının tanımladığı senaryoya göre [karakter] rolünü canlandırıyorsun. Cevaplarını kısa, doğal ve insan gibi tut. Kullanıcıya her zaman hak verme; gerçekçi bir direnç ve karakter tutarlılığı sergile.

**Değerlendirme (Analysis Prompt):**
> Aşağıdaki konuşmayı Empati, Netlik ve Kararlılık açılarından analiz et. Puanları 1-10 arası ver. Kullanıcıya somut gelişim önerileri ve alternatif cümleler sun. Yanıtını yalnızca JSON olarak ver.

---

## 6. Mobil Ekranlar ve Kullanıcı Akışı (Flutter UI)

Tasarım dili: **Soft & Professional**. Krem, violet ve teal tonları ile modern, güven veren bir yapı.

1. **Splash & Login:** Google Sign-in odaklı, minimalist giriş.
2. **Dashboard (Ana Ekran):** 
   - Hızlı Başlat kartları (İş, İlişkiler, Topluluk).
   - Geçmiş oturumların listesi.
   - Duygusal gelişim takibi (Duygu-Durum Analizi).
3. **Senaryo Tanımlama:** Kategori seçimi ve bağlam girişi.
4. **Simülasyon (Chat):** Akıcı, chat baloncukları ve karakter bilgisi içeren dinamik ekran.
5. **Analiz Raporu:** Puanların ve detaylı geri bildirimlerin yer aldığı görsel odaklı rapor sayfası.

---

## 7. Kullanıcı Hikayeleri (Özet)

- **Kimlik:** "Google hesabımla hızlıca giriş yapmak ve geçmişime her cihazdan erişmek istiyorum."
- **Simülasyon:** "Zor bir konuşmayı yapay zeka ile prova edip, karşı tarafın verebileceği gerçekçi tepkileri görmek istiyorum."
- **Analiz:** "Konuşma sonrasında nerede hata yaptığımı ve kendimi nasıl geliştirebileceğimi net skorlarla görmek istiyorum."

---

## 8. Kapsam Dışı (Out of Scope — Faz 1)

- Web platformu desteği (Tamamen mobil odaklı).
- Sesli simülasyon (Voice-to-text / Text-to-speech).
- Çoklu kullanıcı (Multiplayer) modu.
- Gelişmiş ödeme sistemleri.
- Topluluk paylaşımları (Community Feed).
- Terapist veya koç eşleştirme altyapısı.
- Bildirim sistemi (hatırlatıcılar, streak takibi).