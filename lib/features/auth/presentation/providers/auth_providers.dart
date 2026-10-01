import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/services/auth_service.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    authService: ref.watch(authServiceProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AsyncValue.data(null));

  Future<bool> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );
      if (user == null) {
        throw Exception('User profile not found in database.');
      }
    });
    state = result;
    return !result.hasError;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String storeName,
  }) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      final user = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        storeName: storeName,
      );
      if (user == null) {
        throw Exception('Failed to register user.');
      }
    });
    state = result;
    return !result.hasError;
  }

  Future<bool> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.logout();
    });
    return !state.hasError;
  }

  Future<bool> sendPasswordResetEmail({required String email}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authRepository.sendPasswordResetEmail(email: email),
    );
    return !state.hasError;
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      return AuthController(ref.watch(authRepositoryProvider));
    });
