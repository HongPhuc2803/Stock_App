import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/store.dart';
import '../../domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(firestoreProvider));
});

final storeStreamProvider = StreamProvider.family<Store?, String>((
  ref,
  storeId,
) {
  return ref.watch(settingsRepositoryProvider).getStore(storeId);
});

final notificationPreferencesProvider =
    StreamProvider.family<Map<String, bool>, String>((ref, uid) {
      return ref
          .watch(settingsRepositoryProvider)
          .getNotificationPreferences(uid);
    });

class SettingsController extends StateNotifier<AsyncValue<void>> {
  final SettingsRepository _repository;

  SettingsController(this._repository) : super(const AsyncValue.data(null));

  Future<bool> updateStore(Store store) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      await _repository.updateStore(store);
    });
    state = result;
    return !result.hasError;
  }

  Future<bool> updateUserProfile(
    String uid, {
    required String name,
    required String phone,
  }) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      await _repository.updateUserProfile(uid, name: name, phone: phone);
    });
    state = result;
    return !result.hasError;
  }

  Future<bool> updateNotificationPreferences(
    String uid,
    Map<String, bool> preferences,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.updateNotificationPreferences(uid, preferences),
    );
    return !state.hasError;
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AsyncValue<void>>((ref) {
      return SettingsController(ref.watch(settingsRepositoryProvider));
    });
