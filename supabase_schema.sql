-- Temel Tablolar: profiles, services, requests, offers, messages

-- 1. Profiles Tablosu (Kullanıcılar)
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL PRIMARY KEY,
  full_name TEXT,
  phone TEXT,
  role TEXT DEFAULT 'customer' CHECK (role IN ('customer', 'provider')),
  rating NUMERIC DEFAULT 0.0,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- RLS (Row Level Security) ayarları
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public profiles are viewable by everyone." ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can insert their own profile." ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile." ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- 2. Services Tablosu (Kategoriler / Hizmetler)
CREATE TABLE public.services (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  icon_name TEXT,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Services are viewable by everyone." ON public.services FOR SELECT USING (true);
-- (Sadece admin ekleyebilir mantığı ileride eklenebilir)

-- 3. Requests Tablosu (Talepler)
CREATE TABLE public.requests (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  customer_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  service_id UUID REFERENCES public.services(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT,
  location TEXT,
  budget_range TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'completed', 'cancelled')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.requests ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Requests are viewable by everyone." ON public.requests FOR SELECT USING (true);
CREATE POLICY "Customers can insert their own requests." ON public.requests FOR INSERT WITH CHECK (auth.uid() = customer_id);
CREATE POLICY "Anyone can update requests." ON public.requests FOR UPDATE USING (auth.uid() IS NOT NULL);

-- 4. Offers Tablosu (Teklifler)
CREATE TABLE public.offers (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  request_id UUID REFERENCES public.requests(id) ON DELETE CASCADE NOT NULL,
  provider_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  price NUMERIC NOT NULL,
  customer_counter_price NUMERIC,
  estimated_time TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.offers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Offers are viewable by request owner and provider." ON public.offers FOR SELECT USING (
  auth.uid() = provider_id OR 
  auth.uid() IN (SELECT customer_id FROM public.requests WHERE id = request_id)
);
CREATE POLICY "Providers can insert offers." ON public.offers FOR INSERT WITH CHECK (auth.uid() = provider_id);
CREATE POLICY "Users can update offers if they own the request or are the provider." ON public.offers FOR UPDATE USING (
  auth.uid() = provider_id OR 
  auth.uid() IN (SELECT customer_id FROM public.requests WHERE id = request_id)
);

-- 5. Messages Tablosu (Mesajlaşma)
CREATE TABLE public.messages (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  sender_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  receiver_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  request_id UUID REFERENCES public.requests(id) ON DELETE SET NULL,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own messages." ON public.messages FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = receiver_id);
CREATE POLICY "Users can insert messages as sender." ON public.messages FOR INSERT WITH CHECK (auth.uid() = sender_id);

-- Trigger: Yeni kullanıcı kayıt olduğunda profiles tablosuna ekle
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (new.id, new.raw_user_meta_data->>'full_name', COALESCE(new.raw_user_meta_data->>'role', 'customer'));
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- YENI EKLENEN TABLOLAR (Aşama 1)

-- 6. Reviews Tablosu (Değerlendirmeler)
CREATE TABLE public.reviews (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  request_id UUID REFERENCES public.requests(id) ON DELETE CASCADE NOT NULL UNIQUE,
  provider_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  customer_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  rating NUMERIC(2,1) CHECK (rating >= 1.0 AND rating <= 5.0) NOT NULL,
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Reviews are viewable by everyone." ON public.reviews FOR SELECT USING (true);
CREATE POLICY "Customers can insert reviews for their own requests." ON public.reviews FOR INSERT WITH CHECK (auth.uid() = customer_id);

-- 7. Favorites Tablosu (Favori Ustalar)
CREATE TABLE public.favorites (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  customer_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  provider_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(customer_id, provider_id)
);

ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Customers can view their own favorites." ON public.favorites FOR SELECT USING (auth.uid() = customer_id);
CREATE POLICY "Customers can insert their own favorites." ON public.favorites FOR INSERT WITH CHECK (auth.uid() = customer_id);
CREATE POLICY "Customers can delete their own favorites." ON public.favorites FOR DELETE USING (auth.uid() = customer_id);

-- 8. Notifications Tablosu (Bildirim Merkezi)
CREATE TABLE public.notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own notifications." ON public.notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update their own notifications (read)." ON public.notifications FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Anyone can insert notifications." ON public.notifications FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- 9. Portfolios Tablosu (Usta Portfolyosu)
CREATE TABLE public.portfolios (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  provider_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT,
  before_image_url TEXT,
  after_image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.portfolios ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Portfolios are viewable by everyone." ON public.portfolios FOR SELECT USING (true);
CREATE POLICY "Providers can insert their own portfolios." ON public.portfolios FOR INSERT WITH CHECK (auth.uid() = provider_id);
CREATE POLICY "Providers can update their own portfolios." ON public.portfolios FOR UPDATE USING (auth.uid() = provider_id);
CREATE POLICY "Providers can delete their own portfolios." ON public.portfolios FOR DELETE USING (auth.uid() = provider_id);

-- 10. Certificates Tablosu (Usta Sertifikaları)
CREATE TABLE public.certificates (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  provider_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  file_url TEXT NOT NULL,
  issue_date DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.certificates ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Certificates are viewable by everyone." ON public.certificates FOR SELECT USING (true);
CREATE POLICY "Providers can insert their own certificates." ON public.certificates FOR INSERT WITH CHECK (auth.uid() = provider_id);
CREATE POLICY "Providers can delete their own certificates." ON public.certificates FOR DELETE USING (auth.uid() = provider_id);

-- 11. Service Areas Tablosu (Hizmet Bölgeleri)
CREATE TABLE public.service_areas (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  provider_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  city TEXT NOT NULL,
  district TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(provider_id, city, district)
);

ALTER TABLE public.service_areas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Service areas are viewable by everyone." ON public.service_areas FOR SELECT USING (true);
CREATE POLICY "Providers can insert their own service areas." ON public.service_areas FOR INSERT WITH CHECK (auth.uid() = provider_id);
CREATE POLICY "Providers can delete their own service areas." ON public.service_areas FOR DELETE USING (auth.uid() = provider_id);

-- 12. Earnings Tablosu (Kazanç Analizi)
CREATE TABLE public.earnings (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  provider_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  request_id UUID REFERENCES public.requests(id) ON DELETE SET NULL,
  amount NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.earnings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Providers can view their own earnings." ON public.earnings FOR SELECT USING (auth.uid() = provider_id);
CREATE POLICY "Providers can insert their own earnings." ON public.earnings FOR INSERT WITH CHECK (auth.uid() = provider_id);

-- 13. Badges & User Badges (Rozet Sistemi)
CREATE TABLE public.badges (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  icon_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.badges ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Badges are viewable by everyone." ON public.badges FOR SELECT USING (true);
-- Badges sadece admin tarafından eklenebilir.

CREATE TABLE public.user_badges (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  provider_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  badge_id UUID REFERENCES public.badges(id) ON DELETE CASCADE NOT NULL,
  earned_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(provider_id, badge_id)
);

ALTER TABLE public.user_badges ENABLE ROW LEVEL SECURITY;
CREATE POLICY "User badges are viewable by everyone." ON public.user_badges FOR SELECT USING (true);
-- User badges triggerlar veya admin fonksiyonlarıyla eklenebilir, şimdilik insert policy eklendi:
CREATE POLICY "Providers can insert user badges." ON public.user_badges FOR INSERT WITH CHECK (auth.uid() = provider_id);

-- AŞAMA 2 EKLENTİSİ (Mesajlaşma dosya paylaşımı)
ALTER TABLE public.messages ADD COLUMN IF NOT EXISTS file_url TEXT;

-- Realtime Ayarları (Mesajlar ve Bildirimler için)
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;

-- 11. Değerlendirme (Rating) Güncelleme Trigger'ı
CREATE OR REPLACE FUNCTION public.update_provider_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.profiles
  SET rating = (
    SELECT COALESCE(ROUND(AVG(rating), 1), 0.0)
    FROM public.reviews
    WHERE provider_id = NEW.provider_id
  )
  WHERE id = NEW.provider_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_review_inserted ON public.reviews;
CREATE TRIGGER on_review_inserted
AFTER INSERT OR UPDATE ON public.reviews
FOR EACH ROW EXECUTE FUNCTION public.update_provider_rating();

