-- 1. KATEGORİLER (Services) İÇİN ÖRNEK VERİLER
-- Bu tablo başka bir tabloya bağımlı olmadığı için direkt çalıştırabilirsiniz.
INSERT INTO public.services (name, icon_name, description, is_active) VALUES
('Temizlik', 'cleaning_services', 'Ev, ofis ve detaylı temizlik hizmetleri', true),
('Nakliyat', 'local_shipping', 'Evden eve eşya taşıma ve nakliye', true),
('Boya Badana', 'format_paint', 'İç ve dış cephe boya işleri', true),
('Elektrikçi', 'electrical_services', 'Elektrik tesisatı, arıza ve montaj', true),
('Tesisatçı', 'plumbing', 'Su tesisatı tamiri ve yenileme', true),
('Özel Ders', 'school', 'Matematik, İngilizce ve diğer özel dersler', true);


-- DİKKAT: AŞAĞIDAKİ KODLARI ÇALIŞTIRMADAN ÖNCE UYGULAMADAN EN AZ 2 KİŞİ KAYIT OLMALIDIR!
-- Biri "Hizmet Alan (Customer)", diğeri "Hizmet Veren (Provider)" gibi düşünebiliriz.
-- Kayıt olduğunuzda 'profiles' tablosuna otomatik olarak ekleneceksiniz.

DO $$
DECLARE
    customer_user_id UUID;
    provider_user_id UUID;
    service_id_temizlik UUID;
    service_id_boya UUID;
    req_id_1 UUID;
    req_id_2 UUID;
BEGIN
    -- İlk iki kullanıcıyı alalım (Eğer tablonuz boşsa hata verir, o yüzden önce uygulamadan kayıt olun)
    SELECT id INTO customer_user_id FROM public.profiles LIMIT 1;
    SELECT id INTO provider_user_id FROM public.profiles OFFSET 1 LIMIT 1;

    -- Eğer yeterli kullanıcı yoksa işlemi iptal et (sadece provider ve customer aynı kişi olur)
    IF provider_user_id IS NULL THEN
        provider_user_id := customer_user_id;
    END IF;

    IF customer_user_id IS NOT NULL THEN
        -- Servis ID'lerini bulalım
        SELECT id INTO service_id_temizlik FROM public.services WHERE name = 'Temizlik' LIMIT 1;
        SELECT id INTO service_id_boya FROM public.services WHERE name = 'Boya Badana' LIMIT 1;

        -- 2. TALEPLER (Requests) İÇİN ÖRNEK VERİLER
        INSERT INTO public.requests (customer_id, service_id, title, description, location, budget_range, status)
        VALUES 
        (customer_user_id, service_id_temizlik, '3+1 Ev Temizliği', 'Camlar ve kapılar silinecek, detaylı temizlik yapılacak.', 'Kadıköy, İstanbul', '1500 TL - 2000 TL', 'active')
        RETURNING id INTO req_id_1;

        INSERT INTO public.requests (customer_id, service_id, title, description, location, budget_range, status)
        VALUES 
        (customer_user_id, service_id_boya, 'Salon Boya Badana', 'Sadece salon boyanacak, boya bana ait.', 'Şişli, İstanbul', '3000 TL - 5000 TL', 'pending')
        RETURNING id INTO req_id_2;

        -- 3. TEKLİFLER (Offers) İÇİN ÖRNEK VERİLER
        INSERT INTO public.offers (request_id, provider_id, price, estimated_time, status)
        VALUES 
        (req_id_1, provider_user_id, 1800, '4-5 Saat', 'pending'),
        (req_id_1, provider_user_id, 1600, 'Yarım Gün', 'pending'),
        (req_id_2, provider_user_id, 3500, '1 Gün', 'accepted');

    END IF;
END $$;
