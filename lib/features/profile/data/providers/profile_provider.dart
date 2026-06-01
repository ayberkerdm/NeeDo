import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/data/providers/auth_provider.dart';

final profileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final supabase = Supabase.instance.client;
  
  try {
    final response = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .single();
    return response;
  } catch (e) {
    return null;
  }
});
