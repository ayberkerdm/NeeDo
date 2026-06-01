import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/providers/auth_provider.dart';

final reviewServiceProvider = Provider<ReviewService>((ref) {
  return ReviewService();
});

class ReviewService {
  final _supabase = Supabase.instance.client;

  Future<void> submitReview({
    required String providerId,
    required String customerId,
    required String requestId,
    required int rating,
    required String comment,
  }) async {
    await _supabase.from('reviews').insert({
      'provider_id': providerId,
      'customer_id': customerId,
      'request_id': requestId,
      'rating': rating,
      'comment': comment,
    });
    
    // In a real app, you would also trigger a function to update the provider's average rating in profiles.
    // That could be done via a Postgres trigger or an edge function, or directly here:
    // This is a simplified approach.
    final reviewsRes = await _supabase.from('reviews').select('rating').eq('provider_id', providerId);
    
    if (reviewsRes.isNotEmpty) {
      double total = 0;
      for(var r in reviewsRes) {
        total += (r['rating'] as num).toDouble();
      }
      double avg = total / reviewsRes.length;
      
      await _supabase.from('profiles').update({'rating': avg}).eq('id', providerId);
    }
  }
}
