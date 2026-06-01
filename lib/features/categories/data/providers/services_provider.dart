import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_model.dart';

final servicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  final supabase = Supabase.instance.client;
  
  final response = await supabase
      .from('services')
      .select()
      .eq('is_active', true)
      .order('name');
      
  return (response as List).map((e) => ServiceModel.fromJson(e)).toList();
});

final popularServicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  // Gerçek uygulamada popülerliğe göre (örn. talep sayısına göre) sıralanabilir.
  // Şimdilik ilk 4 servisi döndürelim.
  final supabase = Supabase.instance.client;
  
  final response = await supabase
      .from('services')
      .select()
      .eq('is_active', true)
      .limit(4);
      
  return (response as List).map((e) => ServiceModel.fromJson(e)).toList();
});
