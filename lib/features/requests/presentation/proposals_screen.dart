import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/primary_button.dart';

class ProposalsScreen extends StatelessWidget {
  const ProposalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelen Teklifler'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.p16),
        itemCount: 3, 
        itemBuilder: (context, index) {
          return const ProposalCard();
        },
      ),
    );
  }
}

class ProposalCard extends StatelessWidget {
  const ProposalCard({super.key});

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
                      Text('Ahmet Usta', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          const Text('4.9'),
                          const SizedBox(width: 8),
                          Text('(124 Yorum)', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Tahmini Süre: 2-3 Saat', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('1200 TL', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: 'Profili İncele',
                    isSecondary: true,
                    onPressed: () {
                      context.push('/provider-profile');
                    },
                  ),
                ),
                const SizedBox(width: AppSizes.p16),
                Expanded(
                  child: PrimaryButton(
                    text: 'Mesaj Gönder',
                    onPressed: () {
                      context.push('/chat');
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
