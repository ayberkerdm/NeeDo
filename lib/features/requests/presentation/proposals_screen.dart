import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../data/providers/offers_provider.dart';
import '../data/models/offer_model.dart';
import '../../badges/data/providers/badges_provider.dart';

class ProposalsScreen extends ConsumerWidget {
  final String? requestId;
  const ProposalsScreen({super.key, this.requestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = requestId != null 
        ? ref.watch(requestOffersProvider(requestId!))
        : ref.watch(myAllOffersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelen Teklifler'),
      ),
      body: offersAsync.when(
        data: (offers) {
          if (offers.isEmpty) {
            return const Center(child: Text('Henüz teklif bulunmuyor.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.p16),
            itemCount: offers.length, 
            itemBuilder: (context, index) {
              return ProposalCard(offer: offers[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}

class ProposalCard extends ConsumerStatefulWidget {
  final OfferModel offer;
  const ProposalCard({super.key, required this.offer});

  @override
  ConsumerState<ProposalCard> createState() => _ProposalCardState();
}

class _ProposalCardState extends ConsumerState<ProposalCard> {
  bool _isLoading = false;
  bool _isRejecting = false;
  bool _isCountering = false;

  void _showCounterOfferDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Karşı Teklif Ver'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Bütçeniz (₺)',
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
                setState(() => _isCountering = true);
                try {
                  await ref.read(offerServiceProvider).customerCounterOffer(widget.offer.id, price);
                  ref.invalidate(myAllOffersProvider);
                  ref.invalidate(requestOffersProvider(widget.offer.requestId));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Karşı teklifiniz iletildi!')));
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
                  }
                } finally {
                  if (mounted) setState(() => _isCountering = false);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Gönder', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.p16),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.border,
                  child: Icon(Icons.person, color: AppColors.textSecondary, size: 30),
                ),
                const SizedBox(width: AppSizes.p16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.offer.providerName ?? 'Bilinmeyen Usta', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text('${widget.offer.providerRating ?? 0.0}'),
                        ],
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          final badgesAsync = ref.watch(providerBadgesProvider(widget.offer.providerId));
                          return badgesAsync.when(
                            data: (badges) {
                              if (badges.isEmpty) return const SizedBox.shrink();
                              return Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: badges.take(2).map((b) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(b['name'] ?? '', style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                )).toList(),
                              );
                            },
                            loading: () => const SizedBox(),
                            error: (_, __) => const SizedBox(),
                          );
                        },
                      ),
                      if (widget.offer.estimatedTime != null) ...[
                        const SizedBox(height: 4),
                        Text('Tahmini Süre: ${widget.offer.estimatedTime}', style: Theme.of(context).textTheme.bodySmall),
                      ]
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${widget.offer.price} TL', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ],
            ),
            if (widget.offer.customerCounterPrice != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.handshake, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Karşı teklifiniz iletildi: ${widget.offer.customerCounterPrice} ₺ (Ustanın yanıtı bekleniyor)',
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Divider(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                PrimaryButton(
                  text: 'Teklifi Onayla',
                  isLoading: _isLoading,
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    try {
                      await ref.read(offerServiceProvider).acceptOffer(widget.offer.id, widget.offer.requestId);
                      ref.invalidate(myAllOffersProvider);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Teklif onaylandı! İş aktif hale geldi.')));
                        context.pop();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
                      }
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
                ),
                PrimaryButton(
                  text: 'Reddet',
                  isLoading: _isRejecting,
                  onPressed: () async {
                    setState(() => _isRejecting = true);
                    try {
                      await ref.read(offerServiceProvider).rejectOffer(widget.offer.id);
                      ref.invalidate(myAllOffersProvider);
                      // Invalidate specific request provider too
                      ref.invalidate(requestOffersProvider(widget.offer.requestId));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Teklif reddedildi.')));
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
                      }
                    } finally {
                      if (mounted) setState(() => _isRejecting = false);
                    }
                  },
                  isSecondary: true,
                ),
                PrimaryButton(
                  text: 'Karşı Teklif Ver',
                  isLoading: _isCountering,
                  isSecondary: true,
                  onPressed: _showCounterOfferDialog,
                ),
                PrimaryButton(
                  text: 'Mesaj Gönder',
                  isSecondary: true,
                  onPressed: () {
                    context.push('/chat', extra: {
                      'otherUserId': widget.offer.providerId,
                      'otherUserName': widget.offer.providerName ?? 'Usta'
                    });
                  },
                ),
                PrimaryButton(
                  text: 'Profili İncele',
                  isSecondary: true,
                  onPressed: () {
                    context.push('/provider-profile', extra: {'providerId': widget.offer.providerId});
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
