NeeDo adında, Armut.com tarzında bir mobil uygulama tasarımı oluştur.

Teknoloji tarafında uygulama Flutter ile geliştirilecek, bu yüzden tasarım mobil-first, modern, temiz, component bazlı ve Flutter’a kolay aktarılabilir olmalı. Tasarım dili tamamen Türkçe olsun. Uygulamanın adı her ekranda ve marka kimliğinde “NeeDo” olarak geçsin.

Uygulamanın ana mantığı:
Kullanıcıların ihtiyaç duydukları hizmetleri kolayca seçebildiği, hizmet veren kişilerden teklif alabildiği, profilleri inceleyebildiği ve randevu / hizmet sürecini takip edebildiği bir hizmet pazaryeri uygulaması tasarla. Armut.com mantığında çalışsın ama daha modern, sade ve güven veren bir arayüzü olsun.

İstenen genel tasarım özellikleri:

* Modern, sade, güven veren ve kullanıcı dostu arayüz
* Mobil uygulama odaklı tasarım
* Flutter component yapısına uygun ekranlar
* Türkçe metinler ve gerçekçi buton/adlandırmalar
* Soft shadow, yuvarlatılmış kartlar, temiz spacing
* Hem müşteri hem hizmet veren deneyimi düşünülmüş olsun
* Alt navigasyon barı bulunsun
* Renk paleti modern ve profesyonel olsun
* Beyaz ağırlıklı, ferah bir görünüm tercih et
* Vurgu renkleri güven, hız ve pratiklik hissi versin

Hedef kullanıcı kitlesi:
Türkiye’de günlük hizmet ihtiyacı olan kullanıcılar. Örneğin:

* Temizlik
* Nakliyat
* Boya badana
* Elektrikçi
* Tesisatçı
* Klima servisi
* Özel ders
* Ev taşıma
* Mobilya montaj
* Kuaför / bakım
* Evde bakım hizmetleri

Mutlaka tasarlanması gereken ekranlar:

1. Splash Screen

* NeeDo logosu
* Kısa slogan: “İhtiyacın olan hizmet kapında”
* Minimal giriş animasyonu hissi

2. Onboarding Screens

* Uygulamanın mantığını anlatan 3 ekran
* Kolay hizmet bulma
* Hızlı teklif alma
* Güvenilir ustalarla çalışma

3. Giriş Yap / Kayıt Ol

* Telefon numarası ile giriş
* E-posta ile giriş
* Şifre alanı
* Google ile devam et
* Apple ile devam et
* “Hesabın yok mu? Kayıt ol”
* “Şifremi unuttum”

4. Ana Sayfa

* Üstte karşılama alanı
* Arama çubuğu: “Hangi hizmete ihtiyacın var?”
* Popüler kategoriler
* Kampanya / öneri banner alanı
* En çok tercih edilen hizmetler
* Yakındaki hizmet verenler
* Daha önce baktığın hizmetler
* Alt navigasyon: Ana Sayfa, Hizmetler, Taleplerim, Mesajlar, Profil

5. Kategori / Hizmetler Ekranı

* Tüm hizmet kategorileri grid ya da kart düzeninde
* İkonlu yapı
* Kategori arama
* Filtreleme alanı

6. Hizmet Talebi Oluşturma Akışı
   Armut tarzında adım adım form tasarla:

* Hangi hizmet lazım?
* Konum seçimi
* Tarih / saat seçimi
* Hizmet detayları
* Fotoğraf yükleme
* Bütçe aralığı
* Açıklama alanı
* “Teklif Al” butonu

7. Teklifler Ekranı

* Hizmet verenlerden gelen teklifler
* Kart yapısında liste
* Fiyat
* Hizmet veren adı
* Puan
* Yorum sayısı
* Tahmini süre
* “Profili Gör”
* “Mesaj Gönder”
* “Teklifi Kabul Et”

8. Hizmet Veren Profil Ekranı

* Profil fotoğrafı
* Ad soyad
* Uzmanlık alanı
* Ortalama puan
* Yorumlar
* Tamamlanan iş sayısı
* Sertifikalar / rozetler
* Galeri alanı
* “Mesaj Gönder”
* “Teklif İste”
* “Favorilere Ekle”

9. Mesajlar Ekranı

* Kullanıcı ile hizmet veren arasında sohbet ekranı
* Modern chat UI
* Teklif detayını üstte küçük özet olarak göster
* Fotoğraf gönderme opsiyonu
* Tarih/saat düzeni

10. Taleplerim Ekranı

* Aktif talepler
* Bekleyen teklifler
* Tamamlanan işler
* İptal edilen talepler
* Sekmeli yapı kullanılabilir

11. Randevu / Hizmet Takip Ekranı

* Hizmet tarihi
* Hizmet veren bilgisi
* Durum: Bekliyor / Yolda / Başladı / Tamamlandı
* Adres bilgisi
* Destek butonu
* İptal / yeniden planla seçenekleri

12. Değerlendirme ve Yorum Ekranı

* Yıldız puanlama
* Yorum yazma alanı
* Hizmet deneyimini değerlendirme

13. Profil Ekranı

* Kullanıcı bilgileri
* Kayıtlı adresler
* Ödeme yöntemleri
* Bildirim ayarları
* Yardım merkezi
* Favorilerim
* Geçmiş hizmetler
* Çıkış yap

14. Hizmet Veren Paneli / Ayrı Deneyim
    Hizmet veren kullanıcı için de ekranlar tasarla:

* Gelen talepler
* Teklif gönderme
* Takvim
* Kazanç özeti
* Müşteri mesajları
* Profil düzenleme
* Hizmet alanları yönetimi

15. Bildirimler Ekranı

* Yeni teklif
* Mesaj bildirimi
* Hizmet hatırlatması
* Kampanyalar

UI/UX beklentileri:

* Tasarımlar gerçek bir ürün gibi profesyonel olsun
* Her ekranın spacing, component yapısı ve hiyerarşisi düzgün olsun
* CTA butonları belirgin olsun
* Kart yapıları Flutter’da kolay üretilebilir olsun
* Form ekranları kullanıcıyı yormayacak şekilde sade olsun
* Güven hissi oluşturmak için puan, yorum, doğrulama rozeti gibi alanlar net vurgulansın

İstenen çıktı formatı:

* Tüm ekranları tek tek ve tutarlı bir tasarım sistemiyle oluştur
* Aynı design system’i kullan
* Renk paleti, typography, button stilleri, text field stilleri, kart yapıları tutarlı olsun
* Flutter geliştiricisinin rahatlıkla referans alabileceği kadar net bir mobil uygulama tasarımı üret
* Türkçe içerik kullan
* Uygulama App Store / Google Play seviyesinde modern görünsün

Backend şu aşamada aktif olarak kullanılmayacak, ancak uygulama ileride gerçek bir backend ile entegre edilecek şekilde tasarlanmalıdır.

Bu nedenle:

* Tüm veriler mock (dummy) veri olarak gösterilmeli
* Ancak component yapısı backend’e bağlanabilir şekilde düşünülmeli
* Liste yapıları, kartlar ve detay sayfaları dinamik veri gelecekmiş gibi tasarlanmalı
* State yönetimi mantığı (loading, empty, error state) UI seviyesinde düşünülmeli

Özellikle dikkat edilmesi gerekenler:

* API’den veri geliyormuş gibi loading skeleton ekranları tasarla
* Veri yoksa (empty state) kullanıcıyı yönlendiren ekranlar oluştur
* Hata durumları için (error state) basit UI’lar ekle
* Teklifler, mesajlar, talepler gibi alanlar gerçek zamanlı veri gelecekmiş gibi kurgulanmalı

Amaç:
Şu an sadece UI/UX tasarımı yapılacak, ancak bu tasarım ileride kolayca backend (örneğin REST API veya Firebase) ile entegre edilebilecek yapıda olmalıdır.


Ek not:
Armut.com’dan ilham alan bir yapı olsun ama birebir kopya olmasın. NeeDo kendi marka kimliğine sahip, daha genç, daha modern ve daha sade bir hizmet pazaryeri uygulaması gibi hissettirsin.
