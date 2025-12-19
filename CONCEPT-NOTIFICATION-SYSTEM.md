# Bildirim Sistemi - Concept Document

**Version:** 1.0  
**Date:** 2025-12-19  
**Project:** Hackathon Group 3 - AI Document Check  
**Purpose:** Merkezi bildirim yönetim sistemi

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Sistem Mimarisi](#sistem-mimarisi)
3. [Bildirim Oluşturma Prosedürü](#bildirim-oluşturma-prosedürü)
4. [APEX Bildirim Kontrolü](#apex-bildirim-kontrolü)
5. [Toast Bildirim Gösterimi](#toast-bildirim-gösterimi)
6. [Sesli Bildirim](#sesli-bildirim)
7. [AI Bildirim Entegrasyonu](#ai-bildirim-entegrasyonu)
8. [Kullanım Senaryoları](#kullanım-senaryoları)

---

## 🎯 Overview

### Amaç
Sistem genelinde merkezi bir bildirim yönetim sistemi oluşturmak. Tek bir prosedür üzerinden tüm bildirimler oluşturulacak ve APEX uygulamalarında otomatik olarak kullanıcılara gösterilecek.

### Temel Özellikler
- ✅ Tek prosedür ile bildirim oluşturma
- ✅ APEX'te otomatik polling (x saniyede bir kontrol)
- ✅ Sadece okunmamış ve yeni bildirimleri gösterme
- ✅ Toast mesajları ile görsel bildirim
- ✅ Sesli bildirim desteği
- ✅ AI hata durumlarında otomatik bildirim

### Kullanım Alanları
- AI kontrol hataları
- Non-conformity bildirimleri
- Sistem uyarıları
- Kullanıcı bildirimleri

---

## 🏗️ Sistem Mimarisi

### Bildirim Akışı

```
1. Sistem Event (AI hata, non-conformity, vb.)
   ↓
2. Bildirim Prosedürü Çağrılır
   ↓
3. NOTIFICATIONS Tablosuna Kayıt Eklenir
   ↓
4. APEX Polling (Her x saniyede bir)
   ↓
5. Yeni/Okunmamış Bildirimler Kontrol Edilir
   ↓
6. Toast Mesajı + Sesli Bildirim Gösterilir
   ↓
7. Kullanıcı Bildirimi Görür/Okur
   ↓
8. Bildirim Okundu Olarak İşaretlenir
```

### Veri Modeli

**NOTIFICATIONS Tablosu:**
- `seq` - Primary key
- `aicheckseq` - AI check referansı (opsiyonel)
- `nonconformityseq` - Non-conformity referansı (opsiyonel)
- `notificationtype` - WARNING, ERROR, INFO, SUCCESS
- `priority` - LOW, NORMAL, HIGH, URGENT
- `channel` - IN_APP (APEX için)
- `recipientuser` - Alıcı kullanıcı
- `subject` - Bildirim başlığı
- `message` - Bildirim mesajı
- `isread` - Okundu mu? (Y/N)
- `readdate` - Okunma tarihi
- `createdate` - Oluşturulma tarihi
- `provisionerseq` - Tenant izolasyonu

---

## 🔧 Bildirim Oluşturma Prosedürü

### Prosedür Adı
`pkg_notifications.p_create_notification`

### Prosedür Parametreleri

**Gerekli Parametreler:**
- `p_notification_type` - WARNING, ERROR, INFO, SUCCESS
- `p_priority` - LOW, NORMAL, HIGH, URGENT
- `p_recipient_user` - Alıcı kullanıcı adı
- `p_subject` - Bildirim başlığı
- `p_message` - Bildirim mesajı

**Opsiyonel Parametreler:**
- `p_ai_check_seq` - AI check referansı (AI hataları için)
- `p_nonconformity_seq` - Non-conformity referansı
- `p_message_body` - Detaylı mesaj (CLOB)
- `p_recipient_email` - Email adresi (gelecekte email gönderimi için)
- `p_recipient_phone` - Telefon (gelecekte SMS için)

### Prosedür İşlevi

1. **Validasyon:**
   - Parametrelerin geçerliliğini kontrol et
   - Kullanıcının mevcut olup olmadığını kontrol et
   - PROVISIONERSEQ'i otomatik al

2. **Bildirim Oluşturma:**
   - NOTIFICATIONS tablosuna yeni kayıt ekle
   - `channel` = 'IN_APP' olarak ayarla
   - `isread` = 'N' olarak başlat
   - `deliverystatus` = 'PENDING' olarak ayarla
   - `createdate` = CURRENT_TIMESTAMP
   - Audit kolonlarını doldur

3. **Hata Yönetimi:**
   - Hata durumunda loglama yap
   - Exception handling ile güvenli çalışma

### Kullanım Örnekleri

**AI Hata Bildirimi:**
- AI check başarısız olduğunda
- AI check hata verdiğinde
- AI processing timeout olduğunda

**Non-Conformity Bildirimi:**
- Yeni non-conformity oluşturulduğunda
- Kritik severity non-conformity bildirildiğinde
- Non-conformity çözüldüğünde

**Sistem Bildirimi:**
- Sistem uyarıları
- Bilgilendirme mesajları
- Başarı mesajları

---

## 🔄 APEX Bildirim Kontrolü

### Polling Mekanizması

**Çalışma Prensibi:**
- APEX sayfasında JavaScript ile periyodik kontrol
- Varsayılan: Her 30 saniyede bir kontrol
- Yapılandırılabilir interval (kullanıcı tercihine göre)

**Kontrol Süreci:**
1. AJAX call ile APEX process'e istek gönder
2. Process, kullanıcının okunmamış bildirimlerini sorgula
3. Sadece `isread = 'N'` ve yeni bildirimleri döndür
4. Son kontrol zamanından sonra oluşturulan bildirimleri filtrele
5. JSON formatında bildirim listesi döndür

**Performans Optimizasyonu:**
- Sadece son 24 saat içindeki bildirimleri kontrol et
- Maksimum 10 bildirim döndür (en yeni önce)
- Index kullanımı ile hızlı sorgu

### APEX Process

**Process Adı:** `CHECK_NOTIFICATIONS`

**İşlevi:**
- Mevcut kullanıcıyı al (APP_USER)
- PROVISIONERSEQ'i al
- Son kontrol zamanını al (session state'den veya cookie'den)
- Okunmamış ve yeni bildirimleri sorgula
- JSON formatında döndür

**Dönen Veri Formatı:**
- Bildirim listesi (seq, type, priority, subject, message, createdate)
- Toplam okunmamış bildirim sayısı
- Son kontrol zamanı

---

## 🎨 Toast Bildirim Gösterimi

### Toast Mesaj Tipleri

**Bildirim Tipine Göre:**
- **ERROR** → Kırmızı toast, hata ikonu
- **WARNING** → Turuncu toast, uyarı ikonu
- **INFO** → Mavi toast, bilgi ikonu
- **SUCCESS** → Yeşil toast, başarı ikonu

**Önceliğe Göre:**
- **URGENT** → Büyük toast, otomatik kapanmaz, sesli
- **HIGH** → Orta boy toast, 10 saniye gösterilir, sesli
- **NORMAL** → Normal toast, 5 saniye gösterilir, sessiz
- **LOW** → Küçük toast, 3 saniye gösterilir, sessiz

### Toast Özellikleri

**Görsel:**
- Bildirim tipine göre renk kodlu
- İkon gösterimi
- Başlık ve mesaj
- Zaman damgası
- Kapatma butonu

**Etkileşim:**
- Tıklanabilir (bildirim detayına git)
- Otomatik kapanma (önceliğe göre)
- Manuel kapatma
- Bildirim listesine yönlendirme

**Konum:**
- Sağ üst köşe (desktop)
- Üst orta (mobil)
- Çoklu bildirim stack'lenir

---

## 🔊 Sesli Bildirim

### Ses Çalma Kuralları

**Ses Çalınacak Durumlar:**
- URGENT öncelikli bildirimler (her zaman)
- HIGH öncelikli bildirimler (her zaman)
- ERROR tipi bildirimler (her zaman)
- Kullanıcı tercihi açıksa (NORMAL ve LOW için)

**Ses Çalınmayacak Durumlar:**
- Kullanıcı sesi kapattıysa
- Sayfa arka plandaysa (browser tab inactive)
- Düşük öncelikli bildirimler (kullanıcı tercihine göre)

### Ses Dosyaları

**Bildirim Tipine Göre Ses:**
- **ERROR** → Hata sesi (dikkat çekici)
- **WARNING** → Uyarı sesi (orta ton)
- **INFO** → Bilgi sesi (yumuşak)
- **SUCCESS** → Başarı sesi (pozitif)

**Önceliğe Göre Ses:**
- **URGENT** → Yüksek ses, tekrarlı
- **HIGH** → Orta ses, tek sefer
- **NORMAL** → Düşük ses, tek sefer
- **LOW** → Çok düşük ses veya sessiz

### Kullanıcı Tercihleri

**Ayarlanabilir Özellikler:**
- Ses açık/kapalı toggle
- Ses seviyesi ayarı
- Hangi önceliklerde ses çalınacağı
- Bildirim sesi seçimi

---

## 🤖 AI Bildirim Entegrasyonu

### AI Hata Senaryoları

**AI Check Hataları:**
- AI check başarısız olduğunda (status = 'FAILED')
- AI check hata verdiğinde (status = 'ERROR')
- AI processing timeout olduğunda
- AI API bağlantı hatası
- AI model yanıt vermediğinde

**Bildirim Oluşturma:**
- AI check trigger'ı veya prosedürü içinde
- `p_create_notification` prosedürü çağrılır
- `p_ai_check_seq` parametresi ile AI check referansı verilir
- `notification_type` = 'ERROR' veya 'WARNING'
- `priority` = AI check sonucuna göre belirlenir

### AI Bildirim İçeriği

**Bildirim Başlığı:**
- "AI Validation Failed"
- "AI Processing Error"
- "AI Check Timeout"

**Bildirim Mesajı:**
- AI check numarası
- Hata detayı
- İlgili order/asset bilgisi
- Önerilen aksiyon

**Bildirim Detayları:**
- AI check sonuçları
- Hata mesajı
- Retry sayısı
- İlgili dokümanlar

### Otomatik Bildirim Tetikleme

**Trigger veya Prosedür İçinde:**
- AI_CHECKS tablosunda status güncellendiğinde
- Status = 'FAILED' veya 'ERROR' olduğunda
- Otomatik olarak bildirim prosedürü çağrılır
- İlgili kullanıcılara bildirim gönderilir

**Kullanıcı Seçimi:**
- Backoffice yöneticileri
- İlgili order'ın sorumlusu
- Quality control ekibi
- Sistem yöneticileri (kritik hatalar için)

---

## 📱 Kullanım Senaryoları

### Senaryo 1: AI Check Başarısız

**Akış:**
1. AI check çalışır, sonuç: FAILED
2. AI check trigger'ı tetiklenir
3. `p_create_notification` çağrılır
4. Bildirim oluşturulur (ERROR, HIGH priority)
5. APEX polling yeni bildirimi bulur
6. Toast mesajı gösterilir (kırmızı, sesli)
7. Kullanıcı bildirimi görür ve tıklar
8. AI check detay sayfasına yönlendirilir
9. Bildirim okundu olarak işaretlenir

### Senaryo 2: Kritik Non-Conformity

**Akış:**
1. Driver kritik non-conformity bildirir
2. Non-conformity oluşturulur (severity = CRITICAL)
3. `p_create_notification` çağrılır
4. Bildirim oluşturulur (WARNING, URGENT priority)
5. Backoffice kullanıcılarına gönderilir
6. APEX polling bildirimi bulur
7. Toast mesajı gösterilir (turuncu, yüksek sesli)
8. Kullanıcı bildirimi görür
9. Non-conformity detay sayfasına gider
10. Bildirim okundu olarak işaretlenir

### Senaryo 3: Sistem Bilgilendirme

**Akış:**
1. Sistem yöneticisi bilgilendirme mesajı gönderir
2. `p_create_notification` çağrılır
3. Bildirim oluşturulur (INFO, NORMAL priority)
4. Tüm kullanıcılara veya belirli gruba gönderilir
5. APEX polling bildirimi bulur
6. Toast mesajı gösterilir (mavi, sessiz)
7. Kullanıcı bildirimi görür (opsiyonel)
8. Bildirim otomatik kapanır veya manuel kapatılır

### Senaryo 4: Çoklu Bildirim

**Akış:**
1. Birden fazla bildirim aynı anda oluşturulur
2. APEX polling tüm yeni bildirimleri bulur
3. Bildirimler önceliğe göre sıralanır
4. En yüksek öncelikli bildirim önce gösterilir
5. Diğer bildirimler stack'lenir
6. Kullanıcı her birini sırayla görür
7. Bildirim listesi sayfasında tümü görüntülenir

---

## ⚙️ Yapılandırma

### Polling Interval

**Varsayılan:** 30 saniye

**Yapılandırılabilir:**
- Kullanıcı tercihi (15s, 30s, 60s)
- Sayfa bazlı (aktif sayfalarda daha sık)
- Sistem yüküne göre dinamik

### Bildirim Filtreleme

**Filtreleme Kriterleri:**
- Sadece okunmamış bildirimler
- Son kontrol zamanından sonra oluşturulanlar
- Kullanıcıya özel bildirimler
- Öncelik bazlı filtreleme (opsiyonel)

### Bildirim Saklama

**Saklama Süresi:**
- Okunmamış bildirimler: Sınırsız
- Okunmuş bildirimler: 30 gün
- Eski bildirimler: Arşivlenir veya silinir

---

## 🎯 Başarı Kriterleri

- ✅ Tek prosedür ile tüm bildirimler oluşturulabilir
- ✅ APEX'te otomatik polling çalışır
- ✅ Sadece yeni ve okunmamış bildirimler gösterilir
- ✅ Toast mesajları doğru şekilde görüntülenir
- ✅ Sesli bildirimler çalışır
- ✅ AI hatalarında otomatik bildirim oluşturulur
- ✅ Bildirim performansı yüksek (< 1 saniye)
- ✅ Kullanıcı deneyimi akıcı

---

**Document Version:** 1.0  
**Last Updated:** 2025-12-19  
**Author:** Hackathon Group 3  
**Status:** Concept - Ready for Implementation

