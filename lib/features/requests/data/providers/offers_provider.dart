import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/offer_model.dart';
import '../../../auth/data/providers/auth_provider.dart';

// Belirli bir talep (request) için gelen teklifleri getirir
final requestOffersProvider = FutureProvider.autoDispose.family<List<OfferModel>, String>((ref, requestId) async {
  final supabase = Supabase.instance.client;
  
  final response = await supabase
      .from('offers')
      .select('*, profiles(*)')
      .eq('request_id', requestId)
      .order('price', ascending: true);
      
  return (response as List).map((e) => OfferModel.fromJson(e)).toList();
});

// Kullanıcının yaptığı tüm teklifleri getirir (Provider için)
final providerOffersProvider = FutureProvider.autoDispose<List<OfferModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final supabase = Supabase.instance.client;
  
  final response = await supabase
      .from('offers')
      .select('*, requests(status, location, services(name))')
      .eq('provider_id', user.id)
      .order('created_at', ascending: false);
      
  return (response as List).map((e) => OfferModel.fromJson(e)).toList();
});

// Kullanıcının tüm tekliflerini getirir (Müşteri ekranında göstermek için)
final myAllOffersProvider = FutureProvider.autoDispose<List<OfferModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final supabase = Supabase.instance.client;
  
  // Get all request IDs for the customer
  final myRequestsRes = await supabase.from('requests').select('id').eq('customer_id', user.id);
  final requestIds = (myRequestsRes as List).map((r) => r['id']).toList();

  if (requestIds.isEmpty) return [];
  
  final response = await supabase
      .from('offers')
      .select('*, profiles(*)')
      .inFilter('request_id', requestIds)
      .eq('status', 'pending')
      .order('created_at', ascending: false);
      
  return (response as List).map((e) => OfferModel.fromJson(e)).toList();
});

final offerServiceProvider = Provider<OfferService>((ref) {
  return OfferService();
});

class OfferService {
  final _supabase = Supabase.instance.client;

  Future<void> acceptOffer(String offerId, String requestId) async {
    // 1. Accept the specific offer
    await _supabase.from('offers').update({'status': 'accepted'}).eq('id', offerId);
    
    // 2. Reject all other offers for this request
    await _supabase.from('offers').update({'status': 'rejected'})
        .eq('request_id', requestId)
        .neq('id', offerId);
        
    // 3. Update request status to 'active'
    await _supabase.from('requests').update({'status': 'active'}).eq('id', requestId);
  }

  Future<void> rejectOffer(String offerId) async {
    await _supabase.from('offers').update({'status': 'rejected'}).eq('id', offerId);
  }

  Future<void> customerCounterOffer(String offerId, double counterPrice) async {
    await _supabase.from('offers').update({
      'customer_counter_price': counterPrice
    }).eq('id', offerId);
  }

  Future<void> providerUpdatePrice(String offerId, double newPrice) async {
    await _supabase.from('offers').update({
      'price': newPrice,
      'customer_counter_price': null
    }).eq('id', offerId);
  }
}
