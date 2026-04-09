import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/primary_button.dart';

class AppointmentTrackingScreen extends StatelessWidget {
  const AppointmentTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hizmet Takibi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(context),
            const SizedBox(height: AppSizes.p24),
            _buildProviderDetails(context),
            const SizedBox(height: AppSizes.p24),
            _buildServiceDetails(context),
            const SizedBox(height: AppSizes.p32),
            PrimaryButton(
              text: 'Destek Al',
              isSecondary: true,
              onPressed: () {},
            ),
            const SizedBox(height: AppSizes.p16),
            TextButton(
              onPressed: () {},
              child: const Text('İptal Et / Yeniden Planla', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.airport_shuttle, color: AppColors.secondary, size: 40),
          ),
          const SizedBox(height: AppSizes.p16),
          Text('Usta Yolda', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.secondary)),
          const SizedBox(height: 8),
          const Text('Tahmini varış: 15 dakika', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildProviderDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hizmet Veren', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSizes.p12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.border,
            child: Icon(Icons.person, color: AppColors.textSecondary),
          ),
          title: const Text('Ahmet Usta', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('4.9/5Puan • Ev Temizliği Uzmanı'),
          trailing: IconButton(
            icon: const Icon(Icons.phone, color: AppColors.primary),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildServiceDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hizmet Detayları', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSizes.p16),
        _buildDetailRow(Icons.calendar_month, '12 Mayıs 2026, 14:00'),
        const SizedBox(height: AppSizes.p12),
        _buildDetailRow(Icons.location_on, 'Atatürk Mah. İstiklal Cad. No:12 Kat:4'),
        const SizedBox(height: AppSizes.p12),
        _buildDetailRow(Icons.confirmation_num_outlined, 'Talep Kodu: #ND-4291'),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textHint, size: 20),
        const SizedBox(width: AppSizes.p12),
        Expanded(child: Text(text, style: const TextStyle(color: AppColors.textPrimary))),
      ],
    );
  }
}
