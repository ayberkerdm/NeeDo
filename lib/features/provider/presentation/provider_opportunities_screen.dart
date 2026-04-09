import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';

class ProviderOpportunitiesScreen extends StatelessWidget {
  const ProviderOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Fırsatlar'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.p16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return const OpportunityCard();
        },
      ),
    );
  }
}

class OpportunityCard extends StatelessWidget {
  const OpportunityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.p16),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: const Text('Yeni Talep', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const Text('5 dk önce', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
              ],
            ),
            const SizedBox(height: AppSizes.p12),
            const Text('Derinlemesine Ev Temizliği (Boş Ev)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: AppSizes.p12),
            _buildDetailRow(Icons.location_on, 'Ataşehir, İstanbul (Sana 4 km uzakta)'),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.calendar_month, '15 Mayıs 2026, Cuma - Esnek Zaman'),
            const Divider(height: 32),
            PrimaryButton(
              text: 'Detayları İncele & Teklif Ver',
              onPressed: () {
                context.push('/submit-proposal');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
      ],
    );
  }
}
