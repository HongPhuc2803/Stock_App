class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String categoryId;
  final String storeId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.categoryId,
    required this.storeId,
    required this.createdAt,
    required this.updatedAt,
  });
}
