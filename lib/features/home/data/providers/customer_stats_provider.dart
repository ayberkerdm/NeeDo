import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/data/providers/auth_provider.dart';

final customerStatsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final user = ref.watch(authServiceProvider).currentUser;
  if (user == null) {
    return {
      'active_jobs': 0,
      'pending_offers': 0,
      'completed_jobs': 0,
      'favorites': 0,
    };
  }

  final supabase = Supabase.instance.client;

  // Active jobs (status = 'active')
  final activeJobsRes = await supabase
      .from('requests')
      .select('id')
      .eq('customer_id', user.id)
      .eq('status', 'active');
  
  // Completed jobs (status = 'completed')
  final completedJobsRes = await supabase
      .from('requests')
      .select('id')
      .eq('customer_id', user.id)
      .eq('status', 'completed');

  // Pending offers (offers for my requests where status = 'pending')
  // We can join requests and offers or just query offers where request's customer is me.
  // Actually, Supabase allows querying through relationships if configured, but let's do a simple subquery or two step query.
  final myRequestsRes = await supabase
      .from('requests')
      .select('id')
      .eq('customer_id', user.id);
      
  final requestIds = (myRequestsRes as List).map((r) => r['id']).toList();
  
  int pendingOffersCount = 0;
  if (requestIds.isNotEmpty) {
    final pendingOffersRes = await supabase
        .from('offers')
        .select('id')
        .inFilter('request_id', requestIds)
        .eq('status', 'pending');
    pendingOffersCount = pendingOffersRes.length;
  }

  // Favorites
  final favoritesRes = await supabase
      .from('favorites')
      .select('id')
      .eq('customer_id', user.id);

  return {
    'active_jobs': activeJobsRes.length,
    'pending_offers': pendingOffersCount,
    'completed_jobs': completedJobsRes.length,
    'favorites': favoritesRes.length,
  };
});
