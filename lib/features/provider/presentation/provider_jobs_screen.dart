import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';

class ProviderJobsScreen extends StatelessWidget {
  const ProviderJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('İşlerim'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textHint,
            tabs: [
              Tab(text: 'Aktif İşler'),
              Tab(text: 'Geçmiş İşler'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ActiveJobsTab(),
            _PastJobsTab(),
          ],
        ),
      ),
    );
  }
}

class _ActiveJobsTab extends StatelessWidget {
  const _ActiveJobsTab();
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.p16),
      itemCount: 1,
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
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
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Randevu Onaylandı',
                        style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Text('12 Mayıs 2026', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: AppSizes.p12),
                const Text('Ev Temizliği (Ayberk K.)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                const Text('Atatürk Mah. İstiklal Cad. No:12 Kat:4', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                const Divider(height: 24),
                const Row(
                  children: [
                    Icon(Icons.map, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text('Haritada Gör', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PastJobsTab extends StatelessWidget {
  const _PastJobsTab();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Geçmiş tamamlanmış işiniz bulunmuyor.', style: TextStyle(color: AppColors.textHint)));
  }
}
