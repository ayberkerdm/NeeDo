import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../profile/data/providers/profile_provider.dart';
import '../../requests/data/providers/offers_provider.dart';
import '../../requests/data/providers/requests_provider.dart';

class ProviderDashboardScreen extends ConsumerWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final offersAsync = ref.watch(providerOffersProvider);
    final opportunitiesAsync = ref.watch(opportunitiesProvider);

    int completedCount = 0;
    int pendingCount = 0;
    double earnings = 0.0;

    offersAsync.whenData((offers) {
      for (var offer in offers) {
        if (offer.status == 'accepted') {
          completedCount++;
          earnings += offer.price;
        } else if (offer.status == 'pending') {
          pendingCount++;
        }
      }
    });

    int opportunitiesCount = opportunitiesAsync.when(
      data: (data) => data.length,
      loading: () => 0,
      error: (e, s) => 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usta Paneli'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {
            context.push('/notifications');
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWelcomeCard(profileAsync, opportunitiesCount),
            const SizedBox(height: AppSizes.p24),
            Text('İstatistikler (Tüm Zamanlar)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.p16),
            Row(
              children: [
                Expanded(child: _buildStatCard('Kazanç', '₺${earnings.toStringAsFixed(0)}', Icons.account_balance_wallet, AppColors.primary)),
                const SizedBox(width: AppSizes.p16),
                Expanded(child: _buildStatCard('Tamamlanan', '$completedCount İş', Icons.check_circle_outline, AppColors.secondary)),
              ],
            ),
            const SizedBox(height: AppSizes.p16),
            Row(
              children: [
                Expanded(child: _buildStatCard('Profil Puanı', profileAsync.value?['rating']?.toString() ?? '5.0', Icons.star_border, Colors.amber)),
                const SizedBox(width: AppSizes.p16),
                Expanded(child: _buildStatCard('Bekleyen Teklif', '$pendingCount', Icons.hourglass_bottom, Colors.orange)),
              ],
            ),
            const SizedBox(height: AppSizes.p32),
            Text('Yaklaşan İşler', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.p16),
            _buildUpcomingJobCard(offersAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(AsyncValue<Map<String, dynamic>?> profileAsync, int opportunitiesCount) {
    final name = profileAsync.value?['full_name'] ?? 'Usta';
    return Container(
      padding: const EdgeInsets.all(AppSizes.p24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: AppColors.primary, size: 30),
          ),
          const SizedBox(width: AppSizes.p16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Merhaba, $name', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Bölgende $opportunitiesCount yeni iş fırsatı var.', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(height: AppSizes.p12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildUpcomingJobCard(AsyncValue offersAsync) {
    return offersAsync.when(
      data: (offers) {
        final acceptedOffers = offers.where((o) => o.status == 'accepted').toList();
        if (acceptedOffers.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.p16),
              child: Text('Yaklaşan işiniz bulunmuyor.', style: TextStyle(color: AppColors.textHint)),
            ),
          );
        }
        
        final nextJob = acceptedOffers.first;
        return Card(
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
                      decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: const Text('Onaylandı', style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    Text(nextJob.requestService ?? 'Hizmet', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.textHint, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(nextJob.requestLocation ?? 'Belirtilmemiş', style: const TextStyle(color: AppColors.textSecondary))),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const SizedBox(),
    );
  }
}
