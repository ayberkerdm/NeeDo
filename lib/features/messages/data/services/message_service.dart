import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';

final messageServiceProvider = Provider<MessageService>((ref) {
  return MessageService();
});

class MessageService {
  final _supabase = Supabase.instance.client;

  // Listen to messages for a specific chat (between currentUser and another user)
  Stream<List<MessageModel>> getChatMessages(String currentUserId, String otherUserId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((data) {
          final List<MessageModel> allMessages = data.map((json) => MessageModel.fromJson(json)).toList();
          return allMessages.where((msg) => 
            (msg.senderId == currentUserId && msg.receiverId == otherUserId) ||
            (msg.senderId == otherUserId && msg.receiverId == currentUserId)
          ).toList();
        });
  }

  // Get conversations list (last message per user)
  Future<List<Map<String, dynamic>>> getConversations(String currentUserId) async {
    // A raw SQL or an RPC might be better here, but we can fetch messages and group them.
    // In a real app, you'd use a view or RPC in Supabase.
    // For now, we fetch messages where we are sender or receiver.
    final response = await _supabase
        .from('messages')
        .select('*, sender:profiles!messages_sender_id_fkey(full_name, avatar_url), receiver:profiles!messages_receiver_id_fkey(full_name, avatar_url)')
        .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId')
        .order('created_at', ascending: false);

    final List<Map<String, dynamic>> conversations = [];
    final Set<String> processedUsers = {};

    for (var row in response) {
      final msg = MessageModel.fromJson(row);
      final otherUserId = msg.senderId == currentUserId ? msg.receiverId : msg.senderId;
      
      if (!processedUsers.contains(otherUserId)) {
        processedUsers.add(otherUserId);
        
        final otherProfile = msg.senderId == currentUserId ? row['receiver'] : row['sender'];
        
        conversations.add({
          'other_user_id': otherUserId,
          'other_user_name': otherProfile != null ? otherProfile['full_name'] : 'Kullanıcı',
          'other_user_avatar': otherProfile != null ? otherProfile['avatar_url'] : null,
          'last_message': msg,
          'unread_count': (msg.receiverId == currentUserId && !msg.isRead) ? 1 : 0 // Simplified unread count
        });
      } else {
         if (msg.receiverId == currentUserId && !msg.isRead) {
            // Find conversation and increment
            final convIndex = conversations.indexWhere((c) => c['other_user_id'] == otherUserId);
            if (convIndex != -1) {
              conversations[convIndex]['unread_count'] = (conversations[convIndex]['unread_count'] as int) + 1;
            }
         }
      }
    }

    return conversations;
  }

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String? requestId,
  }) async {
    final Map<String, dynamic> payload = {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
    };
    if (requestId != null) {
      payload['request_id'] = requestId;
    }
    await _supabase.from('messages').insert(payload);
  }

  Future<void> markMessagesAsRead(String currentUserId, String otherUserId) async {
    await _supabase
        .from('messages')
        .update({'is_read': true})
        .eq('receiver_id', currentUserId)
        .eq('sender_id', otherUserId)
        .eq('is_read', false);
  }
}
