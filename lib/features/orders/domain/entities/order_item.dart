class OrderItem {
  final String variantId;
  final String productId;
  final String productName;
  final String sku;
  final String color;
  final String size;
  final double price;
  final double costPrice;
  final int quantity;

  const OrderItem({
    required this.variantId,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.color,
    required this.size,
    required this.price,
    required this.costPrice,
    required this.quantity,
  });

  double get totalPrice => price * quantity;
}
