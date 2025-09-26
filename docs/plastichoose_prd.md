## Plastichoose — PRD ve Uygulama Yol Haritası (Offline Doktor Karar Mekanizması)

Bu doküman, yapay zekâ destekli üretim sürecinde adım adım izlenebilecek, açık ve uygulanabilir bir PRD sağlar. Tüm kararlar ve mimari tercihler Flutter/Dart, Clean Architecture, Provider, go_router ve get_it kurallarıyla uyumludur. Uygulama tamamen offline çalışır ve tüm veriler cihazda tutulur.

---

## 1) Ürün Özeti

- **Amaç**: Doktorların hasta görsellerini inceleyerek kabul/red kararı verebildiği, tamamen yerel ve offline çalışan bir uygulama.
- **Temel Modüller**: Ana Sayfa (Grid), Hasta Ekle, Hastalar Listesi, Karar Ver (Swipe), Çıktı Alma, Temizleme.
- **Başarı Kriterleri**:
  - Offline tam işlevsellik
  - 1.000+ hasta ve çoklu görselde akıcı performans
  - 3 tıklamada karar verme, 2 tıklamada çıktı alma
  - Gizlilik: Veriler cihaz dışına çıkmaz

---

## 2) Kapsam ve Varsayımlar

- İnternet gereksinimi yok; bulut senkronizasyonu yok.
- İzinler: Kamera, galeri, dosya sistemi erişimi kullanıcıdan istenir.
- Büyük görsel setlerinde disk alanı yönetimi kullanıcı sorumluluğundadır (uyarılar sağlanır).

---

## 3) Bilgi Mimarisi ve Navigasyon

- **Ana Sayfa (GridView)**: 2–3 sütunlu grid; her karo ilgili özelliğe gider.
  - Hasta Ekle
  - Hastalar Listesi
  - Karar Ver (Swipe)
  - Çıktı Alma
  - Temizleme
- **Yönlendirme**: Tek `GoRouter`, tipli rotalar tercih (go_router_builder), reactive redirect yok (auth gerekmiyor). 
- **Geçişler**: Hafif, hızlı animasyonlar; geri dönüş güvenli.

---

## 4) Özellik Gereksinimleri ve Kabul Kriterleri

### 4.1 Hasta Ekle
- Girdiler: Hasta adı (zorunlu, min 2 karakter), birden çok fotoğraf (kamera/galeri).
- Kurallar:
  - İsim alanı boş veya < 2 karakter ise kaydet kapalı/hata göster.
  - Aynı isim uyarısı (devam/iptal seçeneği).
  - Görseller disk üzerinde uygulama dizinine kopyalanır; metadata'da yol saklanır.
  - Thumbnail üretimi ve lazy load.
- Kabul Kriterleri:
  - Geçersiz girişlerde anlamlı hata iletisi.
  - Başarılı kayıtta hasta listesinde görüntülenir.

### 4.2 Hastalar Listesi
- Listeleme: Sanallaştırılmış liste; isim, küçük görsel önizleme, durum rengi.
- Arama/Filtre: İsim içeren arama; durum filtresi (karar verilmiş/verilmemiş).
- İşlemler: Detaya git, düzenle (ad/görseller), sil (onay diyalogu).
- Detay: Tüm görseller arasında gezinebilme ve büyütme/zoom.
- Kabul Kriterleri:
  - 1.000+ kayıtla akıcı kaydırma.
  - Filtre/arama < 200 ms yanıt.

### 4.3 Karar Ver (Swipe)
- Kuyruk: Karar durumu “yok” olan hastalar FIFO.
- Kart: Hasta adı + büyütülebilir görseller; sağ=Kabul, sol=Red.
- Geri Alma: Son karar için geri al butonu.
- Kısayol: Ekran butonları ile de karar verebilme.
- Animasyon: 60 fps hedef.
- Kabul Kriterleri:
  - Karar sonrası otomatik sıradaki hasta.
  - Geri al işlemi son seçimi geri döndürür.

### 4.4 Çıktı Alma
- Kapsam: Sadece karar verilmiş hastalar (accepted/rejected).
- Formatlar: `.txt` (CSV-benzeri, UTF-8), `.docx` (basit tablo), `.xlsx` (tek sayfa, header).
- Sütunlar: Hasta Adı, Karar (Kabul/Red), Karar Tarihi.
- Kaydetme: Cihaz dosya sistemine kullanıcı seçimiyle.
- Kabul Kriterleri:
  - Dosya oluşur ve içerik başlık/sütunlarla doğru biçimde kaydedilir.

### 4.5 Temizleme
- Ön Ayarlar:
  - Son 1 hafta hariç tümünü sil
  - Son 1 ay hariç tümünü sil
- Özel Aralık: Başlangıç–bitiş tarihi seçimi.
- Kapsam: “Yalnızca karar verilmiş hastalar” seçeneği (checkbox).
- Onay: Özet (silinecek kayıt sayısı) ve geri alınamaz uyarısı.
- Kabul Kriterleri:
  - Seçilen aralıklara uygun ve hızlı toplu silme (UI donmaz).

---

## 5) Veri Modeli (Mantıksal)

- Patient
  - id: uuid (string)
  - name: string
  - images: list<string> (dosya yolları)
  - decisionStatus: enum { none, accepted, rejected }
  - decisionAt: DateTime? (accepted/rejected ise dolu)
  - createdAt: DateTime
  - updatedAt: DateTime

Endeks önerileri:
- decisionStatus + createdAt (listeleme/temizleme hızlandırma)

---

## 6) Mimari ve Teknik İlkeler

- Clean Architecture, feature-first modüler yapı.
- Presentation: Sayfalar, widget'lar, `ChangeNotifier` controller'lar; immutable UI state nesneleri.
- Domain: Entity, repository arayüzleri, use case'ler (pure Dart).
- Data: Local datasource, DTO'lar, repository implementasyonları.
- Durum Yönetimi: Provider (ChangeNotifier + context.select).
- Yönlendirme: go_router (tipli rotalar tercih).
- DI: get_it (repository/use case wiring). Konteks DI içinde tutulmaz.
- Depolama: Yerel DB/anahtar-değer (metadata) + dosya sistemi (görseller). Çevrimdışı ve hızlı.
- Gizli/sabit değerler: Ortam değişkenleri veya konfigürasyon dosyaları üzerinden yönetilir; koda gömülmez.

---

## 7) UI/UX İlkeleri

- Modern, temiz, erişilebilir arayüz; kontrastlı karar renkleri.
- Grid ana sayfa: Büyük ikon + kısa başlıklar.
- Hata mesajları sayfa içinde (inline), net ve kısa.
- Büyük dokunma hedefleri; görsellerde pinch-to-zoom.

---

## 8) Durum Akışları (State Machine Özetleri)

- Hasta Ekle: idle → pickingImages → validating → saving → success|error
- Karar Ver: idle → viewing → swiping(right/left) → applyingDecision → nextCard
- Çıktı Alma: idle → buildingData → generatingFile → saving → success|error
- Temizleme: idle → calculatingImpact → confirming → deleting(batch) → success|error

---

## 9) Hata Yönetimi

- Geçersiz giriş: “Hasta adı en az 2 karakter olmalı.”
- Disk/izin hatası: “Dosya erişim izni gerekli.”
- Çıktı hatası: “Çıktı oluşturulamadı. Tekrar deneyin.”
- Toplu süreçlerde parça/parça sürdürme ve kullanıcıya özet rapor.

---

## 10) Performans Hedefleri

- Liste açılışı: < 100 ms gecikme.
- Karar kartı animasyonu: 60 fps.
- 1.000 hasta / 5.000+ görselde akıcı gezinme.
- Teknikler: Sanallaştırma, thumbnail cache, disk I/O batching, asenkron dosya işlemleri.

---

## 11) Ölçümler

- Günlük karar sayısı
- Karar ekranına geçiş süresi, animasyon süresi
- Çıktı üretim ve dosya erişim hata oranı
- Temizleme süresi ve silinen kayıt sayısı

---

## 12) Yol Haritası ve Adım Adım Uygulama Planı

Bu bölüm, yapay zekânın izleyebileceği net, sıralı görevleri içerir. Her adım tamamlandığında bir sonraki adıma geçilir.

### Faz 1 — Çekirdek Offline Uygulama
1. Proje temel bağımlılıkları ve yapılandırma
   - provider, go_router, get_it, freezed, json_serializable, build_runner
   - analysis_options (flutter_lints) doğrulaması
2. Çekirdek klasör yapısı (feature-first) ve DI iskeleti
   - `lib/app/{app.dart, router.dart, di.dart, theming/}`
   - `lib/core/{constants, errors, result, utils, storage}`
   - `lib/features/patients/{domain, data, presentation}`
3. Domain katmanı
   - Entity: Patient
   - Repository arayüzü: PatientsRepository
   - Use case'ler: addPatient, listPatients, getPatient, updatePatient, deletePatient, decidePatient, undoDecision
4. Data katmanı
   - Local datasource: metadata CRUD + dosya kopyalama/silme + thumbnail
   - DTO/mapper: PatientModel ↔ Patient
   - Repository implementasyonu
5. Presentation katmanı
   - Ana sayfa (Grid)
   - Hasta Ekle sayfası (form + çoklu görsel seçimi/kameradan ekleme)
   - Hastalar Listesi (arama/filtre, detay/düzenleme/silme)
6. Karar Ver (Swipe) sayfası ve geri al akışı
7. Kalıcı depolama ve izin akışlarının doğrulanması (manual QA)

### Faz 2 — Çıktı Alma
8. Çıktı veri toplayıcı (yalnızca karar verilmiş hastalar)
9. .txt, .docx, .xlsx üreticileri (basit tablo/satırlar)
10. Dosya kaydetme akışı ve başarı/hata durumları

### Faz 3 — Temizleme
11. Ön ayarlar (1 hafta/1 ay hariç tümü) hesaplama
12. Özel tarih aralığı seçimi + yalnızca karar verilmiş filtresi
13. Toplu silme (batch) ve özet onay ekranı

### Faz 4 — İyileştirmeler
14. Gelişmiş arama/filtreler ve erişilebilirlik
15. Performans optimizasyonları (önbellek stratejileri, I/O iyileştirmeleri)

---

## 13) Test Stratejisi

- Unit test: Domain use case'ler ve repository sözleşmeleri
- Widget test: Sayfalar (özellikle karar akışı ve liste filtreleri)
- Entegrasyon: Depolama ve dosya I/O akışları (cihaz/emülatör)

---

## 14) Riskler ve Azaltım Planları

- Büyük görseller → Thumbnail ve sınırlı önizleme, isteğe bağlı tam çözünürlük.
- Platform izin farklılıkları → Platforma özel izin kılavuzları ve hata mesajları.
- Disk alanı → Kullanıcıya periyodik uyarılar ve Temizleme sekmesinin görünürlüğü.

---

## 15) Sözlük (Terimler)

- Accepted: Doktor tarafından onaylanmış hasta.
- Rejected: Doktor tarafından reddedilmiş hasta.
- None: Henüz karar verilmemiş hasta.
- Thumbnail: Hızlı listeleme için düşük çözünürlüklü önizleme görseli.

---

## 16) Tamamlanma Tanımı (DoD)

- Tüm ana senaryolar offline çalışır.
- Liste/karar ekranları performans hedeflerini karşılar.
- Çıktı dosyaları 3 formatta doğru üretilir.
- Temizleme doğru aralık ve filtrelere göre çalışır; UI donmaz.
- Testler çalışır ve kritik yolları kapsar.

---

## 17) İzleme Listesi (Yapay Zekâ İçin Checklist)

- [ ] Proje iskeleti ve bağımlılıklar
- [ ] Router ve ana sayfa (Grid)
- [ ] Domain: Patient entity + repository arayüzü + use case'ler
- [ ] Data: Local datasource + DTO + repository implementasyonu
- [ ] Hasta Ekle sayfası (form + çoklu görsel ekleme)
- [ ] Hastalar Listesi (arama/filtre/detay/düzenleme/silme)
- [ ] Karar Ver (Swipe) + geri al
- [ ] Çıktı Alma (.txt/.docx/.xlsx)
- [ ] Temizleme (ön ayar/özel aralık/yalnızca karar verilmiş)
- [ ] Testler (unit/widget/entegrasyon) ve performans doğrulamaları


