import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/entities/product_variant.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/entities/inventory_transaction.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepositoryImpl(ref.watch(firestoreProvider));
});

final inventoryTransactionsStreamProvider =
    StreamProvider<List<InventoryTransaction>>((ref) {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return const Stream.empty();
      return ref.watch(inventoryRepositoryProvider).getTransactions(storeId);
    });

class InventoryStats {
  final int totalItems;
  final int lowStock;
  final int outOfStock;

  InventoryStats({
    required this.totalItems,
    required this.lowStock,
    required this.outOfStock,
  });
}

final inventoryStatsProvider = Provider<AsyncValue<InventoryStats>>((ref) {
  final variantsAsync = ref.watch(storeVariantsStreamProvider);
  final storeId = ref.watch(currentStoreIdProvider);
  final threshold = storeId == null
      ? 10
      : ref.watch(storeStreamProvider(storeId)).value?.lowStockThreshold ?? 10;
  return variantsAsync.whenData((variants) {
    final totalItems = variants.length;
    final lowStock = variants
        .where((v) => v.stock > 0 && v.stock <= threshold)
        .length;
    final outOfStock = variants.where((v) => v.stock == 0).length;
    return InventoryStats(
      totalItems: totalItems,
      lowStock: lowStock,
      outOfStock: outOfStock,
    );
  });
});

class InventoryFormController extends StateNotifier<AsyncValue<void>> {
  final InventoryRepository _repository;

  InventoryFormController(this._repository)
    : super(const AsyncValue.data(null));

  Future<bool> executeStockTransaction({
    required String variantId,
    required int quantity,
    required String type,
    required String createdBy,
    required String storeId,
    String reason = '',
    String note = '',
    String reference = '',
  }) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      await _repository.executeStockTransaction(
        variantId: variantId,
        quantity: quantity,
        type: type,
        createdBy: createdBy,
        storeId: storeId,
        reason: reason,
        note: note,
        reference: reference,
      );
    });
    state = result;
    return !result.hasError;
  }
}

final inventoryFormControllerProvider =
    StateNotifierProvider<InventoryFormController, AsyncValue<void>>((ref) {
      return InventoryFormController(ref.watch(inventoryRepositoryProvider));
    });

class VariantWithProduct {
  final ProductVariant variant;
  final Product? product;

  VariantWithProduct({required this.variant, this.product});
}

final variantsWithProductsProvider =
    Provider<AsyncValue<List<VariantWithProduct>>>((ref) {
      final variantsAsync = ref.watch(storeVariantsStreamProvider);
      final productsAsync = ref.watch(productsStreamProvider);

      if (variantsAsync.isLoading || productsAsync.isLoading) {
        return const AsyncValue.loading();
      }
      if (variantsAsync.hasError) {
        return AsyncValue.error(
          variantsAsync.error!,
          variantsAsync.stackTrace!,
        );
      }
      if (productsAsync.hasError) {
        return AsyncValue.error(
          productsAsync.error!,
          productsAsync.stackTrace!,
        );
      }

      final variants = variantsAsync.value ?? [];
      final products = productsAsync.value ?? [];

      final list = variants.map((variant) {
        final matchingProducts = products.where(
          (p) => p.id == variant.productId,
        );
        final product = matchingProducts.isNotEmpty
            ? matchingProducts.first
            : null;
        return VariantWithProduct(variant: variant, product: product);
      }).toList();

      return AsyncValue.data(list);
    });
