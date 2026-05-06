# Persona Mirror — plan.md
> LLM tüketimi için yapılandırılmış geliştirme planı.  
> Stack: Flutter (mobile) · Supabase Edge Functions (backend) · Claude API (AI)  
> Proje dizini: `persona_mirror/`

---

## Proje Yapısı (Hedef)

```
persona_mirror/
├── backend/          ← Supabase Edge Functions (Deno/TypeScript)
│   └── src/
│       ├── functions/
│       │   ├── auth/
│       │   ├── scenarios/
│       │   ├── sessions/
│       │   └── analyses/
│       └── _shared/   ← ortak yardımcılar (cors, jwt, supabase client)
├── frontend/         ← Flutter uygulaması
│   └── lib/
│       ├── core/      ← theme, router, constants, di
│       └── features/  ← auth, dashboard, scenario, simulation, analysis
├── shared/           ← ortak kontratlar/şemalar
├── supabase/
│   └── migrations/
│       └── 20260422_000001_init.sql
└── plan.md
```

---

## FAZA 0 — Altyapı Kurulumu

### Adım 0.1 — Backend (Supabase Edge Functions) iskeleti
**Dizin:** `backend/`  
**Yapılacaklar:**
- `backend/src/functions/` altında her endpoint için klasör oluştur
- `backend/src/_shared/cors.ts` → CORS başlıkları
- `backend/src/_shared/supabaseClient.ts` → `SUPABASE_URL` + `SUPABASE_SERVICE_ROLE_KEY` ile admin client
- `backend/src/_shared/jwtVerify.ts` → Authorization header'ından Bearer token parse/doğrula
- `backend/.env.example` dosyasına şu değişkenleri ekle:
  ```
  SUPABASE_URL=
  SUPABASE_SERVICE_ROLE_KEY=
  ANTHROPIC_API_KEY=
  ```
- `backend/package.json` → Deno projesi için betikler (deploy, serve)

**Başarı Kriteri:** `supabase functions serve` komutu çalışır, `/health` endpoint 200 döner.

---

### Adım 0.2 — Veritabanı Migrasyonu
**Dizin:** `supabase/migrations/`  
**Dosya:** `20260422_000001_init.sql` (zaten var, kontrol et)  
**Tablo listesi (hepsi mevcut olmalı):**

```sql
-- users
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  google_sub_id VARCHAR UNIQUE,
  email VARCHAR UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- scenarios
CREATE TABLE scenarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(100) NOT NULL,
  context TEXT NOT NULL,
  category VARCHAR(50) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- sessions
CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scenario_id UUID REFERENCES scenarios(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  status VARCHAR(20) DEFAULT 'active',
  started_at TIMESTAMPTZ DEFAULT NOW(),
  ended_at TIMESTAMPTZ
);

-- messages
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
  role VARCHAR(10) NOT NULL CHECK (role IN ('user', 'assistant')),
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- analyses
CREATE TABLE analyses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID UNIQUE REFERENCES sessions(id) ON DELETE CASCADE,
  empathy_score INT NOT NULL CHECK (empathy_score BETWEEN 1 AND 10),
  clarity_score INT NOT NULL CHECK (clarity_score BETWEEN 1 AND 10),
  assertiveness_score INT NOT NULL CHECK (assertiveness_score BETWEEN 1 AND 10),
  summary TEXT NOT NULL,
  strengths TEXT[],
  improvements TEXT[],
  alternative_lines TEXT[],
  share_image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Row Level Security (RLS):**
- Her tabloda `user_id = auth.uid()` politikası ekle
- `analyses` → `session_id`'nin `user_id`'si eşleşenler görür

**Başarı Kriteri:** `supabase db push` hatasız çalışır, Supabase Studio'da tablolar görünür.

---

### Adım 0.3 — Flutter projesi temel kurulumu
**Dizin:** `frontend/`  
**Yapılacaklar:**

1. `pubspec.yaml`'a bağımlılıkları ekle:
   ```yaml
   dependencies:
     supabase_flutter: ^2.x
     google_sign_in: ^6.x
     flutter_riverpod: ^2.x
     riverpod_annotation: ^2.x
     go_router: ^13.x
     dio: ^5.x
     freezed_annotation: ^2.x
     json_annotation: ^4.x
   
   dev_dependencies:
     build_runner: ^2.x
     freezed: ^2.x
     json_serializable: ^6.x
     riverpod_generator: ^2.x
   ```

2. `lib/` altında klasör yapısı:
   ```
   lib/
   ├── main.dart
   ├── core/
   │   ├── constants/        ← app_constants.dart (API base URL vb.)
   │   ├── theme/            ← app_theme.dart (glassmorphism, lacivert/krem palette)
   │   ├── router/           ← app_router.dart (GoRouter tanımları)
   │   └── di/               ← providers.dart (global Riverpod providers)
   └── features/
       ├── auth/
       ├── dashboard/
       ├── scenario/
       ├── simulation/
       └── analysis/
   ```

3. `main.dart` içinde `Supabase.initialize()` çağrısı yapılmalı (env'den URL ve anon key).

**Başarı Kriteri:** `flutter run` komutu hatasız başlar, beyaz ekran değil Splash ekranı görünür.

---

## FAZA 1 — Auth (Kimlik Doğrulama)

### Adım 1.1 — Backend: Google Auth endpoint
**Dosya:** `backend/src/functions/auth/index.ts`  
**Endpoint:** `POST /api/v1/auth/google`  
**Payload:** `{ "id_token": "string" }`

**İş Mantığı:**
1. `id_token`'ı Google'ın tokeninfo endpoint'ine göndererek doğrula
2. `email` ve `google_sub_id`'yi çıkar
3. Supabase'de `users` tablosunu sorgula (`google_sub_id` eşleşiyor mu?)
   - Varsa: mevcut kullanıcıyı getir
   - Yoksa: yeni kayıt oluştur (`INSERT`)
4. `supabase.auth.admin.generateLink()` veya custom JWT ile token üret
5. `{ access_token, user }` döndür

**Başarı Kriteri:** Postman/curl ile `POST /api/v1/auth/google` çağrıldığında JWT döner.

---

### Adım 1.2 — Flutter: Splash & Login ekranı
**Dizin:** `frontend/lib/features/auth/`  
**Dosyalar:** `splash_screen.dart`, `login_screen.dart`, `auth_repository.dart`, `auth_provider.dart`

**Splash Screen:**
- 2 saniye bekle → Supabase'de aktif session var mı kontrol et
- Varsa → Dashboard'a yönlendir
- Yoksa → Login ekranına yönlendir

**Login Screen UI:**
- Arka plan: derin lacivert (`#0D1B2A`) gradient
- Ortada uygulama adı + tagline: *"Zor konuşmaları prova et."*
- Google Sign-In butonu (beyaz kart, Google logosu)
- İnternet yoksa: SnackBar hata mesajı

**Auth Repository:**
```dart
Future<UserModel> signInWithGoogle() async {
  // 1. google_sign_in paketi ile Google token al
  // 2. apps/backend /api/v1/auth/google endpoint'ine POST at
  // 3. Dönen JWT'yi Supabase session olarak set et
  // 4. UserModel döndür
}
```

**Başarı Kriteri:** Gerçek cihazda Google hesabı seçilince Dashboard'a geçilir.

---

## FAZA 2 — Senaryolar (Scenarios)

### Adım 2.1 — Backend: Senaryo CRUD endpoint'leri
**Dosya:** `backend/src/functions/scenarios/index.ts`

**GET /api/v1/scenarios**
- JWT'den `user_id` çıkar
- `scenarios` tablosunu `user_id` ile filtrele, `created_at DESC` sırala
- `[ScenarioModel]` listesi döndür

**POST /api/v1/scenarios**
- Payload: `{ title, context, category }`
- Validasyon: tüm alanlar zorunlu, `category` enum değerlerinden biri olmalı
- `scenarios` tablosuna `INSERT`
- Yeni oluşturulan `scenario` objesini döndür

**GET /api/v1/scenarios/templates**
- Sabit bir liste döndür (hardcoded veya DB'de ayrı tablo):
  ```json
  [
    { "id": "t1", "title": "Zam İste", "category": "İş Hayatı", "context": "..." },
    { "id": "t2", "title": "Sınır Koy", "category": "Arkadaşlık", "context": "..." },
    { "id": "t3", "title": "İlişkiyi Bitir", "category": "Romantik", "context": "..." }
  ]
  ```

**Başarı Kriteri:** Auth token ile GET çağrısı liste döner, POST yeni senaryo yaratır.

---

### Adım 2.2 — Flutter: Dashboard ekranı
**Dizin:** `frontend/lib/features/dashboard/`

**UI Bileşenleri:**
- `AppBar`: "Merhaba, [İsim]" + sağda profil avatarı
- `HorizontalTemplateList`: yatay kaydırılabilir şablon kartları (Glassmorphic kart)
- `PastSessionsList`: geçmiş oturumlar listesi (başlık + tarih + ort. skor badge)
- `FloatingActionButton`: "+ Yeni Senaryo"

**State (Riverpod):**
```dart
// scenarios_provider.dart
final scenariosProvider = FutureProvider<List<ScenarioModel>>((ref) async {
  return ref.read(scenarioRepositoryProvider).getScenarios();
});
```

**Başarı Kriteri:** Dashboard açıldığında şablonlar ve geçmiş oturumlar yüklenir.

---

### Adım 2.3 — Flutter: Senaryo Tanımlama ekranı
**Dizin:** `frontend/lib/features/scenario/`  
**Dosya:** `create_scenario_screen.dart`

**Form Alanları:**
- Kategori seçimi: `ChoiceChip` listesi (`İş Hayatı`, `Aile`, `Arkadaşlık`, `Romantik`, `Diğer`)
- TextField: *"Bu konuşmada ne istiyorsun?"* (title)
- TextField: *"Karşı taraf kimdir ve nasıl biri?"* (context) — multiline
- "Simülasyona Başla" butonu

**Validasyon:**
- `context` boşsa inline hata: `"Lütfen konuşmanın bağlamını açıkla"`
- Buton loading state (POST sırasında disabled)

**Akış:**
1. Form submit → `POST /api/v1/scenarios`
2. Başarılıysa → `POST /api/v1/sessions` (scenario_id ile)
3. Session açıldıysa → Simulation ekranına `push` (session_id ile)

**Başarı Kriteri:** Form doldurulup buton tıklanınca simulation ekranına geçilir.

---

## FAZA 3 — Simülasyon (Sessions & Messages)

### Adım 3.1 — Backend: Session başlatma
**Dosya:** `backend/src/functions/sessions/index.ts`  
**Endpoint:** `POST /api/v1/sessions`  
**Payload:** `{ "scenario_id": "uuid" }`

**İş Mantığı:**
1. `scenario_id` ile senaryoyu getir (context, title)
2. `sessions` tablosuna `INSERT` (status: 'active')
3. **Sistem promptunu oluştur:**
   ```
   [Sabit Çekirdek Prompt]
   Sen bir rol yapma simülatöründe...
   
   [Dinamik Karakter Prompt]
   Bu senaryoda şu kişiyi canlandırıyorsun: {scenario.context}
   ```
4. Claude API'ye sadece sistem promptu ile ilk mesaj iste
5. Claude'un ilk mesajını `messages` tablosuna `INSERT` (role: 'assistant')
6. `{ session_id, first_message }` döndür

**Başarı Kriteri:** POST çağrısı `session_id` ve AI'nın açılış mesajını döndürür.

---

### Adım 3.2 — Backend: Mesaj gönderme
**Endpoint:** `POST /api/v1/sessions/{session_id}/message`  
**Payload:** `{ "content": "string" }`

**İş Mantığı:**
1. `session_id` geçerli mi ve `status = 'active'` mi kontrol et
2. Kullanıcı mesajını `messages` tablosuna `INSERT` (role: 'user')
3. `messages` tablosundan tüm oturum geçmişini çek (`ORDER BY created_at ASC`)
4. Sistem promptu + tüm geçmişi Claude API'ye gönder
5. Claude yanıtını `messages` tablosuna `INSERT` (role: 'assistant')
6. `{ message: AssistantMessage }` döndür

**Claude API Yapısı:**
```typescript
const response = await anthropic.messages.create({
  model: "claude-opus-4-5",
  max_tokens: 500,
  system: systemPrompt,
  messages: conversationHistory // [{role, content}]
});
```

**Başarı Kriteri:** Mesaj gönderilince AI yanıtı max 5 saniyede döner, DB'ye yazılır.

---

### Adım 3.3 — Backend: Oturum sonlandırma
**Endpoint:** `PATCH /api/v1/sessions/{session_id}/end`

**İş Mantığı:**
1. `sessions` tablosunda `status = 'completed'`, `ended_at = NOW()` güncelle
2. Otomatik olarak analiz tetikle: `POST /api/v1/sessions/{session_id}/analyse` iç çağrı

**Başarı Kriteri:** PATCH çağrısından sonra session status'u "completed" olur.

---

### Adım 3.4 — Flutter: Simulation (Chat) ekranı
**Dizin:** `frontend/lib/features/simulation/`

**UI Bileşenleri:**
- `AppBar`: Karakter adı + avatarı ("Ahmet Bey — Patronun") + "Bitir" butonu
- `MessageList`: ScrollView — kullanıcı mesajları sağda (koyu), AI mesajları solda (glassmorphic)
- `TypingIndicator`: üç nokta animasyonu (AI yanıt beklenirken)
- `MessageInput`: TextField + Gönder butonu

**State (Riverpod):**
```dart
// simulation_provider.dart
class SimulationNotifier extends AsyncNotifier<SimulationState> {
  Future<void> sendMessage(String content) async { ... }
  Future<void> endSession() async { ... }
}
```

**Hata Yönetimi:**
- İnternet yoksa: retry butonu göster
- 5 saniye timeout: "Yanıt alınamadı, tekrar dene"

**Başarı Kriteri:** Mesaj gönderilir, typing indicator görünür, AI yanıtı gelir.

---

## FAZA 4 — Analiz (Analysis)

### Adım 4.1 — Backend: Analiz endpoint'leri
**Dosya:** `backend/src/functions/analyses/index.ts`

**POST /api/v1/sessions/{session_id}/analyse**

**İş Mantığı:**
1. Tüm oturum mesajlarını getir
2. Analiz promptunu oluştur ve Claude'a gönder:
   ```
   Aşağıdaki konuşmayı analiz et. Kullanıcının empati, netlik ve 
   kararlılık becerilerini 1-10 arası puanla. Yalnızca JSON döndür:
   {
     "empathy_score": int,
     "clarity_score": int,
     "assertiveness_score": int,
     "summary": "string",
     "strengths": ["string"],
     "improvements": ["string"],
     "alternative_lines": ["string"]
   }
   ```
3. Claude'dan gelen JSON'ı parse et
4. `analyses` tablosuna `INSERT`
5. Paylaşım görselini arka planda oluştur → Supabase Storage'a yükle → `share_image_url` güncelle
6. Analiz objesini döndür

**GET /api/v1/sessions/{session_id}/analyse**
- `analyses` tablosunu `session_id` ile sorgula, döndür

**Başarı Kriteri:** POST çağrısı JSON analiz objesi döndürür, DB'ye yazılır.

---

### Adım 4.2 — Flutter: Analiz Raporu ekranı
**Dizin:** `frontend/lib/features/analysis/`

**UI Bileşenleri:**
- Animasyonlu dairesel göstergeler (Empati / Netlik / Kararlılık — 1-10)
  - `CustomPainter` veya `circular_chart` paketi
  - Ekran açılınca 0'dan skora doğru animasyon
- Metin bölümleri (glassmorphic kartlar):
  - 💪 "Güçlü Yanların" (strengths listesi)
  - 🎯 "Gelişim Alanların" (improvements listesi)
  - 💬 "Şunu da Diyebilirdin" (alternative_lines listesi)
- "Bu Analizi Paylaş" butonu

**Paylaşım Akışı:**
1. `RepaintBoundary` ile analiz kartını PNG'ye çevir
2. Geçici dosyaya kaydet
3. `share_plus` paketi ile native paylaşım sheet'i aç

**Başarı Kriteri:** Analiz ekranı açılır, skorlar animasyonla gelir, paylaşım çalışır.

---

## FAZA 5 — Stabilizasyon & Beta

### Adım 5.1 — Edge case testleri
- İnternet yoksunluğu → tüm ekranlarda uygun hata mesajı
- JWT süresi dolmuş → otomatik refresh veya login'e yönlendir
- Boş senaryo geçmişi → "Henüz simülasyon yok" boş durum ekranı
- Claude API timeout → kullanıcıya bilgi ver + retry

### Adım 5.2 — UI cilası
- Tüm ekranlarda glassmorphism tutarlılığı
- Sayfa geçiş animasyonları (GoRouter transitions)
- Dark/light mode kontrolü (PRD lacivert/krem palette)

### Adım 5.3 — Firebase App Distribution
- `frontend/` için Firebase projesi bağla
- Android: APK/AAB build → Firebase'e yükle
- iOS: TestFlight veya Firebase ile dağıt
- Test kullanıcı listesi ekle

---

## Kontrol Listesi (LLM için)

Her adımı tamamlarken şunları doğrula:

- [ ] Backend endpoint çalışıyor (curl/Postman ile test)
- [ ] DB'ye doğru veri yazılıyor (Supabase Studio'da kontrol)
- [ ] Flutter ekranı emülatörde açılıyor (hata yoksa)
- [ ] Hata senaryosu test edildi (ağ yok, boş input vb.)
- [ ] Bir sonraki adıma geçmeden önce mevcut adım stabil

---

## Ortam Değişkenleri (Environment Variables)

### Backend (`backend/.env`)
```
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJ...
ANTHROPIC_API_KEY=sk-ant-...
```

### Mobile (`frontend/.env` veya `dart-define`)
```
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
BACKEND_BASE_URL=https://xxxx.supabase.co/functions/v1
```