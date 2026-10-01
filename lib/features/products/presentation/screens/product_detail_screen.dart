import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/product_providers.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({
    required this.productId,
    this.allowManagement = false,
    super.key,
  });

  final String productId;
  final bool allowManagement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsWithVariantsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        actions: [
          if (allowManagement)
            IconButton(
              tooltip: 'Chỉnh sửa',
              onPressed: () => context.push('/owner/products/edit/$productId'),
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: products.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: FilledButton.icon(
            onPressed: () => ref.invalidate(productsStreamProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Thử tải lại'),
          ),
        ),
        data: (items) {
          final matches = items.where((item) => item.product.id == productId);
          if (matches.isEmpty) {
            return const Center(child: Text('Không tìm thấy sản phẩm.'));
          }
          final item = matches.first;
          final product = item.product;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: product.imageUrl.isEmpty
                      ? const Icon(Icons.inventory_2_outlined, size: 72)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, error, stack) => const Icon(
                              Icons.broken_image_outlined,
                              size: 72,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                product.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (product.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(product.description),
              ],
              const SizedBox(height: 24),
              Text('Biến thể', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final variant in item.variants)
                Card(
                  child: ListTile(
                    title: Text(variant.sku),
                    subtitle: Text(
                      '${variant.color} ${variant.size} • Barcode: '
                      '${variant.barcode.isEmpty ? '—' : variant.barcode}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          variant.sellingPrice.toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text('Tồn: ${variant.stock}'),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
