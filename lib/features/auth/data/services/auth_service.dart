import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService(this._auth);

  Future<UserCredential> login({
    required String email,

    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,

      password: password,
    );
  }

  Future<UserCredential> register({
    required String email,

    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,

      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
