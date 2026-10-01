import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/store.dart';
import '../../domain/repositories/settings_repository.dart';
import '../models/store_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final FirebaseFirestore _firestore;

  SettingsRepositoryImpl(this._firestore);

  @override
  Stream<Store?> getStore(String storeId) {
    return _firestore.collection('stores').doc(storeId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return StoreModel.fromFirestore(doc);
    });
  }

  @override
  Future<void> updateStore(Store store) async {
    final model = StoreModel(
      id: store.id,
      name: store.name,
      ownerId: store.ownerId,
      address: store.address,
      phone: store.phone,
      currency: store.currency,
      timezone: store.timezone,
      lowStockThreshold: store.lowStockThreshold,
    );
    await _firestore
        .collection('stores')
        .doc(store.id)
        .update(model.toFirestore());
  }

  @override
  Future<void> updateUserProfile(
    String uid, {
    required String name,
    required String phone,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'name': name,
      'phone': phone,
    });
  }

  @override
  Stream<Map<String, bool>> getNotificationPreferences(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      final raw = doc.data()?['notificationPreferences'];
      final values = raw is Map ? Map<String, dynamic>.from(raw) : const {};
      return {
        'lowStock': values['lowStock'] as bool? ?? true,
        'newOrder': values['newOrder'] as bool? ?? true,
        'stockUpdated': values['stockUpdated'] as bool? ?? true,
      };
    });
  }

  @override
  Future<void> updateNotificationPreferences(
    String uid,
    Map<String, bool> preferences,
  ) {
    return _firestore.collection('users').doc(uid).update({
      'notificationPreferences': preferences,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
