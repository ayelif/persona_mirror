# 📈 Gelişim Günlüğü & İlerleme Raporu (Progress.md)

**Proje:** Persona Mirror  
**Geliştirici:** Elif AY & AI Pair Programmer  
**Son Güncelleme:** 1 Haziran 2026

---

## 1. Geliştirme Yaklaşımımız (Our Approach)

Persona Mirror projesinin 8 haftalık zorunlu teslim süresi göz önünde bulundurularak, **Mobile-First** (Mobil Öncelikli) ve **Decoupled API-First** (Ayrık Servis Öncelikli) bir strateji benimsenmiştir.
- **Modülerlik:** İş mantığı tamamen frontend'den izole edilerek backend'de (Supabase Edge Functions) çözülmüş, böylelikle gelecekte web veya masaüstü geçişlerine açık kapı bırakılmıştır.
- **AI-Assisted Iteration:** Her bir kod bloğu, veritabanı migrasyonu ve API kontratı AI yardımıyla tasarlanmış ve optimize edilmiştir.

---

## 2. Bugüne Kadar Yapılanlar & Tamamlanan Milestones

### 2.1. Altyapı ve Veritabanı Kurulumu (Faza 0 & 1)
- **Veritabanı Şeması:** PostgreSQL üzerinde `users`, `scenarios`, `sessions`, `messages` ve `analyses` tabloları ilişkisel olarak kuruldu.
- **Güvenlik (RLS):** Her tabloya Row Level Security (RLS) kuralları yazılarak kullanıcıların yalnızca kendilerine ait verileri görebilmesi sağlandı.
- **Supabase Cloud Bağlantısı:** Local Supabase veritabanı şeması ve konfigürasyonları başarıyla buluta taşındı ve deploy edilmeye hazır hale getirildi.

### 2.2. Backend & API Geliştirmesi (Faza 2 & 3 & 4)
- **CORS ve JWT Yardımcıları:** Tüm Edge Function'lar için güvenli Cross-Origin Resource Sharing (CORS) filtreleri ve Authorization Bearer token doğrulama mekanizmaları yazıldı.
- **Google Auth Servisi:** `/auth` endpoint'i Google `id_token`'ını doğrulayıp kullanıcıyı veritabanında senkronize edecek şekilde kodlandı.
- **Senaryo CRUD API:** Kullanıcının özel senaryo kaydetmesini ve hazır şablonları çekmesini sağlayan `/scenarios` endpoint'i yazıldı.
- **AI Sohbet Simülasyon Motoru (`sessions`):**
  - Gemini 2.5 Flash ve Groq Llama 3.3-70b-versatile modelleri üzerinden çift katmanlı LLM altyapısı kuruldu.
  - LLM'lerin birer robot gibi değil; duraksayan, duygusal tepkiler veren gerçekçi günlük Türkçe (`colloquial`) dil kullanması sağlandı.
  - Canlı mentor/ipucu desteği sağlayan `/sessions/:id/hint` API'si entegre edildi.
- **Otomatik Raporlama API (`analyses`):** Oturum sonlandığında otomatik tetiklenen ve empati/netlik/kararlılık skorlarını hesaplayıp detaylı geri bildirim üreten `/analyses` API'si tamamlandı.

---

## 3. Karşılaşılan Kritik Hatalar & Çözüm Yolları (Resolved Issues)

### 3.1. Senaryo Oluşturmada Kullanıcı Senkronizasyon Hatası
- **Hata:** Flutter tarafında senaryo eklenirken `foreign key constraint` hatası alınıyordu; çünkü kullanıcı authentication id'si ile PostgreSQL'deki `users.id` eşleşmiyordu.
- **Çözüm:** `ScenarioRepository` katmanında yeni senaryo eklemeden önce kullanıcının public profil tablosundaki asıl UUID'sini çeken ve sorguyu bu veriyle güncelleyen koruyucu bir eşleştirme katmanı eklendi.

### 3.2. Deno Edge Functions CORS Engeli
- **Hata:** Flutter Web veya mobil tarayıcılardan yerel fonksiyonlar çağrıldığında tarayıcı güvenliği sebebiyle CORS engeline takılıyordu.
- **Çözüm:** `_shared/cors.ts` altında global bir CORS handler oluşturuldu ve tüm Edge Function'lar gelen `OPTIONS` isteklerine otomatik olarak `204 No Content` yanıtı vererek CORS başlıklarını ekleyecek şekilde güncellendi.

### 3.3. LLM API Kota / Hata Durumları
- **Hata:** Claude veya Gemini API'lerinde anlık kesintiler veya kota aşımı yaşandığında sohbet akışı yarıda kalıyordu.
- **Çözüm:** Çift katmanlı (Gemini 2.5 Flash as primary, Groq Llama 3.3 as fallback) bir `try-catch` mekanizması kuruldu. Gemini çöktüğü an sistem kesinti yapmadan Groq'a geçmektedir.

---

## 4. Gelecek Planı & Kalan Adımlar (Next Steps)
- **UI Entegrasyonu:** Flutter mobil uygulamasında Splash Screen, Dashboard ve Chat arayüzünün bu yeni API endpoint'leri ile tam entegre edilmesi.
- **Stabilite Testleri:** Çevrimdışı (offline) modlarda SnackBar hata uyarılarının ve otomatik token yenileme (refresh token) mekanizmalarının test edilmesi.
- **Web Deploy (Canlıya Alma):** Flutter projesinin Web platformuna build alınarak Vercel veya Supabase Hosting üzerinde canlıya taşınması.
