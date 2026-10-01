import 'package:flutter/material.dart';

import '../../../../core/errors/user_error_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../providers/inventory_providers.dart';

class InventoryManagementScreen extends ConsumerStatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  ConsumerState<InventoryManagementScreen> createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState
    extends ConsumerState<InventoryManagementScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(inventoryStatsProvider);
    final variantsWithProductsAsync = ref.watch(variantsWithProductsProvider);
    final user = ref.watch(currentAppUserProvider);
    final role = user?.role.toUpperCase() ?? 'STAFF';

    // Decide back and action routing prefix based on role
    final routePrefix = role == 'OWNER' ? '/owner' : '/warehouse';

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
          'SmartStock Inventory',
          style: TextStyle(
            color: Color(0xFF004AC6),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Lịch sử kho',
            icon: const Icon(Icons.history, color: Color(0xFF004AC6)),
            onPressed: () => context.push(
              role == 'OWNER'
                  ? '/owner/inventory/history'
                  : '/warehouse/history',
            ),
          ),
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
              child: const Icon(Icons.shelves, color: Color(0xFF004AC6)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title section
            const Text(
              'Inventory Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B1C30),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Monitor and adjust your warehouse stock levels.',
              style: TextStyle(fontSize: 14, color: Color(0xFF434655)),
            ),
            const SizedBox(height: 24),

            // Statistics grid
            statsAsync.when(
              data: (stats) => GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.1,
                children: [
                  _buildStatCard(
                    title: 'Total Items',
                    value: '${stats.totalItems}',
                    icon: Icons.inventory_2_outlined,
                    iconColor: const Color(0xFF004AC6),
                  ),
                  _buildStatCard(
                    title: 'Low Stock',
                    value: '${stats.lowStock}',
                    icon: Icons.warning_amber_rounded,
                    iconColor: const Color(0xFF784B00),
                  ),
                  _buildStatCard(
                    title: 'Out of Stock',
                    value: '${stats.outOfStock}',
                    icon: Icons.error_outline_rounded,
                    iconColor: const Color(0xFFBA1A1A),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Lỗi tải thống kê: ${userErrorMessage(e)}'),
            ),
            const SizedBox(height: 24),

            // Action Buttons (Nhập kho, Điều chỉnh)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Nhập hàng (Receive)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      context.push('$routePrefix/inventory/receive');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit_note_outlined),
                    label: const Text('Điều chỉnh kho'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF004AC6),
                      side: const BorderSide(color: Color(0xFFC3C6D7)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () {
                      context.push('$routePrefix/inventory/adjust');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search Bar
            Container(
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
                  hintText: 'Search SKU, barcode or product name...',
                  hintStyle: TextStyle(color: Color(0xFF737686), fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF737686)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Variant List
            variantsWithProductsAsync.when(
              data: (list) {
                // Filter locally
                final filtered = list.where((item) {
                  if (_searchQuery.isEmpty) return true;
                  final pName = item.product?.name.toLowerCase() ?? '';
                  final sku = item.variant.sku.toLowerCase();
                  final barcode = item.variant.barcode.toLowerCase();
                  return pName.contains(_searchQuery) ||
                      sku.contains(_searchQuery) ||
                      barcode.contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(
                      child: Text(
                        'Không tìm thấy sản phẩm/biến thể nào trong kho.',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final variant = item.variant;
                    final product = item.product;

                    // Color indicators based on stock level
                    Color statusColor;
                    String stockStatus = 'In Stock';
                    if (variant.stock == 0) {
                      statusColor = const Color(0xFFba1a1a);
                      stockStatus = 'Out of Stock';
                    } else if (variant.stock <= 10) {
                      statusColor = const Color(0xFF996100);
                      stockStatus = 'Low Stock';
                    } else {
                      statusColor = const Color(0xFF00714d);
                    }

                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child:
                              product?.imageUrl != null &&
                                  product!.imageUrl.isNotEmpty
                              ? Image.network(
                                  product.imageUrl,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.inventory_2_outlined,
                                  color: Color(0xFF94A3B8),
                                ),
                        ),
                        title: Text(
                          product?.name ?? 'Unknown Product',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0B1C30),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SKU: ${variant.sku} | Barcode: ${variant.barcode.isEmpty ? "N/A" : variant.barcode}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              'Size: ${variant.size} | Color: ${variant.color}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${variant.stock}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  stockStatus,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(
                child: Text('Lỗi tải dữ liệu kho: ${userErrorMessage(e)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                Icon(icon, size: 18, color: iconColor),
              ],
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B1C30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
