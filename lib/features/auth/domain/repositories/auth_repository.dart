import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> login({required String email, required String password});

  Future<AppUser?> register({
    required String name,
    required String email,
    required String password,
    required String storeName,
  });

  Future<void> logout();

  Future<void> sendPasswordResetEmail({required String email});

  Stream<AppUser?> get authStateChanges;
}
