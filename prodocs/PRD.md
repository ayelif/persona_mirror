# 🧠 Persona Mirror — Ürün Gereksinim Dökümanı (Product Requirement Document - PRD)

**Proje Adı:** Persona Mirror  
**Sürüm:** v1.0.0 (MVP)  
**Tarih:** 1 Haziran 2026  
**Durum:** Aktif / Canlıya Hazır  
**Hedef Kitle:** Profesyonel çalışanlar, öğrenciler, çiftler ve sosyal iletişimini geliştirmek isteyen herkes.

---

## 1. Ürün Vizyonu ve Çözülen Problem

### Problemin Tanımı
İnsan ilişkilerindeki en büyük zorluklar genellikle **kaçınılan zor konuşmalardan** kaynaklanır: zam istemek, sınır çizmek, kırıcı bir durumu dile getirmek veya bir ilişkiyi sonlandırmak. Bu anlarda insanlar genellikle aşırı heyecanlanır, empati kurmakta zorlanır veya fikirlerini kararlılıkla savunamayıp geri çekilir. Gerçek hayatta bu anları "deneme" şansı yoktur ve başarısız bir konuşmanın telafisi zordur.

### Çözüm Vizyonu
**Persona Mirror**, kullanıcıların bu kritik anları gerçek hayatta yaşamadan önce **güvenli bir simülasyon ortamında** prova etmelerini sağlar. Yapay zeka destekli sanal karakterler (persona'lar) kullanıcıya gerçekçi bir direnç gösterirken, konuşmanın sonunda verilen **Empati**, **Netlik** ve **Kararlılık** değerlendirmeleriyle kullanıcı adeta kendini bir aynada izler gibi analiz eder.

---

## 2. Hedef Kullanıcı Profilleri (Persona'lar)

1. **Mert (28, Yazılım Geliştirici):** Patronundan hak ettiği zammı istemekten çekiniyor. Konuşma esnasında savunmaya geçmeden net argümanlar sunabilmeyi prova etmek istiyor.
2. **Selin (32, Pazarlama Yöneticisi):** Arkadaşlarına veya iş arkadaşlarına sınır koymakta zorlanıyor. Kırmadan, empatiyle ama kararlı bir şekilde "hayır" diyebilmeyi öğrenmek istiyor.
3. **Can (23, Öğrenci):** Ailesiyle yaşadığı kariyer ve gelecek planı çatışmalarını yönetmek için daha sakin ve net bir iletişim dili arıyor.

---

## 3. Temel Özellikler (Core Features)

### 3.1. Hızlı Başlatma & Hazır Şablonlar (Scenarios & Templates)
- **Kategoriler:** İş Hayatı, Aile, Arkadaşlık, Romantik İlişkiler, Diğer.
- **Şablonlar:** Sık karşılaşılan senaryolar için hazır şablon kartları (örn: "Patronla Zam Görüşmesi", "Arkadaşa Sınır Koyma").
- **Özel Senaryolar:** Kullanıcının kendi durumuna özel bağlam tanımlayabilmesi (*"Karşımdaki kişi eşim, son zamanlarda çok yorgun olduğunu söylüyor..."*).

### 3.2. Yapay Zeka Destekli Dinamik Rol Yapma (Simulation Room)
- **Duygusal Tepkiler (Moods):** AI, kullanıcının cümlelerine göre `neutral`, `satisfied`, `defensive`, `frustrated`, `agitated` modlarına bürünür.
- **Stres Seviyesi (1-10):** Kullanıcı sertleştikçe veya aşırı baskı yaptıkça AI'ın stres seviyesi dinamik olarak artar ve tepkileri değişir.
- **İletişim Zorluk Seviyeleri:** `Easy` (Uzlaşmacı), `Medium` (Dengeli), `Hard` (İnatçı/Savunmacı) modları.
- **Canlı Mentor İpucu (Live Tips):** Kullanıcı tıkandığında AI Mentordan anlık yapıcı cümle ve taktik önerisi alabilir.

### 3.3. Ayna Etkisi: İletişim Analizi & Raporlama (Analytics Room)
- **Değerlendirme Puanları:** Empati, Netlik ve Kararlılık (1-10 arası skorlar).
- **Güçlü Yanlar & Gelişim Alanları:** Kullanıcının konuşmadaki olumlu yaklaşımları ve kaçırdığı fırsatlar.
- **Alternatif Cümle Önerileri:** *"Şu cümlen yerine bunu söyleseydin daha yapıcı olurdu"* önerileri.
- **Analiz Paylaşımı:** Raporu native paylaşım sheet'i ile paylaşabilme.

---

## 4. Kapsam Dışı Özellikler (Out of Scope for MVP)
- Sesli konuşma simülasyonu (Text-to-speech / Speech-to-text).
- Çoklu kullanıcı (Multiplayer) veya canlı koç eşleştirme.
- Sosyal topluluk akışı (Community feed).

---

## 5. Metrikler & Başarı Kriterleri
- **Kuzey Yıldızı Metriği (North Star):** Tamamlanan ve analiz edilen simülasyon oturumu sayısı.
- **Kullanıcı Tutundurma (Retention):** Haftalık en az 2 simülasyon tamamlayan kullanıcı oranı.
- **Viralite Metriği:** Paylaşılan analiz görseli sayısı.
