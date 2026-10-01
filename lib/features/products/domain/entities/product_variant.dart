class ProductVariant {
  final String id;
  final String productId;
  final String sku;
  final String barcode;
  final String color;
  final String size;
  final double costPrice;
  final double sellingPrice;
  final int stock;
  final String storeId;

  const ProductVariant({
    required this.id,
    required this.productId,
    required this.sku,
    required this.barcode,
    required this.color,
    required this.size,
    required this.costPrice,
    required this.sellingPrice,
    required this.stock,
    required this.storeId,
  });
}
