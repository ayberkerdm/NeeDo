import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/primary_button.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uzman Profili'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            const Divider(height: 1),
            _buildStatsSection(),
            const Divider(height: 1),
            _buildAboutSection(context),
            const Divider(height: 1),
            _buildGallerySection(context),
            const Divider(height: 1),
            _buildReviewsSection(context),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  text: 'Mesaj Gönder',
                  isSecondary: true,
                  onPressed: () {
                    context.push('/chat');
                  },
                ),
              ),
              const SizedBox(width: AppSizes.p16),
              Expanded(
                child: PrimaryButton(
                  text: 'Teklif İste',
                  onPressed: () {
                    context.push('/create-request');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.p24),
      child: Column(
        children: [
          const Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.border,
                child: Icon(Icons.person, size: 48, color: AppColors.textSecondary),
              ),
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white,
                child: Icon(Icons.verified, color: AppColors.secondary, size: 24),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.p16),
          Text('Ahmet Usta', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Profesyonel Ev Temizliği', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('4.9', 'Puan', icon: Icons.star, iconColor: Colors.amber),
          _buildStatItem('124', 'Yorum'),
          _buildStatItem('340+', 'Tamamlanan'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {IconData? icon, Color? iconColor}) {
    return Column(
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 4),
            ],
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.p24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hakkında', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSizes.p12),
          const Text(
            '10 yılı aşkın süredir profesyonel ev temizliği, inşaat sonrası temizlik ve ofis temizliği alanında hizmet veriyorum. Müşteri memnuniyeti ve güven benim için önceliktir.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: AppSizes.p16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge('Sertifikalı Personel'),
              _buildBadge('Hızlı Yanıt Verme'),
              _buildBadge('Güvenilir Profil'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildGallerySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.p24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Galeri', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const Text('Tümünü Gör', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: AppSizes.p16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.image, color: AppColors.textHint, size: 30),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.p24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Son Yorumlar', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSizes.p16),
          _buildReviewItem('Meltem T.', 'Evimi pırıl pırıl yaptılar. Zamanında geldiler ve çok titiz çalıştılar. Kesinlikle tavsiye ederim.', 5),
          const SizedBox(height: AppSizes.p16),
          _buildReviewItem('Can K.', 'Ellerine sağlık Ahmet usta. Fiyat/performans olarak mükemmel bir hizmet.', 5),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String name, String content, int rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            Row(
              children: List.generate(5, (index) => Icon(
                index < rating ? Icons.star : Icons.star_border, 
                size: 16, 
                color: Colors.amber
              )),
            )
          ],
        ),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
      ],
    );
  }
}
