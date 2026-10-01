import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/entities/product_variant.dart';

class CartState {
  final List<CartItem> items;
  final double discount;

  const CartState({this.items = const [], this.discount = 0.0});

  CartState copyWith({List<CartItem>? items, double? discount}) {
    return CartState(
      items: items ?? this.items,
      discount: discount ?? this.discount,
    );
  }

  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get total {
    final t = subtotal - discount;
    return t < 0.0 ? 0.0 : t;
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addItem(ProductVariant variant, Product product) {
    final existingIndex = state.items.indexWhere(
      (item) => item.variant.id == variant.id,
    );

    if (existingIndex >= 0) {
      final existingItem = state.items[existingIndex];
      final newQty = existingItem.quantity + 1;

      // Do not allow adding beyond available stock
      if (newQty > variant.stock) return;

      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[existingIndex] = existingItem.copyWith(quantity: newQty);
      state = state.copyWith(items: updatedItems);
    } else {
      if (variant.stock <= 0) return; // out of stock

      final newItem = CartItem(variant: variant, product: product, quantity: 1);
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }

  void updateQuantity(String variantId, int quantity) {
    if (quantity <= 0) {
      removeItem(variantId);
      return;
    }

    final index = state.items.indexWhere(
      (item) => item.variant.id == variantId,
    );
    if (index < 0) return;

    final item = state.items[index];
    // Check stock limit
    if (quantity > item.variant.stock) return;

    final updatedItems = List<CartItem>.from(state.items);
    updatedItems[index] = item.copyWith(quantity: quantity);
    state = state.copyWith(items: updatedItems);
  }

  void removeItem(String variantId) {
    final updatedItems = state.items
        .where((item) => item.variant.id != variantId)
        .toList();
    state = state.copyWith(items: updatedItems);
  }

  void setDiscount(double discount) {
    final safeDiscount = discount.isFinite
        ? discount.clamp(0, state.subtotal).toDouble()
        : 0.0;
    state = state.copyWith(discount: safeDiscount);
  }

  void clearCart() {
    state = const CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
