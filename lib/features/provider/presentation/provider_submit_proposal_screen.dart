import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../requests/data/models/request_model.dart';
import '../../auth/data/providers/auth_provider.dart';
import '../../requests/data/providers/offers_provider.dart';
import '../../notifications/data/services/notification_service.dart';

class ProviderSubmitProposalScreen extends ConsumerStatefulWidget {
  final RequestModel? request;
  
  const ProviderSubmitProposalScreen({super.key, this.request});

  @override
  ConsumerState<ProviderSubmitProposalScreen> createState() => _ProviderSubmitProposalScreenState();
}

class _ProviderSubmitProposalScreenState extends ConsumerState<ProviderSubmitProposalScreen> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String? _selectedTime;
  bool _isLoading = false;

  @override
  void dispose() {
    _priceController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitOffer() async {
    if (widget.request == null) return;
    
    final priceStr = _priceController.text.trim();
    if (priceStr.isEmpty || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen fiyat ve tahmini süreyi doldurun.')));
      return;
    }

    final price = double.tryParse(priceStr);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen geçerli bir fiyat girin.')));
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      await supabase.from('offers').insert({
        'request_id': widget.request!.id,
        'provider_id': user.id,
        'price': price,
        'estimated_time': _selectedTime,
        // _messageController could be saved if we had a message/note column in offers table.
      });

      // Send notification to customer
      final providerName = user.userMetadata?['full_name'] ?? 'Bir uzman';
      await ref.read(notificationServiceProvider).sendNotification(
        userId: widget.request!.customerId,
        title: 'Yeni Bir Teklif Aldınız!',
        message: '$providerName talebiniz için teklif verdi.',
        type: 'offer_received',
      );

      // Refresh offers provider
      ref.invalidate(providerOffersProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Teklifiniz başarıyla iletildi!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata oluştu: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teklif Ver'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('İş Özeti', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.p16),
            Text(widget.request?.description ?? widget.request?.title ?? 'İş detayı bulunamadı.', style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: AppSizes.p32),
            Text('Fiyat Teklifiniz (₺)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.p12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Örn: 1500',
                prefixIcon: const Icon(Icons.currency_lira),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
                filled: true,
                fillColor: AppColors.background,
              ),
            ),
            const SizedBox(height: AppSizes.p24),
            Text('Tahmini İş Süresi', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.p12),
            DropdownButtonFormField<String>(
              value: _selectedTime,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
                filled: true,
                fillColor: AppColors.background,
              ),
              hint: const Text('Seçiniz'),
              items: ['1-2 Saat', '3-4 Saat', 'Tüm Gün'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedTime = val;
                });
              },
            ),
            const SizedBox(height: AppSizes.p24),
            Text('Müşteriye Mesajınız', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.p12),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Müşteriye işi nasıl yapacağınızı anlatın...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
                filled: true,
                fillColor: AppColors.background,
              ),
            ),
            const SizedBox(height: AppSizes.p32),
            _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : PrimaryButton(
                  text: 'Teklifi Gönder',
                  onPressed: _submitOffer,
                ),
          ],
        ),
      ),
    );
  }
}
