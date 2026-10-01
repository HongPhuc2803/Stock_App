import '../entities/store.dart';

abstract class SettingsRepository {
  Stream<Store?> getStore(String storeId);
  Future<void> updateStore(Store store);
  Future<void> updateUserProfile(
    String uid, {
    required String name,
    required String phone,
  });
  Stream<Map<String, bool>> getNotificationPreferences(String uid);
  Future<void> updateNotificationPreferences(
    String uid,
    Map<String, bool> preferences,
  );
}
