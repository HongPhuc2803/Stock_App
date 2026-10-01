import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/services/product_image_service.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/repositories/product_repository.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.watch(firestoreProvider));
});

final productImageServiceProvider = Provider<ProductImageService>((ref) {
  return ProductImageService(FirebaseStorage.instance, ImagePicker());
});

final currentAppUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authStateChangesProvider).value;
});

final currentStoreIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentAppUserProvider);
  return user?.storeId;
});

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return const Stream.empty();
  return ref.watch(productRepositoryProvider).getCategories(storeId);
});

final productSearchQueryProvider = StateProvider<String>((ref) => '');

final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return const Stream.empty();
  final categoryId = ref.watch(selectedCategoryFilterProvider);
  return ref
      .watch(productRepositoryProvider)
      .getProducts(storeId, categoryId: categoryId);
});

final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsStreamProvider);
  return productsAsync;
});

final productVariantsFutureProvider =
    FutureProvider.family<List<ProductVariant>, String>((ref, productId) {
      return ref.watch(productRepositoryProvider).getProductVariants(productId);
    });

final storeVariantsStreamProvider = StreamProvider<List<ProductVariant>>((ref) {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return const Stream.empty();
  return ref.watch(productRepositoryProvider).getStoreVariants(storeId);
});

final lowStockVariantsProvider = Provider<AsyncValue<List<ProductVariant>>>((
  ref,
) {
  final variantsAsync = ref.watch(storeVariantsStreamProvider);
  final storeId = ref.watch(currentStoreIdProvider);
  final threshold = storeId == null
      ? 10
      : ref.watch(storeStreamProvider(storeId)).value?.lowStockThreshold ?? 10;
  return variantsAsync.whenData((variants) {
    return variants.where((variant) => variant.stock <= threshold).toList();
  });
});

class ProductFormController extends StateNotifier<AsyncValue<void>> {
  final ProductRepository _productRepository;

  ProductFormController(this._productRepository)
    : super(const AsyncValue.data(null));

  Future<bool> createProduct({
    required Product product,
    required List<ProductVariant> variants,
  }) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      await _productRepository.createProduct(product, variants);
    });
    state = result;
    return !result.hasError;
  }

  Future<bool> updateProduct({
    required Product product,
    required List<ProductVariant> variants,
  }) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      await _productRepository.updateProduct(product, variants);
    });
    state = result;
    return !result.hasError;
  }

  Future<bool> deleteProduct(String productId) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      await _productRepository.deleteProduct(productId);
    });
    state = result;
    return !result.hasError;
  }
}

final productFormControllerProvider =
    StateNotifierProvider<ProductFormController, AsyncValue<void>>((ref) {
      return ProductFormController(ref.watch(productRepositoryProvider));
    });

class ProductWithVariants {
  final Product product;
  final List<ProductVariant> variants;

  ProductWithVariants({required this.product, required this.variants});

  double get displayPrice {
    if (variants.isEmpty) return 0.0;
    return variants.first.sellingPrice;
  }

  int get totalStock {
    return variants.fold(0, (sum, v) => sum + v.stock);
  }
}

final productsWithVariantsProvider =
    Provider<AsyncValue<List<ProductWithVariants>>>((ref) {
      final productsAsync = ref.watch(filteredProductsProvider);
      final variantsAsync = ref.watch(storeVariantsStreamProvider);

      if (productsAsync.isLoading || variantsAsync.isLoading) {
        return const AsyncValue.loading();
      }
      if (productsAsync.hasError) {
        return AsyncValue.error(
          productsAsync.error!,
          productsAsync.stackTrace!,
        );
      }
      if (variantsAsync.hasError) {
        return AsyncValue.error(
          variantsAsync.error!,
          variantsAsync.stackTrace!,
        );
      }

      final products = productsAsync.value ?? [];
      final variants = variantsAsync.value ?? [];
      final query = ref.watch(productSearchQueryProvider).toLowerCase().trim();

      final list = products
          .map((product) {
            final productVariants = variants
                .where((v) => v.productId == product.id)
                .toList();
            return ProductWithVariants(
              product: product,
              variants: productVariants,
            );
          })
          .where((item) {
            if (query.isEmpty) return true;
            if (item.product.name.toLowerCase().contains(query)) return true;
            return item.variants.any(
              (variant) =>
                  variant.sku.toLowerCase().contains(query) ||
                  variant.barcode.toLowerCase().contains(query),
            );
          })
          .toList();

      return AsyncValue.data(list);
    });
