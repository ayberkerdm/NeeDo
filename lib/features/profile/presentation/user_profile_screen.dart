import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';
import 'package:go_router/go_router.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSizes.p24),
            const CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary,
              child: Text('A', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: AppSizes.p16),
            const Text('Ayberk K.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            const Text('+90 555 123 45 67', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: AppSizes.p32),
            _buildProfileMenuItem(Icons.location_on_outlined, 'Adreslerim'),
            const Divider(height: 1),
            _buildProfileMenuItem(Icons.payment_outlined, 'Ödeme Yöntemleri'),
            const Divider(height: 1),
            _buildProfileMenuItem(Icons.favorite_border, 'Favori Ustalarım'),
            const Divider(height: 1),
            _buildProfileMenuItem(Icons.notifications_outlined, 'Bildirim Ayarları'),
            const Divider(height: 1),
            _buildProfileMenuItem(Icons.help_outline, 'Yardım Merkezi'),
            const Divider(height: 1),
            const SizedBox(height: AppSizes.p32),
            TextButton.icon(
              onPressed: () {
                context.go('/provider-home');
              },
              icon: const Icon(Icons.cases_outlined, color: AppColors.primary),
              label: const Text('Usta Moduna Geç', style: TextStyle(color: AppColors.primary, fontSize: 16)),
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
