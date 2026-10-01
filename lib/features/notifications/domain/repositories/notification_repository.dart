import '../entities/app_notification.dart';

abstract class NotificationRepository {
  Stream<List<AppNotification>> getNotifications(String storeId);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead(String storeId);
}
