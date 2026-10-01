import '../entities/inventory_transaction.dart';

abstract class InventoryRepository {
  Stream<List<InventoryTransaction>> getTransactions(String storeId);

  Future<void> executeStockTransaction({
    required String variantId,
    required int
    quantity, // can be positive (IMPORT, RETURN) or negative (SALE, ADJUSTMENT, DAMAGE)
    required String type, // IMPORT, ADJUSTMENT, SALE, RETURN, DAMAGE
    required String createdBy,
    required String storeId,
    String reason = '',
    String note = '',
    String reference = '',
  });
}
