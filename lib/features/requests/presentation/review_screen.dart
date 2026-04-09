import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/primary_button.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hizmeti Değerlendir'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.border,
              child: Icon(Icons.person, color: AppColors.textSecondary, size: 40),
            ),
            const SizedBox(height: AppSizes.p16),
            const Text('Ahmet Usta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Text('Ev Temizliği', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: AppSizes.p48),
            Text('Hizmet deneyimini nasıl değerlendirirsin?', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.p24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  iconSize: 40,
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: AppSizes.p32),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Yorumunu buraya yazabilirsin...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
                filled: true,
                fillColor: AppColors.background,
              ),
            ),
            const SizedBox(height: AppSizes.p32),
            PrimaryButton(
              text: 'Değerlendirmeyi Gönder',
              onPressed: _rating > 0 ? () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yorumunuz gönderildi!')));
              } : null,
            )
          ],
        ),
      ),
    );
  }
}
