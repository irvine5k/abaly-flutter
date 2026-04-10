import '../../../shared/models/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> signIn({required String email, required String password});
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String fullName,
  });
  Future<void> signOut();
  Future<AppUser?> getCurrentUser();
  Stream<AppUser?> get authStateChanges;
}
