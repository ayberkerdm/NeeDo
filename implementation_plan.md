# Backend Entegrasyon Planı (NeeDo Uygulaması)

NeeDo (hizmet pazaryeri) uygulamanız için bir backend altyapısı kurma talebiniz doğrultusunda, Firebase ve Supabase seçeneklerini değerlendiren ve adım adım nasıl entegre edileceğini gösteren bir plan hazırladım.

Uygulamanın yapısı (Hizmet Alanlar, Hizmet Verenler, Talepler, Teklifler, Mesajlar vb.) oldukça ilişkisel (relational) bir veri modeline ihtiyaç duymaktadır. Bu bağlamda her iki teknolojinin de avantajları ve dezavantajları bulunmaktadır.

## Supabase vs Firebase Karşılaştırması

### 1. Veri Modeli
*   **Supabase:** PostgreSQL tabanlıdır (İlişkisel Veritabanı). Uygulamanızdaki "Kullanıcı -> Talep -> Teklif -> Mesaj" gibi karmaşık ilişkileri yönetmek SQL veritabanlarında çok daha kolay, tutarlı ve performanslıdır.
*   **Firebase:** NoSQL (Firestore) kullanır. Veriler dokümanlar halinde tutulur. Gerçek zamanlı işlemler çok hızlı olsa da, ilişkisel verileri (örneğin "Şu uzmanın onayladığı ve şu müşteriye ait olan teklifler") sorgulamak Firestore'da veriyi tekrarlamayı (data duplication) gerektirebilir ve yapıyı karmaşıklaştırabilir.

### 2. Realtime (Gerçek Zamanlılık)
*   **Firebase:** Realtime konusunda sektör standartlarındandır. Mesajlaşma ekranı ve anlık bildirimler için mükemmeldir.
*   **Supabase:** PostgreSQL'in üzerine kurulan Realtime özellikleri ile Firestore'a çok yakın bir performans sunar. Chat ve anlık teklif bildirimleri için fazlasıyla yeterlidir.

### 3. Flutter Uyumluluğu
*   Her ikisinin de Flutter için harika ve resmi/aktif desteklenen SDK'ları bulunmaktadır. Projede kullandığınız `flutter_riverpod` her iki teknolojiyle de kolayca entegre edilebilir.

### 4. Fiyatlandırma ve Sahiplik
*   **Supabase:** Açık kaynaklıdır. Kendi sunucunuza (self-host) kurabilir veya yönetilen bulut hizmetini kullanabilirsiniz. Vendor lock-in (sisteme hapsolma) riski daha düşüktür.
*   **Firebase:** Google'ın kapalı kaynaklı sistemidir. Kullanımı çok kolaydır ancak veri büyüdükçe Firestore okuma/yazma maliyetleri öngörülemez şekilde artabilir.

## 💡 Öneri: Supabase

Armut.com benzeri bir hizmet pazaryeri uygulaması **kesinlikle güçlü ilişkisel verilere (Relational Data)** ihtiyaç duyar. Örneğin;
- "Hizmet Veren" (Provider) tablosu
- "Hizmet Alan" (Customer) tablosu
- "Talepler" (Requests) tablosu (Customer ID ile bağlı)
- "Teklifler" (Offers) tablosu (Request ID ve Provider ID ile bağlı)

Bu tür ilişkileri yönetmek, filtrelemek (Örn: "Sadece İstanbul'daki temizlik talepleri") PostgreSQL (Supabase) ile NoSQL'e (Firebase) kıyasla çok daha hatasız ve esnektir. Bu yüzden projeniz için **Supabase'i** tercih etmenizi öneririm.

---

## 🛠️ Entegrasyon Yol Haritası (Supabase)

### Aşama 1: Proje Kurulumu
1.  Supabase platformunda yeni bir proje oluşturulması.
2.  Flutter projenize `supabase_flutter` paketinin eklenmesi.
3.  Proje başlatılırken Supabase bağlantısının (URL ve Anon Key) `main.dart` üzerinde yapılandırılması.

### Aşama 2: Veritabanı (Şema) Tasarımı
PostgreSQL üzerinde temel tabloların oluşturulması:
*   `profiles`: Kullanıcı rolleri (Müşteri veya Hizmet Veren), isim, telefon, puan.
*   `services`: Sunulan hizmet kategorileri (Temizlik, Nakliyat vb.).
*   `requests`: Müşterilerin oluşturduğu hizmet talepleri (Konum, Bütçe, Tarih, Açıklama).
*   `offers`: Hizmet verenlerin taleplere verdiği teklifler (Fiyat, Tahmini Süre, Durum).
*   `messages`: Kullanıcılar arası sohbet kayıtları.

> [!NOTE]
> Supabase'in Row Level Security (RLS) politikaları sayesinde her kullanıcı sadece kendi verilerini (kendi mesajları, kendi teklifleri) görebilecek şekilde yetkilendirme (güvenlik) kuralları yazılacaktır.

### Aşama 3: Kimlik Doğrulama (Auth)
1.  Kayıt Ol / Giriş Yap ekranlarının Supabase Auth'a bağlanması.
2.  E-posta / Şifre girişinin aktifleştirilmesi.
3.  İstenirse Google veya Apple ile giriş (OAuth) özelliklerinin entegrasyonu.
4.  Giriş yapan kullanıcının bilgilerinin `flutter_riverpod` ile global state olarak tutulması.

### Aşama 4: Storage (Depolama)
1.  Supabase Storage üzerinde "Profil Fotoğrafları" ve "Talep Görselleri" için iki adet bucket oluşturulması.
2.  Kullanıcının uygulamadan fotoğraf seçip Supabase Storage'a yükleyebileceği yapının kurulması.

### Aşama 5: Arayüz (UI) - Backend Bağlantısı
1.  Şu an `Prompt.md` dosyasında bahsedilen "Mock (dummy)" verilerin kaldırılarak, Supabase'den gelen gerçek verilerle (FutureBuilder veya Riverpod FutureProvider kullanarak) değiştirilmesi.
2.  Mesajlar ekranı için Supabase Realtime Stream yapısının kurularak anlık mesajlaşmanın sağlanması.
3.  Loading (Yükleniyor) ve Error (Hata) state'lerinin uygun şekilde gösterilmesi.

---

> [!IMPORTANT]
> ## User Review Required
> Lütfen aşağıdaki karar noktalarını inceleyip görüşünüzü belirtin:
>
> 1. **Teknoloji Seçimi:** Yukarıdaki gerekçeler ışığında backend olarak **Supabase** ile ilerlemeyi onaylıyor musunuz? (Eğer Firebase'i daha iyi biliyorsanız veya Firestore kullanmayı tercih ediyorsanız, planı Firebase'e göre revize edebilirim.)
> 2. **Kimlik Doğrulama:** İlk aşamada sadece E-posta/Şifre mi yapalım, yoksa Telefon/SMS veya Google/Apple ile girişi de başlangıçta kurmak ister misiniz?
> 3. **Veritabanı Tasarımı:** Uygulamanın temel tabloları (Kullanıcı, Kategori, Talep, Teklif, Mesaj) başlangıç için yeterli midir? Özel olarak tutulmasını istediğiniz başka bir veri var mı?

Onayınız veya revize talebinize göre projeye kod düzeyinde entegrasyon için başlayabiliriz.
