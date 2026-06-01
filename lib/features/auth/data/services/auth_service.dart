import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Current user
  User? get currentUser => _supabase.auth.currentUser;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String role = 'customer',
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role,
      },
    );
    
    // Profil oluşturma işlemi veritabanındaki handle_new_user trigger'ı
    // ile otomatik yapıldığı için manuel eklemeye gerek yoktur.
    
    return response;
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get user profile role
  Future<String?> getUserRole() async {
    if (currentUser == null) return null;
    
    try {
      final response = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', currentUser!.id)
          .single();
      
      return response['role'] as String?;
    } catch (e) {
      return null;
    }
  }
}
