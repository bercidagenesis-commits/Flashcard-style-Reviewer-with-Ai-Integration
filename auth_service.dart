import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  // Register a new user
  Future<AuthResponse> register({
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    return response;
  }

  // Login existing user
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    return response;
  }

  // Logout
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  // Get currently logged-in user
  User? get currentUser {
    return supabase.auth.currentUser;
  }
}
