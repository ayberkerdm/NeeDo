import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/constants/app_sizes.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> allCategories = [
      {'name': 'Temizlik', 'icon': Icons.cleaning_services_rounded},
      {'name': 'Nakliyat', 'icon': Icons.local_shipping_rounded},
      {'name': 'Boya Badana', 'icon': Icons.format_paint_rounded},
      {'name': 'Elektrikçi', 'icon': Icons.electrical_services_rounded},
      {'name': 'Tesisatçı', 'icon': Icons.plumbing_rounded},
      {'name': 'Klima Servisi', 'icon': Icons.ac_unit_rounded},
      {'name': 'Özel Ders', 'icon': Icons.school_rounded},
      {'name': 'Evden Taşıma', 'icon': Icons.house_rounded},
      {'name': 'Mobilya Montaj', 'icon': Icons.handyman_rounded},
      {'name': 'Kuaför', 'icon': Icons.face_retouching_natural_rounded},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tüm Hizmetler', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Hangi kategoriye bakmıştınız?',
                prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: AppSizes.p16),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSizes.p16,
                mainAxisSpacing: AppSizes.p16,
                childAspectRatio: 1.1,
              ),
              itemCount: allCategories.length,
              itemBuilder: (context, index) {
                final cat = allCategories[index];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: InkWell(
                    onTap: () {
                      context.push('/create-request');
                    },
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSizes.p16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            cat['icon'] as IconData,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: AppSizes.p12),
                        Text(
                          cat['name'] as String,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
