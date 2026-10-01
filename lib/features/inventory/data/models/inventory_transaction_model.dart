import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/inventory_transaction.dart';

class InventoryTransactionModel extends InventoryTransaction {
  const InventoryTransactionModel({
    required super.id,
    required super.variantId,
    required super.type,
    required super.quantity,
    required super.beforeStock,
    required super.afterStock,
    required super.createdBy,
    required super.storeId,
    required super.createdAt,
  });

  factory InventoryTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return InventoryTransactionModel(
      id: doc.id,
      variantId: data['variantId'] ?? '',
      type: data['type'] ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      beforeStock: (data['beforeStock'] as num?)?.toInt() ?? 0,
      afterStock: (data['afterStock'] as num?)?.toInt() ?? 0,
      createdBy: data['createdBy'] ?? '',
      storeId: data['storeId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'variantId': variantId,
      'type': type,
      'quantity': quantity,
      'beforeStock': beforeStock,
      'afterStock': afterStock,
      'createdBy': createdBy,
      'storeId': storeId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
