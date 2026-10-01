import '../../domain/entities/order_item.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.variantId,
    required super.productId,
    required super.productName,
    required super.sku,
    required super.color,
    required super.size,
    required super.price,
    required super.costPrice,
    required super.quantity,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      variantId: map['variantId'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      sku: map['sku'] ?? '',
      color: map['color'] ?? '',
      size: map['size'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      costPrice: (map['costPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'variantId': variantId,
      'productId': productId,
      'productName': productName,
      'sku': sku,
      'color': color,
      'size': size,
      'price': price,
      'costPrice': costPrice,
      'quantity': quantity,
    };
  }
}
