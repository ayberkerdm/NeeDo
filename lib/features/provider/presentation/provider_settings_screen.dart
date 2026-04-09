import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';
import 'package:go_router/go_router.dart';

class ProviderSettingsScreen extends StatelessWidget {
  const ProviderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usta Profili'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSizes.p24),
            const CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.handyman, color: Colors.white, size: 40),
            ),
            const SizedBox(height: AppSizes.p16),
            const Text('Ahmet Usta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            const Text('Temizlik Uzmanı', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: AppSizes.p32),
            _buildProfileMenuItem(Icons.business_center_outlined, 'Hizmet Bölgelerim'),
            const Divider(height: 1),
            _buildProfileMenuItem(Icons.monetization_on_outlined, 'Gelir & Ödeme Ayarları'),
            const Divider(height: 1),
            _buildProfileMenuItem(Icons.star_outline, 'Müşteri Değerlendirmeleri'),
            const Divider(height: 1),
            _buildProfileMenuItem(Icons.collections_outlined, 'Portfolyo & Galeri'),
            const Divider(height: 1),
            const SizedBox(height: AppSizes.p32),
            TextButton.icon(
              onPressed: () {
                context.go('/home');
              },
              icon: const Icon(Icons.person_outline, color: AppColors.primary),
              label: const Text('Müşteri Moduna Dön', style: TextStyle(color: AppColors.primary, fontSize: 16)),
            ),
            const SizedBox(height: AppSizes.p16),
            TextButton.icon(
              onPressed: () {
                context.go('/login');
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text('Çıkış Yap', style: TextStyle(color: AppColors.error, fontSize: 16)),
            ),
            const SizedBox(height: AppSizes.p32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: () {},
    );
  }
}
