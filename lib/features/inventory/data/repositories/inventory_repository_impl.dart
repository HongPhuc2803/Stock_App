import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/inventory_transaction.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../models/inventory_transaction_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final FirebaseFirestore _firestore;

  InventoryRepositoryImpl(this._firestore);

  @override
  Stream<List<InventoryTransaction>> getTransactions(String storeId) {
    return _firestore
        .collection('inventory_transactions')
        .where('storeId', isEqualTo: storeId)
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InventoryTransactionModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<void> executeStockTransaction({
    required String variantId,
    required int quantity,
    required String type,
    required String createdBy,
    required String storeId,
    String reason = '',
    String note = '',
    String reference = '',
  }) async {
    const allowedTypes = {
      'IMPORT',
      'ADJUSTMENT',
      'RETURN',
      'DAMAGE',
      'LOST',
      'EXPIRED',
    };
    if (!allowedTypes.contains(type)) {
      throw ArgumentError('Loại giao dịch kho không hợp lệ.');
    }
    if (quantity == 0) throw ArgumentError('Số lượng thay đổi phải khác 0.');
    if ((type == 'IMPORT' || type == 'RETURN') && quantity < 0) {
      throw ArgumentError('Giao dịch nhập kho phải có số lượng dương.');
    }
    final variantRef = _firestore.collection('variants').doc(variantId);
    final txRef = _firestore.collection('inventory_transactions').doc();

    await _firestore.runTransaction((transaction) async {
      final variantSnapshot = await transaction.get(variantRef);
      if (!variantSnapshot.exists) {
        throw Exception('Product variant not found.');
      }
      if (variantSnapshot.data()?['storeId'] != storeId ||
          variantSnapshot.data()?['isActive'] == false) {
        throw StateError('Biến thể không thuộc cửa hàng hoặc đã bị lưu trữ.');
      }

      final beforeStock =
          (variantSnapshot.data()?['stock'] as num?)?.toInt() ?? 0;
      final afterStock = beforeStock + quantity;
      if (afterStock < 0) {
        throw StateError('Tồn kho không đủ. Tồn hiện tại: $beforeStock.');
      }

      // Update variant stock count
      transaction.update(variantRef, {'stock': afterStock});

      final sku = variantSnapshot.data()?['sku'] ?? '';
      final color = variantSnapshot.data()?['color'] ?? '';
      final size = variantSnapshot.data()?['size'] ?? '';
      final productId = variantSnapshot.data()?['productId'] ?? '';

      final productRef = _firestore.collection('products').doc(productId);
      final productSnapshot = await transaction.get(productRef);
      final productName = productSnapshot.data()?['name'] ?? 'Sản phẩm';

      // Trigger Notifications for low stock/out of stock
      if (afterStock <= 5 && beforeStock > 5) {
        final notifRef = _firestore.collection('notifications').doc();
        transaction.set(notifRef, {
          'storeId': storeId,
          'title': 'Cảnh báo tồn kho thấp',
          'message':
              'Biến thể của sản phẩm "$productName" (SKU: $sku, Màu: $color, Size: $size) đã giảm xuống còn $afterStock sản phẩm.',
          'type': 'LOW_STOCK',
          'targetType': 'PRODUCT',
          'targetId': productId,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      if (afterStock == 0 && beforeStock > 0) {
        final notifRef = _firestore.collection('notifications').doc();
        transaction.set(notifRef, {
          'storeId': storeId,
          'title': 'Cảnh báo hết hàng',
          'message':
              'Biến thể của sản phẩm "$productName" (SKU: $sku, Màu: $color, Size: $size) đã hết hàng hoàn toàn.',
          'type': 'OUT_OF_STOCK',
          'targetType': 'PRODUCT',
          'targetId': productId,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Create transaction log
      final model = InventoryTransactionModel(
        id: txRef.id,
        variantId: variantId,
        type: type,
        quantity: quantity,
        beforeStock: beforeStock,
        afterStock: afterStock,
        createdBy: createdBy,
        storeId: storeId,
        createdAt: DateTime.now(),
      );

      transaction.set(txRef, {
        ...model.toFirestore(),
        'reason': reason,
        'note': note,
        'reference': reference,
      });
    });
  }
}
