import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(ref.watch(firestoreProvider));
});

final rawNotificationsStreamProvider = StreamProvider<List<AppNotification>>((
  ref,
) {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return const Stream.empty();
  return ref.watch(notificationRepositoryProvider).getNotifications(storeId);
});

final notificationsStreamProvider = Provider<AsyncValue<List<AppNotification>>>(
  (ref) {
    final raw = ref.watch(rawNotificationsStreamProvider);
    final user = ref.watch(currentAppUserProvider);
    if (user == null) return const AsyncValue.data([]);
    final preferences = ref.watch(notificationPreferencesProvider(user.uid));
    if (raw.isLoading || preferences.isLoading) {
      return const AsyncValue.loading();
    }
    if (raw.hasError) {
      return AsyncValue.error(raw.error!, raw.stackTrace!);
    }
    if (preferences.hasError) {
      return AsyncValue.error(preferences.error!, preferences.stackTrace!);
    }
    final values = preferences.value ?? const {};
    final list = (raw.value ?? const <AppNotification>[]).where((item) {
      if (item.type == 'LOW_STOCK' || item.type == 'OUT_OF_STOCK') {
        return values['lowStock'] ?? true;
      }
      if (item.type == 'NEW_ORDER') return values['newOrder'] ?? true;
      return values['stockUpdated'] ?? true;
    }).toList();
    return AsyncValue.data(list);
  },
);

class NotificationController extends StateNotifier<AsyncValue<void>> {
  final NotificationRepository _repository;

  NotificationController(this._repository) : super(const AsyncValue.data(null));

  Future<void> markAsRead(String id) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      await _repository.markAsRead(id);
    });
    state = result;
  }

  Future<void> markAllAsRead(String storeId) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      await _repository.markAllAsRead(storeId);
    });
    state = result;
  }
}

final notificationsControllerProvider =
    StateNotifierProvider<NotificationController, AsyncValue<void>>((ref) {
      return NotificationController(ref.watch(notificationRepositoryProvider));
    });
