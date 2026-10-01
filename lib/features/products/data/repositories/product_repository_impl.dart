import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/product_variant_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepositoryImpl(this._firestore);

  @override
  Stream<List<Category>> getCategories(String storeId) {
    return _firestore
        .collection('categories')
        .where('storeId', isEqualTo: storeId)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .where((doc) => doc.data()['isActive'] != false)
              .map((doc) => CategoryModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<void> createCategory(Category category) async {
    await _ensureCategoryNameAvailable(category);
    final model = CategoryModel(
      id: category.id,
      name: category.name,
      description: category.description,
      storeId: category.storeId,
      createdAt: category.createdAt,
    );
    await _firestore
        .collection('categories')
        .doc(category.id.isEmpty ? null : category.id)
        .set({...model.toFirestore(), 'isActive': true});
  }

  @override
  Future<void> updateCategory(Category category) async {
    await _ensureCategoryNameAvailable(category, excludingId: category.id);
    await _firestore.collection('categories').doc(category.id).update({
      'name': category.name.trim(),
      'description': category.description.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _ensureCategoryNameAvailable(
    Category category, {
    String? excludingId,
  }) async {
    final snapshot = await _firestore
        .collection('categories')
        .where('storeId', isEqualTo: category.storeId)
        .get();
    final normalized = category.name.trim().toLowerCase();
    final duplicated = snapshot.docs.any(
      (doc) =>
          doc.id != excludingId &&
          doc.data()['isActive'] != false &&
          (doc.data()['name'] as String? ?? '').trim().toLowerCase() ==
              normalized,
    );
    if (duplicated) throw StateError('Tên danh mục đã tồn tại.');
  }

  @override
  Future<void> archiveCategory(String categoryId, String storeId) async {
    final products = await _firestore
        .collection('products')
        .where('storeId', isEqualTo: storeId)
        .where('categoryId', isEqualTo: categoryId)
        .get();
    final hasActiveProducts = products.docs.any(
      (doc) => doc.data()['isActive'] != false,
    );
    if (hasActiveProducts) {
      throw StateError('Danh mục đang được sử dụng bởi sản phẩm.');
    }
    await _firestore.collection('categories').doc(categoryId).update({
      'isActive': false,
      'archivedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<Product>> getProducts(String storeId, {String? categoryId}) {
    Query query = _firestore
        .collection('products')
        .where('storeId', isEqualTo: storeId);

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    // Sort by createdAt descending
    query = query.orderBy('createdAt', descending: true);
    query = query.limit(200);

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .where(
            (doc) => (doc.data() as Map<String, dynamic>)['isActive'] != false,
          )
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList(),
    );
  }

  @override
  Future<Product?> getProductById(String productId) async {
    final doc = await _firestore.collection('products').doc(productId).get();
    if (!doc.exists || doc.data()?['isActive'] == false) return null;
    return ProductModel.fromFirestore(doc);
  }

  @override
  Future<List<ProductVariant>> getProductVariants(String productId) async {
    final snapshot = await _firestore
        .collection('variants')
        .where('productId', isEqualTo: productId)
        .get();
    return snapshot.docs
        .where((doc) => doc.data()['isActive'] != false)
        .map((doc) => ProductVariantModel.fromFirestore(doc))
        .toList();
  }

  @override
  Stream<List<ProductVariant>> getStoreVariants(String storeId) {
    return _firestore
        .collection('variants')
        .where('storeId', isEqualTo: storeId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .where((doc) => doc.data()['isActive'] != false)
              .map((doc) => ProductVariantModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> _validateVariants(
    String storeId,
    List<ProductVariant> variants, {
    String? productId,
  }) async {
    if (variants.isEmpty) {
      throw ArgumentError('Sản phẩm phải có ít nhất một biến thể.');
    }

    final skus = <String>{};
    final barcodes = <String>{};
    for (final variant in variants) {
      final sku = variant.sku.trim().toUpperCase();
      final barcode = variant.barcode.trim();
      if (sku.isEmpty) throw ArgumentError('SKU không được để trống.');
      if (!skus.add(sku)) throw StateError('SKU bị trùng trong biểu mẫu: $sku');
      if (barcode.isNotEmpty && !barcodes.add(barcode)) {
        throw StateError('Barcode bị trùng trong biểu mẫu: $barcode');
      }
      if (variant.costPrice < 0 || variant.sellingPrice < 0) {
        throw ArgumentError('Giá sản phẩm không được âm.');
      }

      final skuQuery = await _firestore
          .collection('variants')
          .where('storeId', isEqualTo: storeId)
          .where('skuNormalized', isEqualTo: sku)
          .get();
      final legacyVariants = await _firestore
          .collection('variants')
          .where('storeId', isEqualTo: storeId)
          .get();
      if ([...skuQuery.docs, ...legacyVariants.docs].any(
            (doc) =>
                doc.data()['isActive'] != false &&
                doc.data()['productId'] != productId &&
                doc.id != variant.id,
          ) &&
          legacyVariants.docs.any(
            (doc) =>
                doc.data()['isActive'] != false &&
                doc.data()['productId'] != productId &&
                doc.id != variant.id &&
                (doc.data()['sku'] as String? ?? '').trim().toUpperCase() ==
                    sku,
          )) {
        throw StateError('SKU đã tồn tại: ${variant.sku}');
      }

      if (barcode.isNotEmpty) {
        final barcodeQuery = await _firestore
            .collection('variants')
            .where('storeId', isEqualTo: storeId)
            .where('barcode', isEqualTo: barcode)
            .get();
        if (barcodeQuery.docs.any(
          (doc) =>
              doc.data()['isActive'] != false &&
              doc.data()['productId'] != productId &&
              doc.id != variant.id,
        )) {
          throw StateError('Barcode đã tồn tại: $barcode');
        }
      }
    }
  }

  @override
  Future<void> createProduct(
    Product product,
    List<ProductVariant> variants,
  ) async {
    await _validateVariants(product.storeId, variants);
    final batch = _firestore.batch();

    // 1. Create product doc
    final productRef = _firestore.collection('products').doc();
    final newProduct = ProductModel(
      id: productRef.id,
      name: product.name,
      description: product.description,
      imageUrl: product.imageUrl,
      categoryId: product.categoryId,
      storeId: product.storeId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    batch.set(productRef, {...newProduct.toFirestore(), 'isActive': true});

    // 2. Create variant docs
    for (final variant in variants) {
      final variantRef = _firestore.collection('variants').doc();
      final newVariant = ProductVariantModel(
        id: variantRef.id,
        productId: productRef.id,
        sku: variant.sku,
        barcode: variant.barcode,
        color: variant.color,
        size: variant.size,
        costPrice: variant.costPrice,
        sellingPrice: variant.sellingPrice,
        stock: 0,
        storeId: variant.storeId,
      );
      batch.set(variantRef, {
        ...newVariant.toFirestore(),
        'skuNormalized': variant.sku.trim().toUpperCase(),
        'isActive': true,
      });
    }

    await batch.commit();
  }

  @override
  Future<void> updateProduct(
    Product product,
    List<ProductVariant> variants,
  ) async {
    await _validateVariants(product.storeId, variants, productId: product.id);
    final batch = _firestore.batch();

    // 1. Update product doc
    final productRef = _firestore.collection('products').doc(product.id);
    final updatedProduct = ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      imageUrl: product.imageUrl,
      categoryId: product.categoryId,
      storeId: product.storeId,
      createdAt: product.createdAt,
      updatedAt: DateTime.now(),
    );
    batch.set(productRef, {
      ...updatedProduct.toFirestore(),
      'isActive': true,
    }, SetOptions(merge: true));

    // Preserve stock and identifiers of existing variants. Stock may only be
    // changed through an inventory transaction.
    final oldVariantsSnapshot = await _firestore
        .collection('variants')
        .where('productId', isEqualTo: product.id)
        .get();

    final retainedIds = variants
        .where((item) => item.id.isNotEmpty)
        .map((item) => item.id)
        .toSet();
    for (final doc in oldVariantsSnapshot.docs) {
      if (!retainedIds.contains(doc.id)) {
        batch.update(doc.reference, {
          'isActive': false,
          'archivedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    for (final variant in variants) {
      final variantRef = _firestore
          .collection('variants')
          .doc(variant.id.isEmpty ? null : variant.id);
      var stock = 0;
      if (variant.id.isNotEmpty) {
        final current = oldVariantsSnapshot.docs
            .where((doc) => doc.id == variant.id)
            .firstOrNull;
        stock = (current?.data()['stock'] as num?)?.toInt() ?? 0;
      }
      final newVariant = ProductVariantModel(
        id: variantRef.id,
        productId: product.id,
        sku: variant.sku,
        barcode: variant.barcode,
        color: variant.color,
        size: variant.size,
        costPrice: variant.costPrice,
        sellingPrice: variant.sellingPrice,
        stock: stock,
        storeId: variant.storeId,
      );
      batch.set(variantRef, {
        ...newVariant.toFirestore(),
        'skuNormalized': variant.sku.trim().toUpperCase(),
        'isActive': true,
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  @override
  Future<void> deleteProduct(String productId) async {
    final batch = _firestore.batch();

    batch.update(_firestore.collection('products').doc(productId), {
      'isActive': false,
      'archivedAt': FieldValue.serverTimestamp(),
    });

    // 2. Query and delete all variants
    final variantsSnapshot = await _firestore
        .collection('variants')
        .where('productId', isEqualTo: productId)
        .get();

    for (final doc in variantsSnapshot.docs) {
      batch.update(doc.reference, {
        'isActive': false,
        'archivedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }
}
