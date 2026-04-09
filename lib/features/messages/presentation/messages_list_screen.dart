import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';

class MessagesListScreen extends StatelessWidget {
  const MessagesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesajlar'),
      ),
      body: ListView.separated(
        itemCount: 2,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final isUnread = index == 0;
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p8),
            leading: const CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.border,
              child: Icon(Icons.person, color: AppColors.textSecondary),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ahmet Usta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  index == 0 ? '10:42' : 'Dün', 
                  style: TextStyle(
                    color: isUnread ? AppColors.primary : AppColors.textHint, 
                    fontSize: 12,
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal
                  )
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                index == 0 ? 'Konum bilgisi atabilir misiniz?' : 'Tamamdır teşekkürler.',
                style: TextStyle(
                  color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: isUnread ? Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ) : null,
            onTap: () {
              context.push('/chat');
            },
          );
        },
      ),
    );
  }
}
