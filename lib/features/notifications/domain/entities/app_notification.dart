class AppNotification {
  final String id;
  final String storeId;
  final String title;
  final String message;
  final String type; // LOW_STOCK, OUT_OF_STOCK, STOCK_RECEIVED
  final bool isRead;
  final DateTime createdAt;
  final String targetType;
  final String targetId;

  const AppNotification({
    required this.id,
    required this.storeId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.targetType = '',
    this.targetId = '',
  });
}
