import 'package:flutter/material.dart';

import '../../../../core/errors/user_error_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../providers/order_providers.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  String _searchQuery = '';
  String? _statusFilter; // null (All), PAID, PENDING, CANCELLED

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersStreamProvider);
    final user = ref.watch(currentAppUserProvider);
    final role = user?.role.toUpperCase() ?? 'STAFF';
    final routePrefix = role == 'OWNER' ? '/owner' : '/staff';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Lịch Sử Đơn Hàng',
          style: TextStyle(
            color: Color(0xFF004AC6),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter & Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
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
                      hintText: 'Tìm kiếm theo mã đơn hàng...',
                      hintStyle: TextStyle(
                        color: Color(0xFF737686),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF737686)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Choice chips for status filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(label: 'Tất cả', value: null),
                      const SizedBox(width: 8),
                      _buildFilterChip(label: 'Đã thanh toán', value: 'PAID'),
                      const SizedBox(width: 8),
                      _buildFilterChip(label: 'Chờ xử lý', value: 'PENDING'),
                      const SizedBox(width: 8),
                      _buildFilterChip(label: 'Đã hủy', value: 'CANCELLED'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                // Filter locally
                final filtered = orders.where((order) {
                  final matchesSearch = order.id.toLowerCase().contains(
                    _searchQuery,
                  );
                  final matchesStatus =
                      _statusFilter == null ||
                      order.paymentStatus == _statusFilter;
                  return matchesSearch && matchesStatus;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'Không tìm thấy đơn hàng nào.',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final order = filtered[index];
                    final dateStr = DateFormat(
                      'dd/MM/yyyy HH:mm',
                    ).format(order.createdAt);

                    Color statusColor;
                    switch (order.paymentStatus) {
                      case 'PAID':
                        statusColor = const Color(0xFF00714d);
                        break;
                      case 'PENDING':
                        statusColor = const Color(0xFF996100);
                        break;
                      case 'CANCELLED':
                        statusColor = const Color(0xFFba1a1a);
                        break;
                      default:
                        statusColor = Colors.grey;
                    }

                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          context.push(
                            '$routePrefix/orders/details/${order.id}',
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Đơn hàng: #${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length)}...',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF0B1C30),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      order.paymentStatus,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Thời gian: $dateStr',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              Text(
                                'Số sản phẩm: ${order.items.fold<int>(0, (sum, item) => sum + item.quantity)} món',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Thanh toán: ${order.paymentMethod}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '\$${order.total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(
                child: Text(
                  'Lỗi tải danh sách đơn hàng: ${userErrorMessage(e)}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label, required String? value}) {
    final isSelected = _statusFilter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF434655),
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _statusFilter = selected ? value : null;
        });
      },
      selectedColor: const Color(0xFF2563EB),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? Colors.transparent : const Color(0xFFC3C6D7),
        ),
      ),
    );
  }
}
