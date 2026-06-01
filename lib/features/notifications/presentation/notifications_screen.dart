import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../auth/data/providers/auth_provider.dart';
import '../data/services/notification_service.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Giriş yapınız.')),
      );
    }

    final notificationService = ref.read(notificationServiceProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Tümünü Okundu İşaretle',
            onPressed: () {
              notificationService.markAllAsRead(user.id);
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: notificationService.getNotificationsStream(user.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? [];
          
          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                'Henüz bildiriminiz yok.',
                style: TextStyle(color: AppColors.textHint, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: notification.isRead ? AppColors.surface : AppColors.primaryLight.withOpacity(0.2),
                  child: Icon(
                    _getIconForType(notification.type),
                    color: notification.isRead ? AppColors.textHint : AppColors.primary,
                  ),
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(notification.message),
                trailing: Text(
                  _formatDate(notification.createdAt),
                  style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
                onTap: () {
                  if (!notification.isRead) {
                    notificationService.markAsRead(notification.id);
                  }
                  // Yönlendirme mantığı buraya eklenebilir
                },
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'new_offer':
        return Icons.local_offer;
      case 'message':
        return Icons.chat_bubble;
      case 'status_update':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 0) {
      return '${difference.inDays}g önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}s önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}d önce';
    } else {
      return 'Şimdi';
    }
  }
}
