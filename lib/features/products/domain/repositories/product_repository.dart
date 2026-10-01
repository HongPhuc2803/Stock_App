import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';

abstract class ProductRepository {
  Stream<List<Category>> getCategories(String storeId);

  Future<void> createCategory(Category category);

  Future<void> updateCategory(Category category);

  Future<void> archiveCategory(String categoryId, String storeId);

  Stream<List<Product>> getProducts(String storeId, {String? categoryId});

  Future<Product?> getProductById(String productId);

  Future<List<ProductVariant>> getProductVariants(String productId);

  Stream<List<ProductVariant>> getStoreVariants(String storeId);

  Future<void> createProduct(Product product, List<ProductVariant> variants);

  Future<void> updateProduct(Product product, List<ProductVariant> variants);

  Future<void> deleteProduct(String productId);
}
