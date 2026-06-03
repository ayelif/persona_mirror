# 🎨 Tasarım Sistemi (DesignSystem.md)

**Proje:** Persona Mirror  
**Tasarım Dili:** Premium Soft UI & Glassmorphism (Modern, Canlı ve Güven Veren)  
**Renk Karakteri:** Derin Lacivert (Gece), Yumuşak Krem (Toprak), Eflatun (Duygu) ve Turkuaz (Netlik)

---

## 1. Renk Paleti (Color Palette)

Arayüzde sade ve sıradan renkler yerine, birbiriyle mükemmel uyum sağlayan ve gözü yormayan premium bir kontrast hedeflenmiştir.

| Renk | Hex Kodu | Kullanım Alanı | Psikolojik Etki |
|---|---|---|---|
| **Deep Space (Koyu Lacivert)** | `#0D1B2A` | Birincil arka planlar, gölgeler, ana butonlar | Güven, derinlik, odaklanma |
| **Warm Sand (Yumuşak Krem)** | `#F4F1DE` | Metinler, ikincil arka planlar, aydınlık mod elemanları | Sıcaklık, doğallık, okunabilirlik |
| **Amethyst Glow (Lavanta/Mor)** | `#8187B4` | Empati metrikleri, vurgu renkleri, pasif kart sınırları | Duygusallık, anlayış, bilgelik |
| **Mint Breeze (Nane Yeşil/Turkuaz)** | `#3D9970` | Netlik skoru, başarı durumları, aktif butonlar | Netlik, gelişim, sakinlik |
| **Soft Coral (Yumuşak Mercan)** | `#E07A5F` | Kararlılık skoru, stres indikatörleri, uyarı durumları | Kararlılık, güç, ciddiyet |

---

## 2. Tipografi (Typography)

Persona Mirror, modern ve okunabilirliği en üst düzeyde tutan **Google Fonts - Outfit** ve **Inter** font ailelerini kullanır.

- **Başlıklar (Headers):** `Outfit` (Modern, geometrik ve premium duruş)
  - `Display Large`: 32pt · Bold (Splash başlığı, büyük skorlar)
  - `Headline Medium`: 20pt · SemiBold (Dashboard selamlama, kart başlıkları)
- **Gövde Metinleri (Body Text):** `Inter` (Sohbet balonlarında ve analiz metinlerinde maksimum okunabilirlik)
  - `Body Large`: 16pt · Medium (Mesaj metinleri, form bağlam alanları)
  - `Body Small`: 12pt · Regular (Tarihler, ek bilgiler, küçük ipucu kartları)

---

## 3. Glassmorphism & Kart Tasarım Kuralları

Uygulamanın görsel kalitesini "sıradan" seviyesinden "premium" seviyesine taşıyan en önemli unsur **Glassmorphic** kart tasarımlarıdır.

### Cam Efekti Kuralları (Flutter):
- **Arka Plan Rengi:** Fırçalanmış beyaz/gri, saydamlık `%10` - `%18` aralığında olmalıdır:
  ```dart
  Color(0xFFFFFFFF).withOpacity(0.12)
  ```
- **Bulanıklık (Blur):** `BackdropFilter` ile en az 10-15 piksel derinlik:
  ```dart
  ImageFilter.blur(sigmaX: 12, sigmaY: 12)
  ```
- **Kart Sınırları (Border):** Çok ince, belirgin ama göze batmayan beyaz sınırlar (%15 opaklık):
  ```dart
  Border.all(color: Colors.white.withOpacity(0.15), width: 1.0)
  ```
- **Köşe Yuvarlama (BorderRadius):** Tüm kartlarda standart `BorderRadius.circular(16)` kullanılır.

---

## 4. Bileşen Kuralları (Component Rules)

### 4.1. Mesaj Baloncukları (Chat Bubbles)
- **Kullanıcı Mesajı:** Sağda yer alır. Arka planı düz, derin lacivert veya mat mor renkli, sağ alt köşesi keskin oval. Metin rengi Warm Sand.
- **AI Karakter Mesajı:** Solda yer alır. Arka planı cam efektli (glassmorphic), sol alt köşesi keskin oval. Metin rengi mat beyaz.

### 4.2. Kategori Seçim Çipleri (Selection Chips)
- Çipler oval kenarlı (`stadium border`) olmalıdır.
- Seçili olmayan çip: Koyu mavi arka plan, ince gri sınır, pasif beyaz metin.
- Seçili çip: Amethyst Glow veya Mint Breeze arka plan, hafif dış ışık (glow effect), kalın beyaz metin.

### 4.3. Animasyonlu Dairesel Göstergeler (Gauges)
- Analiz ekranındaki Empati, Netlik ve Kararlılık skor göstergeleri sıfırdan başlayarak hedeflenen değere doğru saat yönünde dönerek çizilmelidir.
- Göstergelerin içi hafifçe saydam renklerle dolmalı, skor değeri tam ortada büyük puntolarla yazılmalıdır (örn: `8/10`).
