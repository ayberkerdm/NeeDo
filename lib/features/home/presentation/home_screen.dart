import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../categories/data/providers/services_provider.dart';
import '../data/providers/customer_stats_provider.dart';
import '../../auth/data/providers/auth_provider.dart';
import '../../notifications/data/services/notification_service.dart';
import '../../notifications/data/models/notification_model.dart';
import '../../profile/data/providers/profile_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, ref),
              _buildDynamicStats(context, ref),
              _buildSearchBar(context),
              _buildRecentActivities(ref),
              _buildCampaignBanner(context),
              _buildSectionTitle(context, 'Popüler Kategoriler', onSeeAll: () {}),
              _buildCategoryChips(ref),
              _buildSectionTitle(context, 'En Çok Tercih Edilenler'),
              _buildPopularServices(ref),
              const SizedBox(height: AppSizes.p32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(profileProvider);
    final name = userProfile.value?['full_name']?.split(' ')[0] ?? 'Müşteri';
    
    return Padding(
      padding: const EdgeInsets.all(AppSizes.p24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Günaydın, $name! 👋',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Bugün hangi hizmete ihtiyacın var?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  context.push('/notifications');
                },
                icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                radius: 24,
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Hizmet ara (Örn: Boya badana, temizlik...)',
          prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.p24),
      padding: const EdgeInsets.all(AppSizes.p24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'İlk Hizmetine Özel %20 İndirim!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hemen teklif al, indirimi yakala.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_offer, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('Tümünü Gör', style: TextStyle(color: AppColors.primary)),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);

    return servicesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p8),
            child: Text('Henüz kategori bulunmuyor.'),
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p8),
          child: Row(
            children: categories.map((cat) {
              return Container(
                margin: const EdgeInsets.only(right: AppSizes.p16),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.handyman, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat.name,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSizes.p24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Text('Hata: $error'),
      ),
    );
  }

  Widget _buildPopularServices(WidgetRef ref) {
    final popularAsync = ref.watch(popularServicesProvider);

    return popularAsync.when(
      data: (services) {
        if (services.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.p24),
            child: Text('Popüler hizmet bulunmuyor.'),
          );
        }
        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p8),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: AppSizes.p16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusMedium - 1)),
                        ),
                        child: const Icon(Icons.image, color: AppColors.textHint, size: 40),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.p12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text('4.8', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Hata: $error')),
    );
  }

  Widget _buildDynamicStats(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(customerStatsProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p16),
      child: statsAsync.when(
        data: (stats) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Aktif', stats['active_jobs'].toString(), Icons.handyman, AppColors.primary, onTap: () => context.push('/requests')),
              _buildStatItem('Teklif', stats['pending_offers'].toString(), Icons.local_offer, Colors.orange, onTap: () => context.push('/proposals')),
              _buildStatItem('Biten', stats['completed_jobs'].toString(), Icons.check_circle, AppColors.secondary, onTap: () => context.push('/requests')),
              _buildStatItem('Favori', stats['favorites'].toString(), Icons.favorite, Colors.red, onTap: () {}), // we don't have favorites screen yet
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Text('Hata: $e'),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.p12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    if (user == null) return const SizedBox();

    final notificationService = ref.watch(notificationServiceProvider);

    return StreamBuilder<List<NotificationModel>>(
      stream: notificationService.getNotificationsStream(user.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();
        
        final latest = snapshot.data!.take(2).toList(); // Show max 2
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Son Aktiviteler', onSeeAll: () {
              context.push('/notifications');
            }),
            ...latest.map((n) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.p24),
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                child: const Icon(Icons.notifications, color: AppColors.primary),
              ),
              title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(n.message, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
            )).toList(),
          ],
        );
      },
    );
  }
}
