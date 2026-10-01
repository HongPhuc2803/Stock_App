import '../../../products/domain/entities/product.dart';
import '../../../products/domain/entities/product_variant.dart';

class CartItem {
  final ProductVariant variant;
  final Product product;
  final int quantity;

  const CartItem({
    required this.variant,
    required this.product,
    required this.quantity,
  });

  CartItem copyWith({
    ProductVariant? variant,
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      variant: variant ?? this.variant,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  double get totalPrice => variant.sellingPrice * quantity;
}
