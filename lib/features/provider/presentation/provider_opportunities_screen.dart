import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';
import '../../requests/data/providers/requests_provider.dart';
import '../../requests/data/models/request_model.dart';

class ProviderOpportunitiesScreen extends ConsumerWidget {
  const ProviderOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunitiesAsync = ref.watch(opportunitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Fırsatlar'),
      ),
      body: opportunitiesAsync.when(
        data: (opportunities) {
          if (opportunities.isEmpty) {
            return const Center(child: Text('Şu an yeni bir fırsat bulunmuyor.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.p16),
            itemCount: opportunities.length,
            itemBuilder: (context, index) {
              return OpportunityCard(request: opportunities[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Bir hata oluştu: $err')),
      ),
    );
  }
}

class OpportunityCard extends StatelessWidget {
  final RequestModel request;
  
  const OpportunityCard({super.key, required this.request});

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
                const Text('Yeni', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
              ],
            ),
            const SizedBox(height: AppSizes.p12),
            Text(request.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: AppSizes.p12),
            if (request.location != null)
              _buildDetailRow(Icons.location_on, request.location!),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.calendar_month, '${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}'),
            const Divider(height: 32),
            PrimaryButton(
              text: 'Detayları İncele & Teklif Ver',
              onPressed: () {
                context.push('/submit-proposal', extra: request);
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
