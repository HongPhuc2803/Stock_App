import 'package:flutter/material.dart';

import '../../../../core/errors/user_error_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../providers/customer_providers.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'ALL'; // ALL or VIP

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _archiveCustomer(String id, String storeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Lưu trữ khách hàng?'),
        content: const Text(
          'Khách hàng sẽ bị ẩn nhưng lịch sử đơn hàng vẫn được giữ lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Lưu trữ'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(customerFormControllerProvider.notifier)
        .archiveCustomer(id, storeId);
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersStreamProvider);
    final user = ref.watch(currentAppUserProvider);
    final role = user?.role.toUpperCase() ?? 'STAFF';
    final basePath = role == 'OWNER' ? '/owner' : '/staff';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Danh Sách Khách Hàng',
          style: TextStyle(
            color: Color(0xFF004AC6),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1C30)),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm khách hàng (tên, SĐT)...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF737686),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFC3C6D7)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (val) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilterChip(
                      label: const Text('Tất cả'),
                      selected: _selectedFilter == 'ALL',
                      selectedColor: const Color(0xFFD3E4FE),
                      labelStyle: TextStyle(
                        color: _selectedFilter == 'ALL'
                            ? const Color(0xFF004AC6)
                            : const Color(0xFF434655),
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFilter = 'ALL';
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Thành viên VIP'),
                      selected: _selectedFilter == 'VIP',
                      selectedColor: const Color(0xFFFFF0D4),
                      labelStyle: TextStyle(
                        color: _selectedFilter == 'VIP'
                            ? const Color(0xFFB25E00)
                            : const Color(0xFF434655),
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFilter = 'VIP';
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Customer Directory List
          Expanded(
            child: customersAsync.when(
              data: (list) {
                // Apply Search
                final query = _searchController.text.trim().toLowerCase();
                var filtered = list.where((c) {
                  final matchesQuery =
                      c.name.toLowerCase().contains(query) ||
                      c.phone.contains(query) ||
                      c.email.toLowerCase().contains(query);
                  final matchesFilter = _selectedFilter == 'ALL' || c.isVip;
                  return matchesQuery && matchesFilter;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'Không tìm thấy khách hàng phù hợp.',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final customer = filtered[index];
                    final initials = customer.name.isNotEmpty
                        ? customer.name.trim().split(' ').last[0].toUpperCase()
                        : '?';

                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: customer.isVip
                              ? const Color(0xFFFFF0D4)
                              : const Color(0xFFE2E8F0),
                          child: Text(
                            initials,
                            style: TextStyle(
                              color: customer.isVip
                                  ? const Color(0xFFB25E00)
                                  : const Color(0xFF475569),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              customer.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B1C30),
                              ),
                            ),
                            if (customer.isVip) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0D4),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'VIP',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFB25E00),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          customer.phone.isNotEmpty
                              ? customer.phone
                              : customer.email,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                        trailing: role == 'OWNER'
                            ? PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'archive') {
                                    _archiveCustomer(
                                      customer.id,
                                      customer.storeId,
                                    );
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'archive',
                                    child: Text('Lưu trữ'),
                                  ),
                                ],
                              )
                            : const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF94A3B8),
                              ),
                        onTap: () {
                          context.push(
                            '$basePath/customers/details/${customer.id}',
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(
                child: Text('Lỗi tải khách hàng: ${userErrorMessage(e)}'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm khách hàng'),
        onPressed: () {
          context.push('$basePath/customers/create');
        },
      ),
    );
  }
}
