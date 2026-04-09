import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/app_user.dart';
import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final userId = response.user?.id;
    if (userId == null) throw Exception('Sign in failed');

    return _fetchProfile(userId);
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    final userId = response.user?.id;
    if (userId == null) throw Exception('Sign up failed');

    return _fetchProfile(userId);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    return _fetchProfile(user.id);
  }

  @override
  Stream<AppUser?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) return null;
      return _fetchProfile(user.id);
    });
  }

  Future<AppUser> _fetchProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return AppUser.fromJson(response);
  }
}
