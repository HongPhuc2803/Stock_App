import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../inventory/data/models/inventory_transaction_model.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<List<AppOrder>> getOrders(String storeId) {
    return _firestore
        .collection('orders')
        .where('storeId', isEqualTo: storeId)
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<String> createOrder(AppOrder order) async {
    if (order.items.isEmpty) throw ArgumentError('Giỏ hàng đang trống.');
    if (order.discount < 0) {
      throw ArgumentError('Chiết khấu không được âm.');
    }
    if (!{'CASH', 'CARD', 'ONLINE'}.contains(order.paymentMethod)) {
      throw ArgumentError('Phương thức thanh toán không hợp lệ.');
    }

    final variantIds = <String>{};
    for (final item in order.items) {
      if (item.quantity <= 0) {
        throw ArgumentError('Số lượng bán phải lớn hơn 0.');
      }
      if (!variantIds.add(item.variantId)) {
        throw ArgumentError('Giỏ hàng chứa biến thể bị lặp.');
      }
    }

    final orderRef = _firestore
        .collection('orders')
        .doc(order.id.isEmpty ? null : order.id);
    await _firestore.runTransaction((transaction) async {
      final existingOrder = await transaction.get(orderRef);
      if (existingOrder.exists) return;

      // Firestore requires the read phase to finish before the write phase.
      final changes = <_StockChange>[];
      for (final requestedItem in order.items) {
        final variantRef = _firestore
            .collection('variants')
            .doc(requestedItem.variantId);
        final snapshot = await transaction.get(variantRef);
        if (!snapshot.exists) {
          throw StateError('Biến thể ${requestedItem.sku} không còn tồn tại.');
        }

        final data = snapshot.data()!;
        if (data['storeId'] != order.storeId || data['isActive'] == false) {
          throw StateError('Sản phẩm không thuộc cửa hàng hoặc đã ngừng bán.');
        }
        final beforeStock = (data['stock'] as num?)?.toInt() ?? 0;
        final afterStock = beforeStock - requestedItem.quantity;
        if (afterStock < 0) {
          throw StateError(
            '${requestedItem.productName} (${requestedItem.sku}) chỉ còn '
            '$beforeStock sản phẩm.',
          );
        }

        final canonicalItem = OrderItem(
          variantId: requestedItem.variantId,
          productId: data['productId'] ?? requestedItem.productId,
          productName: requestedItem.productName,
          sku: data['sku'] ?? requestedItem.sku,
          color: data['color'] ?? requestedItem.color,
          size: data['size'] ?? requestedItem.size,
          price: (data['sellingPrice'] as num?)?.toDouble() ?? 0,
          costPrice: (data['costPrice'] as num?)?.toDouble() ?? 0,
          quantity: requestedItem.quantity,
        );
        changes.add(
          _StockChange(
            reference: variantRef,
            item: canonicalItem,
            beforeStock: beforeStock,
            afterStock: afterStock,
          ),
        );
      }

      DocumentReference<Map<String, dynamic>>? customerRef;
      DocumentSnapshot<Map<String, dynamic>>? customerSnapshot;
      if (order.customerId != null && order.customerId!.isNotEmpty) {
        customerRef = _firestore.collection('customers').doc(order.customerId);
        customerSnapshot = await transaction.get(customerRef);
      }

      final canonicalItems = changes.map((change) => change.item).toList();
      final subtotal = canonicalItems.fold<double>(
        0,
        (total, item) => total + item.totalPrice,
      );
      final discount = order.discount.clamp(0, subtotal).toDouble();
      final total = subtotal - discount;

      for (final change in changes) {
        transaction.update(change.reference, {'stock': change.afterStock});
        final txRef = _firestore.collection('inventory_transactions').doc();
        final txModel = InventoryTransactionModel(
          id: txRef.id,
          variantId: change.item.variantId,
          type: 'SALE',
          quantity: -change.item.quantity,
          beforeStock: change.beforeStock,
          afterStock: change.afterStock,
          createdBy: order.createdBy,
          storeId: order.storeId,
          createdAt: order.createdAt,
        );
        transaction.set(txRef, {
          ...txModel.toFirestore(),
          'orderId': orderRef.id,
        });

        if (change.afterStock <= 5 && change.beforeStock > 5) {
          final notificationRef = _firestore.collection('notifications').doc();
          transaction.set(notificationRef, {
            'storeId': order.storeId,
            'title': 'Cảnh báo tồn kho thấp',
            'message':
                '${change.item.productName} '
                '(${change.item.sku}) chỉ còn ${change.afterStock}.',
            'type': change.afterStock == 0 ? 'OUT_OF_STOCK' : 'LOW_STOCK',
            'targetType': 'PRODUCT',
            'targetId': change.item.productId,
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      if (customerRef != null &&
          customerSnapshot != null &&
          customerSnapshot.exists &&
          customerSnapshot.data()?['storeId'] == order.storeId) {
        final data = customerSnapshot.data()!;
        final spent = (data['totalSpent'] as num?)?.toDouble() ?? 0;
        final count = (data['ordersCount'] as num?)?.toInt() ?? 0;
        final points = (data['loyaltyPoints'] as num?)?.toInt() ?? 0;
        final newSpent = spent + total;
        transaction.update(customerRef, {
          'totalSpent': newSpent,
          'ordersCount': count + 1,
          'loyaltyPoints': points + (total / 10).floor(),
          'isVip': newSpent >= 1000,
        });
      }

      final model = OrderModel(
        id: orderRef.id,
        storeId: order.storeId,
        items: canonicalItems,
        subtotal: subtotal,
        discount: discount,
        total: total,
        paymentStatus: 'PAID',
        paymentMethod: order.paymentMethod,
        createdBy: order.createdBy,
        createdAt: order.createdAt,
        customerId: order.customerId,
        customerName: order.customerName,
      );
      transaction.set(orderRef, model.toFirestore());
      final orderNotification = _firestore.collection('notifications').doc();
      transaction.set(orderNotification, {
        'storeId': order.storeId,
        'title': 'Đơn hàng mới',
        'message':
            'Đơn ${orderRef.id.substring(0, 8)} đã thanh toán thành công.',
        'type': 'NEW_ORDER',
        'targetType': 'ORDER',
        'targetId': orderRef.id,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
    return orderRef.id;
  }
}

class _StockChange {
  const _StockChange({
    required this.reference,
    required this.item,
    required this.beforeStock,
    required this.afterStock,
  });

  final DocumentReference<Map<String, dynamic>> reference;
  final OrderItem item;
  final int beforeStock;
  final int afterStock;
}
