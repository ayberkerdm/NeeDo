import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../data/providers/requests_provider.dart';
import '../data/models/request_model.dart';
import '../data/models/offer_model.dart';
import '../data/providers/reviews_provider.dart';
import '../../auth/data/providers/auth_provider.dart';

class AppointmentTrackingScreen extends ConsumerStatefulWidget {
  final String requestId;
  const AppointmentTrackingScreen({super.key, required this.requestId});

  @override
  ConsumerState<AppointmentTrackingScreen> createState() => _AppointmentTrackingScreenState();
}

class _AppointmentTrackingScreenState extends ConsumerState<AppointmentTrackingScreen> {
  bool _hasShownReviewPopup = false;

  void _showReviewDialog(BuildContext context, String providerId, String customerId) {
    int rating = 5;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ustayı Değerlendir', textAlign: TextAlign.center),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Aldığınız hizmetten ne kadar memnun kaldınız?', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() => rating = index + 1);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Yorumunuz (İsteğe bağlı)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                  child: const Text('Daha Sonra', style: TextStyle(color: AppColors.textHint)),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setState(() => isSubmitting = true);
                          try {
                            await ref.read(reviewServiceProvider).submitReview(
                                  requestId: widget.requestId,
                                  providerId: providerId,
                                  customerId: customerId,
                                  rating: rating.toDouble(),
                                  comment: commentController.text,
                                );
                            ref.invalidate(hasReviewedProvider(widget.requestId));
                            if (mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Değerlendirmeniz için teşekkürler!')));
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
                            }
                          } finally {
                            if (mounted) setState(() => isSubmitting = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: isSubmitting 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text('Gönder', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(activeRequestDetailsProvider(widget.requestId));
    final hasReviewedAsync = ref.watch(hasReviewedProvider(widget.requestId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hizmet Takibi'),
      ),
      body: detailsAsync.when(
        data: (details) {
          if (details == null) {
            return const Center(child: Text('Talep bulunamadı.'));
          }

          final request = details['request'] as RequestModel;
          final offer = details['offer'] as OfferModel?;
          final customer = ref.read(authServiceProvider).currentUser;

          final hasReviewed = hasReviewedAsync.value ?? false;

          // Automatically show popup if completed and not reviewed yet
          if (request.status == 'completed' && !hasReviewed && !_hasShownReviewPopup && offer != null && customer != null) {
            _hasShownReviewPopup = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showReviewDialog(context, offer.providerId, customer.id);
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.p24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatusCard(context, request, offer),
                const SizedBox(height: AppSizes.p24),
                if (offer != null) ...[
                  _buildProviderDetails(context, offer),
                  const SizedBox(height: AppSizes.p24),
                ],
                _buildServiceDetails(context, request),
                const SizedBox(height: AppSizes.p32),
                
                if (request.status == 'completed' && !hasReviewed && offer != null && customer != null)
                  PrimaryButton(
                    text: 'Ustayı Değerlendir',
                    onPressed: () => _showReviewDialog(context, offer.providerId, customer.id),
                  )
                else if (request.status != 'completed') ...[
                  PrimaryButton(
                    text: 'Destek Al',
                    isSecondary: true,
                    onPressed: () {},
                  ),
                  const SizedBox(height: AppSizes.p16),
                  TextButton(
                    onPressed: () {},
                    child: const Text('İptal Et / Yeniden Planla', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, RequestModel request, OfferModel? offer) {
    String statusText = 'Hazırlanıyor';
    String estimatedText = '';

    if (request.status == 'active') {
      statusText = 'Usta Yolda';
      estimatedText = offer?.estimatedTime != null ? 'Tahmini süre: ${offer!.estimatedTime}' : 'Hizmet onaylandı.';
    } else if (request.status == 'completed') {
      statusText = 'Tamamlandı';
      estimatedText = 'Hizmet başarıyla tamamlandı.';
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.p24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              request.status == 'completed' ? Icons.check_circle : Icons.airport_shuttle, 
              color: AppColors.secondary, 
              size: 40
            ),
          ),
          const SizedBox(height: AppSizes.p16),
          Text(statusText, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.secondary)),
          if (estimatedText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(estimatedText, style: const TextStyle(color: AppColors.textSecondary)),
          ]
        ],
      ),
    );
  }

  Widget _buildProviderDetails(BuildContext context, OfferModel offer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hizmet Veren', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSizes.p12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.border,
            child: Icon(Icons.person, color: AppColors.textSecondary),
          ),
          title: Text(offer.providerName ?? 'Bilinmiyor', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${offer.providerRating ?? 0.0}/5 Puan • Usta'),
          trailing: IconButton(
            icon: const Icon(Icons.phone, color: AppColors.primary),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildServiceDetails(BuildContext context, RequestModel request) {
    final dateStr = '${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hizmet Detayları', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSizes.p16),
        _buildDetailRow(Icons.calendar_month, '$dateStr (Oluşturulma)'),
        const SizedBox(height: AppSizes.p12),
        if (request.location != null) ...[
          _buildDetailRow(Icons.location_on, request.location!),
          const SizedBox(height: AppSizes.p12),
        ],
        _buildDetailRow(Icons.confirmation_num_outlined, 'Hizmet: ${request.serviceName ?? request.title}'),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textHint, size: 20),
        const SizedBox(width: AppSizes.p12),
        Expanded(child: Text(text, style: const TextStyle(color: AppColors.textPrimary))),
      ],
    );
  }
}
