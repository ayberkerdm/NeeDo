import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../requests/data/providers/offers_provider.dart';
import '../../requests/data/models/offer_model.dart';

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

class _ActiveJobsTab extends ConsumerWidget {
  const _ActiveJobsTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(providerOffersProvider);
    
    return offersAsync.when(
      data: (offers) {
        final activeOffers = offers.where((o) => o.requestStatus != 'completed').toList();
        
        if (activeOffers.isEmpty) {
          return const Center(child: Text('Aktif teklifiniz/işiniz bulunmuyor.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.p16),
          itemCount: activeOffers.length,
          itemBuilder: (context, index) {
            final offer = activeOffers[index];
            return _ActiveJobCard(offer: offer);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Hata oluştu: $err')),
    );
  }
}

class _PastJobsTab extends ConsumerWidget {
  const _PastJobsTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(providerOffersProvider);
    
    return offersAsync.when(
      data: (offers) {
        final pastOffers = offers.where((o) => o.requestStatus == 'completed').toList();
        
        if (pastOffers.isEmpty) {
          return const Center(child: Text('Geçmiş tamamlanmış işiniz bulunmuyor.', style: TextStyle(color: AppColors.textHint)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.p16),
          itemCount: pastOffers.length,
          itemBuilder: (context, index) {
            final offer = pastOffers[index];
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
                          child: const Text('Tamamlandı', style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        Text('${offer.createdAt.day}/${offer.createdAt.month}/${offer.createdAt.year}', style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: AppSizes.p12),
                    Text('${offer.requestService ?? "Talep"} - ${offer.price} ₺', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Hata oluştu: $err')),
    );
  }
}

class _ActiveJobCard extends ConsumerStatefulWidget {
  final OfferModel offer;
  const _ActiveJobCard({required this.offer});

  @override
  ConsumerState<_ActiveJobCard> createState() => _ActiveJobCardState();
}

class _ActiveJobCardState extends ConsumerState<_ActiveJobCard> {
  bool _isLoading = false;

  void _showUpdatePriceDialog() {
    final controller = TextEditingController(text: widget.offer.price.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Fiyatı Güncelle'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Yeni Teklifiniz (₺)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final price = double.tryParse(controller.text);
                if (price == null || price <= 0) return;
                
                Navigator.pop(ctx);
                setState(() => _isLoading = true);
                try {
                  await ref.read(offerServiceProvider).providerUpdatePrice(widget.offer.id, price);
                  ref.invalidate(providerOffersProvider);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fiyat güncellendi ve müşteriye iletildi!')));
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
                  }
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Güncelle', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _acceptCounterOffer() async {
    setState(() => _isLoading = true);
    try {
      // Müşterinin fiyatını teklif fiyatı yapıp kabul et
      await ref.read(offerServiceProvider).providerUpdatePrice(widget.offer.id, widget.offer.customerCounterPrice!);
      await ref.read(offerServiceProvider).acceptOffer(widget.offer.id, widget.offer.requestId);
      ref.invalidate(providerOffersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Karşı teklif kabul edildi ve iş onaylandı!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: InkWell(
        onTap: widget.offer.status == 'accepted' ? () {
          context.push('/provider-job-detail', extra: {'offer': widget.offer});
        } : null,
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
                      color: widget.offer.status == 'accepted' ? AppColors.secondary.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.offer.status == 'accepted' ? 'Onaylandı' : 'Teklif Verildi',
                      style: TextStyle(
                        color: widget.offer.status == 'accepted' ? AppColors.secondary : AppColors.primary, 
                        fontSize: 12, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  Text('${widget.offer.createdAt.day}/${widget.offer.createdAt.month}/${widget.offer.createdAt.year}', style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                ],
              ),
              const SizedBox(height: AppSizes.p12),
              Text('${widget.offer.requestService ?? "Talep"} - ${widget.offer.price} ₺', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              if (widget.offer.requestLocation != null)
                Text(widget.offer.requestLocation!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              
              if (widget.offer.status == 'pending' && widget.offer.customerCounterPrice != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.handshake, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Müşteri Karşı Teklif Yaptı: ${widget.offer.customerCounterPrice} ₺',
                              style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _acceptCounterOffer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Kabul Et', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _showUpdatePriceDialog,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                ),
                                child: const Text('Fiyatı Güncelle', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
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
      ),
    );
  }
}
