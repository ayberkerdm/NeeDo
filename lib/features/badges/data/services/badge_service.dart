import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final badgeServiceProvider = Provider<BadgeService>((ref) {
  return BadgeService();
});

class BadgeService {
  final _supabase = Supabase.instance.client;

  Future<void> checkAndAssignBadges(String providerId) async {
    try {
      // 1. Get total completed jobs
      final offersResponse = await _supabase
          .from('offers')
          .select('id, status')
          .eq('provider_id', providerId)
          .eq('status', 'accepted');
      
      final completedJobsCount = offersResponse.length;

      // 2. Get average rating
      final profileResponse = await _supabase
          .from('profiles')
          .select('rating')
          .eq('id', providerId)
          .single();
      
      final double rating = (profileResponse['rating'] as num?)?.toDouble() ?? 0.0;

      // Badges logic (assuming they exist in 'badges' table with specific names)
      final allBadges = await _supabase.from('badges').select('*');
      
      for (var badge in allBadges) {
        bool earned = false;
        if (badge['name'] == '100+ İş' && completedJobsCount >= 100) {
          earned = true;
        } else if (badge['name'] == '5 Yıldız Usta' && rating >= 4.8) {
          earned = true;
        }
        
        if (earned) {
          // Check if user already has it
          final existing = await _supabase
              .from('user_badges')
              .select()
              .eq('provider_id', providerId)
              .eq('badge_id', badge['id']);
          
          if (existing.isEmpty) {
            await _supabase.from('user_badges').insert({
              'provider_id': providerId,
              'badge_id': badge['id'],
            });
          }
        }
      }
    } catch (e) {
      print('Badge check error: $e');
    }
  }
}
