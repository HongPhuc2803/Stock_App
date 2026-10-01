import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/user_error_message.dart';
import '../../../../core/formatters/app_formatters.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../reports/presentation/providers/reports_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(reportsMetricsProvider);
    final productsAsync = ref.watch(productsStreamProvider);
    final lowStockAsync = ref.watch(lowStockVariantsProvider);
    final storeId = ref.watch(currentStoreIdProvider);
    final store = storeId == null
        ? null
        : ref.watch(storeStreamProvider(storeId)).value;
    final formatter = AppFormatters(currencyCode: store?.currency ?? 'VND');

    return Scaffold(
      appBar: AppBar(
        title: Text(store?.name ?? 'Tổng quan cửa hàng'),
        actions: [
          IconButton(
            tooltip: 'Thông báo',
            onPressed: () => context.push('/owner/notifications'),
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: () async {
              final success = await ref
                  .read(authControllerProvider.notifier)
                  .logout();
              if (success && context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: metricsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _DashboardError(
          message: userErrorMessage(error),
          onRetry: () => ref.invalidate(reportsMetricsProvider),
        ),
        data: (metrics) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(ordersStreamProvider);
            ref.invalidate(productsStreamProvider);
            ref.invalidate(storeVariantsStreamProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Text(
                'Hiệu quả tháng này',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 900 ? 4 : 2;
                  return GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: constraints.maxWidth >= 600 ? 1.8 : 1.25,
                    children: [
                      _MetricCard(
                        'Doanh thu',
                        formatter.money(metrics.totalRevenue),
                        Icons.payments_outlined,
                      ),
                      _MetricCard(
                        'Đơn đã thanh toán',
                        '${metrics.totalOrders}',
                        Icons.receipt_long_outlined,
                      ),
                      _MetricCard(
                        'Sản phẩm',
                        '${productsAsync.value?.length ?? 0}',
                        Icons.inventory_2_outlined,
                      ),
                      _MetricCard(
                        'Sắp/hết hàng',
                        '${lowStockAsync.value?.length ?? 0}',
                        Icons.warning_amber_outlined,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              _SectionHeader(
                title: 'Đơn hàng gần đây',
                actionLabel: 'Xem tất cả',
                onPressed: () => context.push('/owner/orders'),
              ),
              const SizedBox(height: 8),
              if (metrics.recentOrders.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('Chưa có đơn hàng trong kỳ.')),
                  ),
                )
              else
                ...metrics.recentOrders.map(
                  (order) => Card(
                    child: ListTile(
                      onTap: () => context.push('/owner/orders/${order.id}'),
                      leading: const CircleAvatar(
                        child: Icon(Icons.receipt_outlined),
                      ),
                      title: Text(order.customerName ?? 'Khách lẻ'),
                      subtitle: Text(formatter.dateTime(order.createdAt)),
                      trailing: Text(
                        formatter.money(order.total),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              _SectionHeader(
                title: 'Cảnh báo tồn kho',
                actionLabel: 'Mở kho',
                onPressed: () => context.push('/owner/inventory'),
              ),
              const SizedBox(height: 8),
              lowStockAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, stack) =>
                    const Text('Không tải được cảnh báo tồn kho.'),
                data: (items) => items.isEmpty
                    ? const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text('Tồn kho đang ở mức an toàn.'),
                          ),
                        ),
                      )
                    : Card(
                        child: Column(
                          children: items
                              .take(5)
                              .map(
                                (item) => ListTile(
                                  leading: Icon(
                                    item.stock == 0
                                        ? Icons.error_outline
                                        : Icons.warning_amber,
                                    color: item.stock == 0
                                        ? Colors.red
                                        : Colors.orange,
                                  ),
                                  title: Text(item.sku),
                                  trailing: Text(
                                    '${item.stock}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.push('/owner/reports'),
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('Xem báo cáo chi tiết'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(this.title, this.value, this.icon);
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onPressed,
  });
  final String title;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      TextButton(onPressed: onPressed, child: Text(actionLabel)),
    ],
  );
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Thử lại'),
        ),
      ],
    ),
  );
}
