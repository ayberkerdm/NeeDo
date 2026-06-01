import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final _supabase = Supabase.instance.client;

  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => NotificationModel.fromJson(json)).toList());
  }

  Future<void> markAsRead(String notificationId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  Future<void> markAllAsRead(String userId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? relatedId, // kept in signature in case we want to use it later, but not inserted
  }) async {
    await _supabase.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': false,
    });
  }
}
