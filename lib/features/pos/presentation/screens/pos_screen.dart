import 'package:flutter/material.dart';

import '../../../../core/errors/user_error_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/entities/product_variant.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../providers/cart_providers.dart';
import 'package:go_router/go_router.dart';
import '../widgets/pos_cart_dialog.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  String _searchQuery = '';

  void _showCartDetails() {
    showDialog(context: context, builder: (context) => const PosCartDialog());
  }

  Future<void> _enterBarcode() async {
    final controller = TextEditingController();
    final barcode = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nhập barcode'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Barcode sản phẩm',
            prefixIcon: Icon(Icons.qr_code_scanner),
          ),
          onSubmitted: (value) => Navigator.pop(dialogContext, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Tìm'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || barcode == null || barcode.isEmpty) return;

    final products = ref.read(productsWithVariantsProvider).value ?? [];
    for (final item in products) {
      final matches = item.variants.where(
        (variant) => variant.barcode == barcode,
      );
      if (matches.isNotEmpty) {
        ref.read(cartProvider.notifier).addItem(matches.first, item.product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã thêm ${item.product.name} vào giỏ.')),
        );
        return;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Không tìm thấy barcode trong cửa hàng.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsWithVariantsAsync = ref.watch(productsWithVariantsProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final selectedCategoryId = ref.watch(selectedCategoryFilterProvider);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF004AC6)),
          onPressed: () {},
        ),
        title: const Text(
          'SmartStock POS',
          style: TextStyle(
            color: Color(0xFF004AC6),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          ref
              .watch(notificationsStreamProvider)
              .when(
                data: (list) {
                  final unreadCount = list.where((n) => !n.isRead).length;
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none,
                          color: Color(0xFF004AC6),
                        ),
                        onPressed: () {
                          final role =
                              ref
                                  .read(currentAppUserProvider)
                                  ?.role
                                  .toUpperCase() ??
                              'STAFF';
                          final basePath = role == 'OWNER'
                              ? '/owner'
                              : (role == 'WAREHOUSE_MANAGER'
                                    ? '/warehouse'
                                    : '/staff');
                          context.push('$basePath/notifications');
                        },
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const SizedBox(),
                error: (e, s) => const SizedBox(),
              ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFD3E4FE),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Color(0xFF004AC6),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search & Barcode
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFC3C6D7)),
                        ),
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val.toLowerCase().trim();
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Search products, SKU...',
                            hintStyle: TextStyle(
                              color: Color(0xFF737686),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color(0xFF737686),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _enterBarcode,
                    ),
                  ],
                ),
              ),

              // Categories Chips Scroll
              categoriesAsync.when(
                data: (categories) {
                  return SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categories.length + 1,
                      itemBuilder: (context, index) {
                        final isAll = index == 0;
                        final category = isAll ? null : categories[index - 1];
                        final isSelected = isAll
                            ? selectedCategoryId == null
                            : selectedCategoryId == category?.id;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(
                              isAll ? 'All' : category!.name,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF434655),
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              ref
                                  .read(selectedCategoryFilterProvider.notifier)
                                  .state = isAll
                                  ? null
                                  : category!.id;
                            },
                            selectedColor: const Color(0xFF2563EB),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.transparent
                                    : const Color(0xFFC3C6D7),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const SizedBox(height: 38),
                error: (e, s) => const SizedBox(height: 38),
              ),

              const SizedBox(height: 16),

              // Products Grid
              Expanded(
                child: productsWithVariantsAsync.when(
                  data: (productsWithVariantsList) {
                    // Extract all variants as individual purchasable items
                    final List<VariantWithParentProduct> list = [];
                    for (final item in productsWithVariantsList) {
                      for (final variant in item.variants) {
                        list.add(
                          VariantWithParentProduct(
                            product: item.product,
                            variant: variant,
                          ),
                        );
                      }
                    }

                    // Apply local search filter
                    final filtered = list.where((item) {
                      if (_searchQuery.isEmpty) return true;
                      final pName = item.product.name.toLowerCase();
                      final sku = item.variant.sku.toLowerCase();
                      final barcode = item.variant.barcode.toLowerCase();
                      return pName.contains(_searchQuery) ||
                          sku.contains(_searchQuery) ||
                          barcode.contains(_searchQuery);
                    }).toList();

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text(
                          'Không có sản phẩm nào khả dụng.',
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 90,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final variant = item.variant;
                        final product = item.product;
                        final isLowStock = variant.stock <= 10;

                        return Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          child: InkWell(
                            onTap: () {
                              ref
                                  .read(cartProvider.notifier)
                                  .addItem(variant, product);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image with stock indicator
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Stack(
                                      children: [
                                        product.imageUrl.isNotEmpty
                                            ? Image.network(
                                                product.imageUrl,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                              )
                                            : const Center(
                                                child: Icon(
                                                  Icons.image_outlined,
                                                  color: Color(0xFF94A3B8),
                                                ),
                                              ),
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isLowStock
                                                  ? const Color(
                                                      0xFFba1a1a,
                                                    ).withValues(alpha: 0.1)
                                                  : const Color(
                                                      0xFF00714d,
                                                    ).withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '${variant.stock} in stock',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: isLowStock
                                                    ? const Color(0xFFba1a1a)
                                                    : const Color(0xFF00714d),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Details
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0B1C30),
                                        ),
                                      ),
                                      Text(
                                        'SKU: ${variant.sku}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '\$${variant.sellingPrice.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0B1C30),
                                            ),
                                          ),
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF2563EB,
                                              ).withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              size: 16,
                                              color: Color(0xFF2563EB),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(
                    child: Text('Lỗi tải sản phẩm: ${userErrorMessage(e)}'),
                  ),
                ),
              ),
            ],
          ),

          // Persistent Cart Drawer
          if (cart.items.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF2563EB,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.shopping_cart_outlined,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            Positioned(
                              top: -2,
                              right: -2,
                              child: CircleAvatar(
                                radius: 8,
                                backgroundColor: const Color(0xFF2563EB),
                                child: Text(
                                  '${cart.items.fold<int>(0, (sum, item) => sum + item.quantity)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Giỏ hàng hiện tại',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              '\$${cart.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B1C30),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _showCartDetails,
                      child: const Row(
                        children: [
                          Text('Checkout'),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class VariantWithParentProduct {
  final Product product;
  final ProductVariant variant;

  VariantWithParentProduct({required this.product, required this.variant});
}
