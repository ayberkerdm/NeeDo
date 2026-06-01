import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/data/providers/auth_provider.dart';

final providerProfileProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, providerId) async {
  final supabase = Supabase.instance.client;
  
  final profileRes = await supabase
      .from('profiles')
      .select('*')
      .eq('id', providerId)
      .single();
      
  final reviewsRes = await supabase
      .from('reviews')
      .select('*, profiles:customer_id(full_name, avatar_url)')
      .eq('provider_id', providerId)
      .order('created_at', ascending: false);
      
  // Get stats
  final completedRes = await supabase
      .from('offers')
      .select('id')
      .eq('provider_id', providerId)
      .eq('status', 'accepted');

  return {
    'profile': profileRes,
    'reviews': reviewsRes,
    'completed_count': completedRes.length,
    'review_count': (reviewsRes as List).length,
  };
});

final isFavoriteProvider = FutureProvider.family<bool, String>((ref, providerId) async {
  final user = ref.watch(authServiceProvider).currentUser;
  if (user == null) return false;

  final supabase = Supabase.instance.client;
  final res = await supabase
      .from('favorites')
      .select('id')
      .eq('customer_id', user.id)
      .eq('provider_id', providerId);
      
  return res.isNotEmpty;
});

final favoriteServiceProvider = Provider<FavoriteService>((ref) {
  return FavoriteService();
});

class FavoriteService {
  final _supabase = Supabase.instance.client;

  Future<bool> toggleFavorite(String customerId, String providerId, bool currentlyFavorited) async {
    if (currentlyFavorited) {
      await _supabase
          .from('favorites')
          .delete()
          .eq('customer_id', customerId)
          .eq('provider_id', providerId);
      return false;
    } else {
      await _supabase
          .from('favorites')
          .insert({
            'customer_id': customerId,
            'provider_id': providerId,
          });
      return true;
    }
  }
}
