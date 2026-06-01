import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../data/providers/provider_profile_provider.dart';
import '../../auth/data/providers/auth_provider.dart';
import '../../badges/data/providers/badges_provider.dart';

class ProviderProfileScreen extends ConsumerStatefulWidget {
  final String providerId;
  const ProviderProfileScreen({super.key, required this.providerId});

  @override
  ConsumerState<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends ConsumerState<ProviderProfileScreen> {

  Future<void> _toggleFavorite(bool isFav) async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;
    
    try {
      await ref.read(favoriteServiceProvider).toggleFavorite(user.id, widget.providerId, isFav);
      ref.invalidate(isFavoriteProvider(widget.providerId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isFav ? 'Favorilerden çıkarıldı' : 'Favorilere eklendi')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.providerId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: const Center(child: Text('Usta bilgisi bulunamadı')),
      );
    }

    final profileAsync = ref.watch(providerProfileProvider(widget.providerId));
    final isFavAsync = ref.watch(isFavoriteProvider(widget.providerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uzman Profili'),
        actions: [
          isFavAsync.when(
            data: (isFav) => IconButton(
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null),
              onPressed: () => _toggleFavorite(isFav),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, __) => const SizedBox(),
          )
        ],
      ),
      body: profileAsync.when(
        data: (data) {
          final profile = data['profile'];
          final reviews = data['reviews'] as List;
          final completedCount = data['completed_count'];
          final reviewCount = data['review_count'];
          final rating = (profile['rating'] as num?)?.toDouble() ?? 0.0;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(context, profile),
                const Divider(height: 1),
                _buildStatsSection(rating, reviewCount, completedCount),
                const Divider(height: 1),
                _buildAboutSection(context, profile),
                const Divider(height: 1),
                _buildReviewsSection(context, reviews),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
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
                    final profileData = ref.read(providerProfileProvider(widget.providerId)).value?['profile'];
                    context.push('/chat', extra: {
                      'otherUserId': widget.providerId,
                      'otherUserName': profileData?['full_name'] ?? 'Usta'
                    });
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

  Widget _buildProfileHeader(BuildContext context, Map<String, dynamic> profile) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.p24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.border,
                backgroundImage: profile['avatar_url'] != null ? NetworkImage(profile['avatar_url']) : null,
                child: profile['avatar_url'] == null ? const Icon(Icons.person, size: 48, color: AppColors.textSecondary) : null,
              ),
              const CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white,
                child: Icon(Icons.verified, color: AppColors.secondary, size: 24),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.p16),
          Text(profile['full_name'] ?? 'İsimsiz Usta', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Profesyonel Hizmet', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildStatsSection(double rating, int reviewCount, int completedCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(rating.toStringAsFixed(1), 'Puan', icon: Icons.star, iconColor: Colors.amber),
          _buildStatItem(reviewCount.toString(), 'Yorum'),
          _buildStatItem('$completedCount', 'Tamamlanan'),
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

  Widget _buildAboutSection(BuildContext context, Map<String, dynamic> profile) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.p24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hakkında', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSizes.p12),
          Text(
            profile['description'] ?? 'Usta henüz bir açıklama eklemedi.',
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: AppSizes.p16),
          Consumer(
            builder: (context, ref, child) {
              final badgesAsync = ref.watch(providerBadgesProvider(widget.providerId));
              return badgesAsync.when(
                data: (badges) {
                  if (badges.isEmpty) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBadge('Güvenilir Profil', Icons.verified_user),
                      ],
                    );
                  }
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: badges.map((b) => _buildBadge(b['name'] ?? '', _getIconForBadge(b['icon_name']))).toList(),
                  );
                },
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              );
            },
          )
        ],
      ),
    );
  }

  IconData _getIconForBadge(String? iconName) {
    if (iconName == 'verified') return Icons.verified;
    if (iconName == 'speed') return Icons.speed;
    if (iconName == 'star') return Icons.star;
    if (iconName == 'thumb_up') return Icons.thumb_up;
    return Icons.emoji_events;
  }

  Widget _buildBadge(String text, IconData iconData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context, List reviews) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.p24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Son Yorumlar', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSizes.p16),
          if (reviews.isEmpty)
            const Text('Henüz yorum yapılmamış.', style: TextStyle(color: AppColors.textHint)),
          ...reviews.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildReviewItem(
              r['profiles']?['full_name'] ?? 'Bilinmeyen Müşteri', 
              r['comment'] ?? '', 
              (r['rating'] as num?)?.toInt() ?? 5
            ),
          )),
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
