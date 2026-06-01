import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/request_model.dart';
import '../models/offer_model.dart';
import '../../../auth/data/providers/auth_provider.dart';

final myRequestsProvider = FutureProvider<List<RequestModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final supabase = Supabase.instance.client;
  
  final response = await supabase
      .from('requests')
      .select('*, services(name)')
      .eq('customer_id', user.id)
      .order('created_at', ascending: false);
      
  return (response as List).map((e) => RequestModel.fromJson(e)).toList();
});

final opportunitiesProvider = FutureProvider<List<RequestModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final supabase = Supabase.instance.client;
  
  final response = await supabase
      .from('requests')
      .select('*, services(name), profiles(full_name)')
      .eq('status', 'pending')
      .neq('customer_id', user.id) // Don't show own requests
      .order('created_at', ascending: false);
      
  return (response as List).map((e) => RequestModel.fromJson(e)).toList();
});

final requestServiceProvider = Provider<RequestService>((ref) {
  return RequestService();
});

class RequestService {
  final _supabase = Supabase.instance.client;

  Future<void> createRequest({
    required String customerId,
    required String title,
    String? description,
    String? location,
    String? budgetRange,
  }) async {
    await _supabase.from('requests').insert({
      'customer_id': customerId,
      'title': title,
      'description': description,
      'location': location,
      'budget_range': budgetRange,
      'status': 'pending',
    });
  }
}

final activeRequestDetailsProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, requestId) async {
  final supabase = Supabase.instance.client;
  
  // 1. Get request
  final reqRes = await supabase
      .from('requests')
      .select('*, services(name)')
      .eq('id', requestId)
      .maybeSingle();
      
  if (reqRes == null) return null;
  
  // 2. Get accepted offer for this request
  final offerRes = await supabase
      .from('offers')
      .select('*, profiles(*)')
      .eq('request_id', requestId)
      .eq('status', 'accepted')
      .maybeSingle();

  return {
    'request': RequestModel.fromJson(reqRes),
    'offer': offerRes != null ? OfferModel.fromJson(offerRes) : null,
  };
});
