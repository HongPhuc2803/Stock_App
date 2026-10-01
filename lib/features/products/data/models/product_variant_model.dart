import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product_variant.dart';

class ProductVariantModel extends ProductVariant {
  const ProductVariantModel({
    required super.id,
    required super.productId,
    required super.sku,
    required super.barcode,
    required super.color,
    required super.size,
    required super.costPrice,
    required super.sellingPrice,
    required super.stock,
    required super.storeId,
  });

  factory ProductVariantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProductVariantModel(
      id: doc.id,
      productId: data['productId'] ?? '',
      sku: data['sku'] ?? '',
      barcode: data['barcode'] ?? '',
      color: data['color'] ?? '',
      size: data['size'] ?? '',
      costPrice: (data['costPrice'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (data['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      storeId: data['storeId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'sku': sku,
      'barcode': barcode,
      'color': color,
      'size': size,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'stock': stock,
      'storeId': storeId,
    };
  }
}
