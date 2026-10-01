import 'package:flutter_test/flutter_test.dart';
import 'package:smartstock/features/pos/presentation/providers/cart_providers.dart';
import 'package:smartstock/features/products/domain/entities/product.dart';
import 'package:smartstock/features/products/domain/entities/product_variant.dart';

void main() {
  final product = Product(
    id: 'product-1',
    name: 'Coffee',
    description: '',
    imageUrl: '',
    categoryId: 'category-1',
    storeId: 'store-1',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
  const variant = ProductVariant(
    id: 'variant-1',
    productId: 'product-1',
    sku: 'COFFEE-1',
    barcode: '123456',
    color: '',
    size: '1kg',
    costPrice: 60,
    sellingPrice: 100,
    stock: 2,
    storeId: 'store-1',
  );

  test('cart never exceeds available stock', () {
    final cart = CartNotifier();
    cart.addItem(variant, product);
    cart.addItem(variant, product);
    cart.addItem(variant, product);

    expect(cart.state.items.single.quantity, 2);
    expect(cart.state.total, 200);
  });

  test('quantity zero removes item', () {
    final cart = CartNotifier()..addItem(variant, product);
    cart.updateQuantity(variant.id, 0);
    expect(cart.state.items, isEmpty);
  });

  test('discount is clamped to the cart subtotal', () {
    final cart = CartNotifier()..addItem(variant, product);
    cart.setDiscount(-20);
    expect(cart.state.discount, 0);

    cart.setDiscount(500);
    expect(cart.state.discount, 100);
    expect(cart.state.total, 0);
  });
}
