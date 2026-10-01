import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    required AuthService authService,
    required FirebaseFirestore firestore,
  }) : _authService = authService,
       _firestore = firestore;

  @override
  Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.login(
      email: email,
      password: password,
    );
    final userDoc = await _firestore
        .collection('users')
        .doc(credential.user?.uid)
        .get();

    if (!userDoc.exists || userDoc.data() == null) {
      return null;
    }
    return UserModel.fromJson(userDoc.data()!);
  }

  @override
  Future<AppUser?> register({
    required String name,
    required String email,
    required String password,
    required String storeName,
  }) async {
    final credential = await _authService.register(
      email: email,
      password: password,
    );
    final uid = credential.user?.uid;
    if (uid == null) return null;

    // Create a new store document
    final storeRef = _firestore.collection('stores').doc();
    await storeRef.set({
      'name': storeName,
      'ownerId': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'currency': 'USD',
      'timezone': 'Asia/Bangkok',
      'lowStockThreshold': 10,
    });

    // Create a new user profile document
    final userRef = _firestore.collection('users').doc(uid);
    final userMap = {
      'uid': uid,
      'name': name,
      'email': email,
      'role': 'OWNER',
      'storeId': storeRef.id,
      'avatarUrl': '',
      'phone': '',
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    };
    await userRef.set(userMap);

    return UserModel.fromJson(userMap);
  }

  @override
  Future<void> logout() async {
    await _authService.logout();
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _authService.sendPasswordResetEmail(email: email);
  }

  @override
  Stream<AppUser?> get authStateChanges {
    return _authService.authStateChanges.asyncExpand((firebaseUser) {
      if (firebaseUser == null) return Stream<AppUser?>.value(null);
      return _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots()
          .map((doc) {
            if (!doc.exists || doc.data() == null) return null;
            return UserModel.fromJson(doc.data()!);
          });
    });
  }
}
