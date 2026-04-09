import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/primary_button.dart';

class ProviderSubmitProposalScreen extends StatelessWidget {
  const ProviderSubmitProposalScreen({super.key});

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
            const Text('Müşteri 120 metrekarelik boş bir evin dezenfekte edilerek derinlemesine temizlenmesini talep ediyor. Camlar dahil.', style: TextStyle(color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: AppSizes.p32),
            Text('Fiyat Teklifiniz (₺)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.p12),
            TextField(
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
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
                filled: true,
                fillColor: AppColors.background,
              ),
              hint: const Text('Seçiniz'),
              items: ['1-2 Saat', '3-4 Saat', 'Tüm Gün'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) {},
            ),
            const SizedBox(height: AppSizes.p24),
            Text('Müşteriye Mesajınız', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.p12),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Müşteriye işi nasıl yapacağınızı anlatın...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
                filled: true,
                fillColor: AppColors.background,
              ),
            ),
            const SizedBox(height: AppSizes.p32),
            PrimaryButton(
              text: 'Teklifi Gönder',
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Teklifiniz müşteriye başarıyla iletildi!')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
