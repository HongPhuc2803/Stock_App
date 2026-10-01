import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/app_notification.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.storeId,
    required super.title,
    required super.message,
    required super.type,
    required super.isRead,
    required super.createdAt,
    super.targetType,
    super.targetId,
  });

  factory AppNotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppNotificationModel(
      id: doc.id,
      storeId: data['storeId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'LOW_STOCK',
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      targetType: data['targetType'] ?? '',
      targetId: data['targetId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'storeId': storeId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'targetType': targetType,
      'targetId': targetId,
    };
  }
}
