import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final hasReviewedProvider = FutureProvider.family<bool, String>((ref, requestId) async {
  final supabase = Supabase.instance.client;
  
  final res = await supabase
      .from('reviews')
      .select('id')
      .eq('request_id', requestId)
      .maybeSingle();
      
  return res != null;
});

final reviewServiceProvider = Provider<ReviewService>((ref) {
  return ReviewService();
});

class ReviewService {
  final _supabase = Supabase.instance.client;

  Future<void> submitReview({
    required String requestId,
    required String providerId,
    required String customerId,
    required double rating,
    String? comment,
  }) async {
    await _supabase.from('reviews').insert({
      'request_id': requestId,
      'provider_id': providerId,
      'customer_id': customerId,
      'rating': rating,
      'comment': comment,
    });
  }
}
