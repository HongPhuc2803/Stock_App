class InventoryTransaction {
  final String id;
  final String variantId;
  final String type; // IMPORT, ADJUSTMENT, SALE, RETURN, DAMAGE
  final int quantity;
  final int beforeStock;
  final int afterStock;
  final String createdBy;
  final String storeId;
  final DateTime createdAt;

  const InventoryTransaction({
    required this.id,
    required this.variantId,
    required this.type,
    required this.quantity,
    required this.beforeStock,
    required this.afterStock,
    required this.createdBy,
    required this.storeId,
    required this.createdAt,
  });
}
