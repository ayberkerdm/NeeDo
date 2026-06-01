import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final providerBadgesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, providerId) async {
  final supabase = Supabase.instance.client;
  
  // user_badges joined with badges table
  final response = await supabase
      .from('user_badges')
      .select('*, badges(*)')
      .eq('provider_id', providerId);
      
  return (response as List).map((e) => e['badges'] as Map<String, dynamic>).toList();
});
