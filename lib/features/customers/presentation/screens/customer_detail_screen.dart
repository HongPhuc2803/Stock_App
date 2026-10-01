import 'package:flutter/material.dart';

import '../../../../core/errors/user_error_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../providers/customer_providers.dart';

class CustomerDetailScreen extends ConsumerWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersStreamProvider);
    final ordersAsync = ref.watch(ordersStreamProvider);
    final user = ref.watch(currentAppUserProvider);
    final role = user?.role.toUpperCase() ?? 'STAFF';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text('Chi Tiết Khách Hàng'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1C30)),
          onPressed: () => context.pop(),
        ),
      ),
      body: customersAsync.when(
        data: (list) {
          final matchingCustomers = list
              .where((c) => c.id == customerId)
              .toList();
          final customer = matchingCustomers.isNotEmpty
              ? matchingCustomers.first
              : null;
          if (customer == null) {
            return const Center(
              child: Text('Không tìm thấy thông tin khách hàng.'),
            );
          }

          final initials = customer.name.isNotEmpty
              ? customer.name.trim().split(' ').last[0].toUpperCase()
              : '?';

          return ordersAsync.when(
            data: (orders) {
              final customerOrders = orders
                  .where((o) => o.customerId == customerId)
                  .toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header Card
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: customer.isVip
                                  ? const Color(0xFFFFF0D4)
                                  : const Color(0xFFD3E4FE),
                              child: Text(
                                initials,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: customer.isVip
                                      ? const Color(0xFFB25E00)
                                      : const Color(0xFF004AC6),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        customer.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0B1C30),
                                        ),
                                      ),
                                      if (customer.isVip) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF0D4),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: const Text(
                                            'VIP',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFB25E00),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (customer.company.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      customer.company,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (role == 'OWNER' || role == 'STAFF')
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Color(0xFF004AC6),
                                ),
                                onPressed: () {
                                  final base = role == 'OWNER'
                                      ? '/owner'
                                      : '/staff';
                                  context.push(
                                    '$base/customers/edit/$customerId',
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bento Grid Stats (4 elements)
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.4,
                      children: [
                        _buildStatCard(
                          'Tổng chi tiêu',
                          '\$${customer.totalSpent.toStringAsFixed(2)}',
                          Icons.payments_outlined,
                          const Color(0xFF004AC6),
                        ),
                        _buildStatCard(
                          'Điểm tích lũy',
                          '${customer.loyaltyPoints}',
                          Icons.star_outline,
                          const Color(0xFFB25E00),
                        ),
                        _buildStatCard(
                          'Số đơn mua',
                          '${customer.ordersCount}',
                          Icons.shopping_cart_outlined,
                          const Color(0xFF006C49),
                        ),
                        _buildStatCard(
                          'AOV',
                          '\$${customer.avgOrderValue.toStringAsFixed(2)}',
                          Icons.receipt_long_outlined,
                          const Color(0xFF7C3AED),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Contact Info Card
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thông tin liên hệ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B1C30),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildContactRow(
                              Icons.phone_outlined,
                              'Số điện thoại',
                              customer.phone,
                            ),
                            if (customer.email.isNotEmpty) ...[
                              const Divider(height: 24),
                              _buildContactRow(
                                Icons.email_outlined,
                                'Email',
                                customer.email,
                              ),
                            ],
                            if (customer.address.isNotEmpty) ...[
                              const Divider(height: 24),
                              _buildContactRow(
                                Icons.location_on_outlined,
                                'Địa chỉ giao hàng',
                                customer.address,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Recent Orders List Card
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Đơn hàng gần đây',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B1C30),
                              ),
                            ),
                            const SizedBox(height: 12),
                            customerOrders.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 24.0,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Khách hàng chưa có lịch sử mua hàng.',
                                        style: TextStyle(
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: customerOrders.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(height: 24),
                                    itemBuilder: (context, index) {
                                      final order = customerOrders[index];
                                      final dateStr = DateFormat(
                                        'dd/MM/yyyy HH:mm',
                                      ).format(order.createdAt);

                                      return InkWell(
                                        onTap: () {
                                          final routePath = role == 'OWNER'
                                              ? '/owner'
                                              : '/staff';
                                          context.push(
                                            '$routePath/orders/details/${order.id}',
                                          );
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Đơn #${order.id.length > 8 ? order.id.substring(order.id.length - 8) : order.id}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF0B1C30),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  dateStr,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '\$${order.total.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF004AC6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(
              child: Text('Lỗi tải lịch sử đơn hàng: ${userErrorMessage(e)}'),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Text('Lỗi tải thông tin khách hàng: ${userErrorMessage(e)}'),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(icon, size: 16, color: color),
              ],
            ),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B1C30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0B1C30),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
