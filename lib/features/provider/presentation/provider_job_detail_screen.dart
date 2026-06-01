import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../requests/data/models/offer_model.dart';
import '../../requests/data/providers/offers_provider.dart';
import '../../notifications/data/services/notification_service.dart';

class ProviderJobDetailScreen extends ConsumerStatefulWidget {
  final OfferModel offer;

  const ProviderJobDetailScreen({super.key, required this.offer});

  @override
  ConsumerState<ProviderJobDetailScreen> createState() => _ProviderJobDetailScreenState();
}

class _ProviderJobDetailScreenState extends ConsumerState<ProviderJobDetailScreen> {
  bool _isLoading = false;

  Future<void> _completeJob() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      
      // 1. Update requests table status to 'completed'
      await supabase.from('requests').update({'status': 'completed'}).eq('id', widget.offer.requestId);
      
      // 2. Fetch the customer ID associated with the request to send notification
      final reqRes = await supabase.from('requests').select('customer_id').eq('id', widget.offer.requestId).single();
      final customerId = reqRes['customer_id'] as String;

      // 3. Send notification to the customer
      await ref.read(notificationServiceProvider).sendNotification(
        userId: customerId,
        title: 'İş Tamamlandı 🎉',
        message: 'Ustanız "${widget.offer.requestService ?? 'Talep'}" hizmetini tamamladığını bildirdi. Lütfen ustayı değerlendirin.',
        type: 'job_completed',
      );

      // 4. Invalidate provider offers list to reflect changes
      ref.invalidate(providerOffersProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('İş başarıyla tamamlandı!')));
        context.pop(); // Return to jobs list
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('İş Detayı'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(context),
            const SizedBox(height: AppSizes.p24),
            _buildServiceDetails(context),
            const SizedBox(height: AppSizes.p32),
            if (widget.offer.status == 'accepted')
              PrimaryButton(
                text: 'İşi Tamamla',
                isLoading: _isLoading,
                onPressed: _completeJob,
              ),
            if (widget.offer.status == 'completed')
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.secondary),
                    SizedBox(width: 8),
                    Text('Bu iş tamamlandı', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
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
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.handyman, color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: AppSizes.p16),
          Text(widget.offer.requestService ?? 'Talep Detayı', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text('Teklifiniz: ${widget.offer.price} ₺', style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildServiceDetails(BuildContext context) {
    final dateStr = '${widget.offer.createdAt.day}/${widget.offer.createdAt.month}/${widget.offer.createdAt.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hizmet Detayları', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSizes.p16),
        _buildDetailRow(Icons.calendar_month, '$dateStr (Teklif Tarihi)'),
        const SizedBox(height: AppSizes.p12),
        if (widget.offer.requestLocation != null) ...[
          _buildDetailRow(Icons.location_on, widget.offer.requestLocation!),
          const SizedBox(height: AppSizes.p12),
        ],
        if (widget.offer.estimatedTime != null) ...[
          _buildDetailRow(Icons.access_time, 'Tahmini Süre: ${widget.offer.estimatedTime}'),
          const SizedBox(height: AppSizes.p12),
        ],
        _buildDetailRow(Icons.confirmation_num_outlined, 'İş Kodu: #${widget.offer.requestId.substring(0, 8).toUpperCase()}'),
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
