import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/widgets/async_state_view.dart';
import '../providers/inventory_providers.dart';

class InventoryHistoryScreen extends ConsumerStatefulWidget {
  const InventoryHistoryScreen({super.key});

  @override
  ConsumerState<InventoryHistoryScreen> createState() =>
      _InventoryHistoryScreenState();
}

class _InventoryHistoryScreenState
    extends ConsumerState<InventoryHistoryScreen> {
  String _type = 'ALL';

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(inventoryTransactionsStreamProvider);
    final variants = ref.watch(variantsWithProductsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử kho')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Loại giao dịch',
                prefixIcon: Icon(Icons.filter_list),
              ),
              items: const [
                DropdownMenuItem(value: 'ALL', child: Text('Tất cả')),
                DropdownMenuItem(value: 'IMPORT', child: Text('Nhập kho')),
                DropdownMenuItem(
                  value: 'ADJUSTMENT',
                  child: Text('Điều chỉnh'),
                ),
                DropdownMenuItem(value: 'DAMAGE', child: Text('Hàng hỏng')),
                DropdownMenuItem(value: 'LOST', child: Text('Thất thoát')),
                DropdownMenuItem(value: 'EXPIRED', child: Text('Hết hạn')),
                DropdownMenuItem(value: 'SALE', child: Text('Bán hàng')),
              ],
              onChanged: (value) => setState(() => _type = value ?? 'ALL'),
            ),
          ),
          Expanded(
            child: AsyncStateView(
              value: transactions,
              isEmpty: (items) => items.isEmpty,
              emptyTitle: 'Chưa có giao dịch kho',
              emptyMessage:
                  'Các lần nhập, bán và điều chỉnh sẽ xuất hiện tại đây.',
              onRetry: () =>
                  ref.invalidate(inventoryTransactionsStreamProvider),
              data: (items) {
                final filtered = _type == 'ALL'
                    ? items
                    : items.where((item) => item.type == _type).toList();
                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('Không có giao dịch phù hợp bộ lọc.'),
                  );
                }
                final variantItems = variants.value ?? [];
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(inventoryTransactionsStreamProvider);
                    await ref.read(inventoryTransactionsStreamProvider.future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final transaction = filtered[index];
                      final matches = variantItems.where(
                        (item) => item.variant.id == transaction.variantId,
                      );
                      final match = matches.isEmpty ? null : matches.first;
                      final isIncrease = transaction.quantity > 0;
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isIncrease
                                ? Colors.green.withValues(alpha: .12)
                                : Colors.orange.withValues(alpha: .12),
                            child: Icon(
                              isIncrease
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: isIncrease ? Colors.green : Colors.orange,
                            ),
                          ),
                          title: Text(
                            match?.product?.name ?? 'Biến thể đã lưu trữ',
                          ),
                          subtitle: Text(
                            '${_label(transaction.type)} • '
                            '${DateFormat('dd/MM/yyyy HH:mm').format(transaction.createdAt)}\n'
                            'Tồn: ${transaction.beforeStock} → ${transaction.afterStock}',
                          ),
                          isThreeLine: true,
                          trailing: Text(
                            '${isIncrease ? '+' : ''}${transaction.quantity}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isIncrease ? Colors.green : Colors.orange,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _label(String type) => switch (type) {
    'IMPORT' => 'Nhập kho',
    'ADJUSTMENT' => 'Điều chỉnh',
    'DAMAGE' => 'Hàng hỏng',
    'LOST' => 'Thất thoát',
    'EXPIRED' => 'Hết hạn',
    'SALE' => 'Bán hàng',
    _ => type,
  };
}
