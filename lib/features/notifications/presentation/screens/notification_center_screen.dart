import 'package:flutter/material.dart';

import '../../../../core/errors/user_error_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../domain/entities/app_notification.dart';
import '../providers/notification_providers.dart';

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  Future<void> _openNotification(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) async {
    if (!notification.isRead) {
      await ref
          .read(notificationsControllerProvider.notifier)
          .markAsRead(notification.id);
    }
    if (!context.mounted || notification.targetId.isEmpty) return;
    final role = ref.read(currentAppUserProvider)?.role.toUpperCase() ?? '';
    final base = role == 'OWNER'
        ? '/owner'
        : role == 'STAFF'
        ? '/staff'
        : '/warehouse';
    if (notification.targetType == 'ORDER' && role != 'WAREHOUSE_MANAGER') {
      context.push('$base/orders/details/${notification.targetId}');
    } else if (notification.targetType == 'PRODUCT') {
      if (role == 'OWNER' || role == 'STAFF') {
        context.push('$base/products/${notification.targetId}');
      } else {
        context.push('/warehouse/inventory');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final storeId = ref.watch(currentStoreIdProvider) ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Trung Tâm Thông Báo',
          style: TextStyle(
            color: Color(0xFF004AC6),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1C30)),
          onPressed: () => context.pop(),
        ),
      ),
      body: notificationsAsync.when(
        data: (list) {
          final unreadList = list.where((n) => !n.isRead).toList();
          final unreadCount = unreadList.length;

          return Column(
            children: [
              // Header actions
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        unreadCount > 0
                            ? 'Bạn có $unreadCount thông báo chưa đọc.'
                            : 'Không có thông báo mới.',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF434655),
                        ),
                      ),
                    ),
                    if (unreadCount > 0)
                      TextButton.icon(
                        icon: const Icon(Icons.done_all, size: 16),
                        label: const Text('Đọc tất cả'),
                        onPressed: () {
                          ref
                              .read(notificationsControllerProvider.notifier)
                              .markAllAsRead(storeId);
                        },
                      ),
                  ],
                ),
              ),

              // Notifications List
              Expanded(
                child: list.isEmpty
                    ? const Center(
                        child: Text(
                          'Hộp thư thông báo trống.',
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final notification = list[index];
                          final dateStr = DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(notification.createdAt);

                          IconData icon;
                          Color iconColor;
                          Color bgTonalColor;

                          if (notification.type == 'OUT_OF_STOCK') {
                            icon = Icons.error_outline;
                            iconColor = const Color(0xFFBA1A1A);
                            bgTonalColor = const Color(0xFFFFDAD6);
                          } else if (notification.type == 'LOW_STOCK') {
                            icon = Icons.warning_amber_outlined;
                            iconColor = const Color(0xFFB25E00);
                            bgTonalColor = const Color(0xFFFFF0D4);
                          } else {
                            icon = Icons.inventory_2_outlined;
                            iconColor = const Color(0xFF006C49);
                            bgTonalColor = const Color(0xFFD0F8E3);
                          }

                          return Card(
                            elevation: 0,
                            color: notification.isRead
                                ? Colors.white
                                : const Color(0xFFEFF6FF), // Unread highlighted
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: notification.isRead
                                    ? const Color(0xFFE2E8F0)
                                    : const Color(0xFFBFDBFE),
                                width: notification.isRead ? 1 : 1.5,
                              ),
                            ),
                            child: ListTile(
                              onTap: () =>
                                  _openNotification(context, ref, notification),
                              leading: CircleAvatar(
                                backgroundColor: bgTonalColor,
                                child: Icon(icon, color: iconColor, size: 20),
                              ),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      notification.title,
                                      style: TextStyle(
                                        fontWeight: notification.isRead
                                            ? FontWeight.normal
                                            : FontWeight.bold,
                                        color: const Color(0xFF0B1C30),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    dateStr,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  notification.message,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF434655),
                                  ),
                                ),
                              ),
                              trailing: !notification.isRead
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.done,
                                        size: 18,
                                        color: Color(0xFF2563EB),
                                      ),
                                      onPressed: () {
                                        ref
                                            .read(
                                              notificationsControllerProvider
                                                  .notifier,
                                            )
                                            .markAsRead(notification.id);
                                      },
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) =>
            Center(child: Text('Lỗi tải thông báo: ${userErrorMessage(e)}')),
      ),
    );
  }
}
