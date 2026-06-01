import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';
import 'package:go_router/go_router.dart';
import '../data/providers/requests_provider.dart';
import '../data/models/request_model.dart';

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
            _RequestsList(statusFilter: 'active'),
            _RequestsList(statusFilter: 'pending'),
            _RequestsList(statusFilter: 'past'),
          ],
        ),
      ),
    );
  }
}

class _RequestsList extends ConsumerWidget {
  final String statusFilter;
  const _RequestsList({required this.statusFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(myRequestsProvider);

    return requestsAsync.when(
      data: (requests) {
        final filtered = requests.where((r) {
          if (statusFilter == 'active') return r.status == 'active';
          if (statusFilter == 'pending') return r.status == 'pending';
          if (statusFilter == 'past') return r.status == 'completed' || r.status == 'cancelled';
          return false;
        }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('Bu kategoride talep bulunmuyor', style: TextStyle(color: AppColors.textHint)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.p16),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final req = filtered[index];
            
            // Format date manually
            final dateStr = '${req.createdAt.day}/${req.createdAt.month}/${req.createdAt.year}';

            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: AppSizes.p16),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              child: InkWell(
                onTap: () {
                  if (req.status == 'pending') {
                    context.push('/proposals', extra: {'requestId': req.id});
                  } else {
                    context.push('/appointment-tracking', extra: {'requestId': req.id});
                  }
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
                              color: statusFilter == 'active' ? AppColors.secondary.withOpacity(0.1) : AppColors.textHint.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              req.status.toUpperCase(),
                              style: TextStyle(
                                color: statusFilter == 'active' ? AppColors.secondary : AppColors.textSecondary, 
                                fontSize: 12, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Text(dateStr, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: AppSizes.p12),
                      Text(req.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Hizmet: ${req.serviceName ?? 'Bilinmiyor'}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      if (req.budgetRange != null) ...[
                        const SizedBox(height: 4),
                        Text('Bütçe: ${req.budgetRange}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      ],
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Text('Detayları Gör', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                              Icon(Icons.chevron_right, color: AppColors.primary, size: 20),
                            ],
                          ),
                          if (statusFilter == 'past' && req.status == 'completed')
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(120, 32),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              onPressed: () {
                                context.push('/review', extra: {
                                  'requestId': req.id,
                                  'serviceName': req.serviceName ?? 'Hizmet',
                                });
                              },
                              child: const Text('Değerlendir'),
                            )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
    );
  }
}

