import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/async_state_view.dart';
import '../providers/product_providers.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key, this.allowManagement = true});

  final bool allowManagement;

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsWithVariantsAsync = ref.watch(productsWithVariantsProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final selectedCategoryId = ref.watch(selectedCategoryFilterProvider);

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
          'SmartStock',
          style: TextStyle(
            color: Color(0xFF004AC6),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          if (widget.allowManagement)
            IconButton(
              tooltip: 'Quản lý danh mục',
              onPressed: () => context.push('/owner/categories'),
              icon: const Icon(Icons.category_outlined),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFD3E4FE),
              child: const Icon(Icons.person, color: Color(0xFF004AC6)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        ref.read(productSearchQueryProvider.notifier).state =
                            val;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search products...',
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
                  icon: const Icon(Icons.filter_list_outlined),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0xFFC3C6D7)),
                    ),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Categories Filter Chips
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

          // Product List
          Expanded(
            child: AsyncStateView(
              value: productsWithVariantsAsync,
              isEmpty: (products) => products.isEmpty,
              emptyTitle: _searchController.text.trim().isEmpty
                  ? 'Chưa có sản phẩm nào'
                  : 'Không tìm thấy sản phẩm',
              emptyMessage: _searchController.text.trim().isEmpty
                  ? 'Dùng nút thêm để tạo sản phẩm đầu tiên.'
                  : 'Hãy thử từ khóa hoặc bộ lọc khác.',
              emptyIcon: Icons.inventory_2_outlined,
              onRetry: () => ref.invalidate(productsWithVariantsProvider),
              data: (products) => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final item = products[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ProductCard(
                      productWithVariants: item,
                      allowManagement: widget.allowManagement,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.allowManagement
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add),
              onPressed: () => context.push('/owner/products/create'),
            )
          : null,
    );
  }
}
