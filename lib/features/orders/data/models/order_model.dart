import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/order.dart';
import 'order_item_model.dart';

class OrderModel extends AppOrder {
  const OrderModel({
    required super.id,
    required super.storeId,
    required super.items,
    required super.subtotal,
    required super.discount,
    required super.total,
    required super.paymentStatus,
    required super.paymentMethod,
    required super.createdBy,
    required super.createdAt,
    super.customerId,
    super.customerName,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final list = data['items'] as List<dynamic>? ?? [];
    final itemsList = list
        .map((item) => OrderItemModel.fromMap(item as Map<String, dynamic>))
        .toList();

    return OrderModel(
      id: doc.id,
      storeId: data['storeId'] ?? '',
      items: itemsList,
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: data['paymentStatus'] ?? 'PENDING',
      paymentMethod: data['paymentMethod'] ?? 'CASH',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      customerId: data['customerId'],
      customerName: data['customerName'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'storeId': storeId,
      'items': items
          .map(
            (item) => OrderItemModel(
              variantId: item.variantId,
              productId: item.productId,
              productName: item.productName,
              sku: item.sku,
              color: item.color,
              size: item.size,
              price: item.price,
              costPrice: item.costPrice,
              quantity: item.quantity,
            ).toMap(),
          )
          .toList(),
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'customerId': customerId,
      'customerName': customerName,
    };
  }
}
