import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';
import 'package:go_router/go_router.dart';

class RequestsListScreen extends StatelessWidget {
  const RequestsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Taleplerim'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textHint,
            tabs: [
              Tab(text: 'Aktif'),
              Tab(text: 'Bekleyen'),
              Tab(text: 'Geçmiş'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ActiveRequestsTab(),
            _PendingRequestsTab(),
            _PastRequestsTab(),
          ],
        ),
      ),
    );
  }
}

class _ActiveRequestsTab extends StatelessWidget {
  const _ActiveRequestsTab();

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
          child: InkWell(
            onTap: () {
              context.push('/appointment-tracking');
            },
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
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
                          'Yolda',
                          style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Text('12 Mayıs 2026', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p12),
                  const Text('Ev Temizliği', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text('Hizmet Veren: Ahmet Usta', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  const Divider(height: 24),
                  const Row(
                    children: [
                      Text('Detayları Gör', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      Icon(Icons.chevron_right, color: AppColors.primary, size: 20),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PendingRequestsTab extends StatelessWidget {
  const _PendingRequestsTab();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Bekleyen talep bulunmuyor', style: TextStyle(color: AppColors.textHint)));
  }
}

class _PastRequestsTab extends StatelessWidget {
  const _PastRequestsTab();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Geçmiş talep bulunmuyor', style: TextStyle(color: AppColors.textHint)));
  }
}
