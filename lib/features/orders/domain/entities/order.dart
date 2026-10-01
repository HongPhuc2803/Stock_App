import 'order_item.dart';

class AppOrder {
  final String id;
  final String storeId;
  final List<OrderItem> items;
  final double subtotal;
  final double discount;
  final double total;
  final String paymentStatus; // PAID, PENDING, CANCELLED
  final String paymentMethod; // CASH, CARD, TRANSFER
  final String createdBy;
  final DateTime createdAt;
  final String? customerId;
  final String? customerName;

  const AppOrder({
    required this.id,
    required this.storeId,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.createdBy,
    required this.createdAt,
    this.customerId,
    this.customerName,
  });
}
