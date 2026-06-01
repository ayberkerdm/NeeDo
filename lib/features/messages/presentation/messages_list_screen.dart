import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../auth/data/providers/auth_provider.dart';
import '../data/services/message_service.dart';
import '../data/models/message_model.dart';

// Provider for conversations list
final conversationsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(authServiceProvider).currentUser;
  if (user == null) return [];
  return ref.watch(messageServiceProvider).getConversations(user.id);
});

class MessagesListScreen extends ConsumerWidget {
  const MessagesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesajlar'),
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return const Center(child: Text('Henüz mesajınız yok.', style: TextStyle(color: AppColors.textHint)));
          }

          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final conv = conversations[index];
              final MessageModel lastMessage = conv['last_message'];
              final int unreadCount = conv['unread_count'];
              final bool isUnread = unreadCount > 0;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p8),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.border,
                  backgroundImage: conv['other_user_avatar'] != null ? NetworkImage(conv['other_user_avatar']) : null,
                  child: conv['other_user_avatar'] == null ? const Icon(Icons.person, color: AppColors.textSecondary) : null,
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(conv['other_user_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      _formatDate(lastMessage.createdAt),
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
                    lastMessage.content,
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
                  child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ) : null,
                onTap: () {
                  // Navigate to chat and pass other user's info
                  context.push('/chat', extra: {
                    'otherUserId': conv['other_user_id'],
                    'otherUserName': conv['other_user_name'],
                  });
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Hata: $e')),
      ),
    );
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

