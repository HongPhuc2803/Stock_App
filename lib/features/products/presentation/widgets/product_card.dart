import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/product_providers.dart';

class ProductCard extends ConsumerWidget {
  final ProductWithVariants productWithVariants;
  final bool allowManagement;

  const ProductCard({
    super.key,
    required this.productWithVariants,
    this.allowManagement = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = productWithVariants.product;
    final totalStock = productWithVariants.totalStock;
    final price = productWithVariants.displayPrice;

    // Color indicators based on stock level
    Color badgeBgColor;
    Color badgeTextColor;
    String stockText = 'Stock: $totalStock';

    if (totalStock == 0) {
      badgeBgColor = const Color(0xFFba1a1a).withValues(alpha: 0.1);
      badgeTextColor = const Color(0xFFba1a1a);
      stockText = 'Out of Stock';
    } else if (totalStock <= 10) {
      badgeBgColor = const Color(0xFF996100).withValues(alpha: 0.1);
      badgeTextColor = const Color(0xFF784b00);
      stockText = 'Stock: $totalStock (Low)';
    } else {
      badgeBgColor = const Color(0xFF6cf8bb).withValues(alpha: 0.1);
      badgeTextColor = const Color(0xFF00714d);
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported_outlined,
                        color: Color(0xFF94A3B8),
                        size: 32,
                      ),
                    )
                  : const Icon(
                      Icons.inventory_2_outlined,
                      color: Color(0xFF94A3B8),
                      size: 32,
                    ),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: SizedBox(
                height: 96,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top row: Name & Category + Action buttons
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0B1C30),
                                ),
                              ),
                              const SizedBox(height: 2),
                              // We could resolve category name here, but simple placeholder is fine
                              Text(
                                'Category ID: ${product.categoryId}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Actions
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Xem chi tiết',
                              icon: const Icon(
                                Icons.visibility_outlined,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => context.push(
                                '${allowManagement ? '/owner' : '/staff'}/products/${product.id}',
                              ),
                            ),
                            if (allowManagement) const SizedBox(width: 8),
                            if (allowManagement)
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                color: const Color(0xFF434655),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  context.push(
                                    '/owner/products/edit/${product.id}',
                                  );
                                },
                              ),
                            if (allowManagement) const SizedBox(width: 8),
                            if (allowManagement)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                ),
                                color: const Color(0xFFBA1A1A),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  _confirmDelete(
                                    context,
                                    ref,
                                    product.id,
                                    product.name,
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    ),

                    // Bottom row: Price & Stock level badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B1C30),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: badgeTextColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                stockText,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: badgeTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sản phẩm?'),
        content: Text(
          'Bạn có chắc chắn muốn xóa "$name" cùng tất cả các biến thể của nó không?',
        ),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFBA1A1A),
            ),
            child: const Text('Xóa'),
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(productFormControllerProvider.notifier)
                  .deleteProduct(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Đã xóa sản phẩm "$name" thành công.'
                          : 'Xóa thất bại. Vui lòng thử lại.',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
