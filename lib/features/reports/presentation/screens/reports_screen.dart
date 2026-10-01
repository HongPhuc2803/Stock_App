import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../core/errors/user_error_message.dart';
import '../../../../core/formatters/app_formatters.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../providers/reports_providers.dart';
import '../services/report_export_service.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(reportsMetricsProvider);
    final selectedFilter = ref.watch(reportsFilterProvider);
    final storeId = ref.watch(currentStoreIdProvider);
    final store = storeId == null
        ? null
        : ref.watch(storeStreamProvider(storeId)).value;
    final formatter = AppFormatters(currencyCode: store?.currency ?? 'VND');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Báo Cáo & Thống Kê',
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
      body: metricsAsync.when(
        data: (metrics) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Báo cáo kinh doanh',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B1C30),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tổng hợp hiệu quả bán hàng theo kỳ đã chọn.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF434655),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        await ReportExportService.sharePdf(
                          metrics,
                          period: selectedFilter.toLowerCase(),
                          storeName: store?.name ?? 'SmartStock',
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Chia sẻ PDF'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await ReportExportService.copyCsv(metrics);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã sao chép CSV UTF-8.'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.table_view_outlined),
                      label: const Text('Sao chép CSV'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Date Filters Choice Chips segment control
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5EEFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      _buildFilterButton(ref, 'Today', 'TODAY', selectedFilter),
                      _buildFilterButton(ref, 'Week', 'WEEK', selectedFilter),
                      _buildFilterButton(ref, 'Month', 'MONTH', selectedFilter),
                      _buildFilterButton(ref, 'Year', 'YEAR', selectedFilter),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final selected = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(now.year - 5),
                      lastDate: now,
                    );
                    if (selected != null) {
                      ref.read(reportsCustomRangeProvider.notifier).state = (
                        start: selected.start,
                        end: selected.end,
                      );
                      ref.read(reportsFilterProvider.notifier).state = 'CUSTOM';
                    }
                  },
                  icon: const Icon(Icons.date_range_outlined),
                  label: Text(
                    selectedFilter == 'CUSTOM'
                        ? 'Khoảng ngày tùy chọn đang áp dụng'
                        : 'Chọn khoảng ngày',
                  ),
                ),
                const SizedBox(height: 24),

                // Bento KPI Cards Grid
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.3,
                  children: [
                    _buildKpiCard(
                      title: 'Doanh thu',
                      value: formatter.money(metrics.totalRevenue),
                      icon: Icons.payments_outlined,
                      iconColor: const Color(0xFF004AC6),
                      bgTonalColor: const Color(0xFFE5EEFF),
                    ),
                    _buildKpiCard(
                      title: 'Lợi nhuận ước tính',
                      value: formatter.money(metrics.totalProfit),
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: const Color(0xFF006C49),
                      bgTonalColor: const Color(0xFFD0F8E3),
                    ),
                    _buildKpiCard(
                      title: 'Đơn đã thanh toán',
                      value: '${metrics.totalOrders}',
                      icon: Icons.shopping_cart_outlined,
                      iconColor: const Color(0xFF784B00),
                      bgTonalColor: const Color(0xFFFFEEDD),
                    ),
                    _buildKpiCard(
                      title: 'Giá trị đơn TB',
                      value: formatter.money(metrics.avgOrderValue),
                      icon: Icons.receipt_long_outlined,
                      iconColor: const Color(0xFF6A5ACD),
                      bgTonalColor: const Color(0xFFF3E8FF),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Chart: Revenue Trend Custom Painter Cột bar
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
                          'Xu hướng doanh thu',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B1C30),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildBarChart(metrics.chartData, formatter),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Category share progress indicator list
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
                          'Doanh thu theo danh mục',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B1C30),
                          ),
                        ),
                        const SizedBox(height: 16),
                        metrics.categorySales.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24.0),
                                child: Center(
                                  child: Text(
                                    'Chưa có dữ liệu danh mục.',
                                    style: TextStyle(color: Color(0xFF64748B)),
                                  ),
                                ),
                              )
                            : Column(
                                children: metrics.categorySales.entries.map((
                                  entry,
                                ) {
                                  final catName = entry.key;
                                  final sales = entry.value;
                                  final pct = metrics.totalRevenue > 0
                                      ? (sales / metrics.totalRevenue)
                                      : 0.0;

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 12.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              catName,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              '${formatter.money(sales)} (${(pct * 100).toStringAsFixed(1)}%)',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF004AC6),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        LinearProgressIndicator(
                                          value: pct,
                                          backgroundColor: const Color(
                                            0xFFF1F5F9,
                                          ),
                                          color: const Color(0xFF2563EB),
                                          minHeight: 8,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildBreakdownCard(
                  context,
                  title: 'Sản phẩm bán chạy',
                  children: metrics.topProducts.take(5).map((item) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.name),
                      subtitle: Text('${item.quantity} sản phẩm'),
                      trailing: Text(
                        formatter.money(item.revenue),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                _buildBreakdownCard(
                  context,
                  title: 'Phương thức thanh toán',
                  children: metrics.paymentMethods.entries
                      .map(
                        (entry) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(_paymentLabel(entry.key)),
                          trailing: Text('${entry.value} đơn'),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) =>
            Center(child: Text('Lỗi tải báo cáo: ${userErrorMessage(e)}')),
      ),
    );
  }

  Widget _buildFilterButton(
    WidgetRef ref,
    String label,
    String value,
    String currentFilter,
  ) {
    final isSelected = value == currentFilter;
    return Expanded(
      child: InkWell(
        onTap: () {
          ref.read(reportsFilterProvider.notifier).state = value;
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? const Color(0xFF004AC6)
                    : const Color(0xFF434655),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgTonalColor,
  }) {
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
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: bgTonalColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 16, color: iconColor),
                ),
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

  Widget _buildBarChart(
    List<RevenueBarData> chartData,
    AppFormatters formatter,
  ) {
    if (chartData.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(
          child: Text(
            'Không có dữ liệu biểu đồ.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final double maxVal = chartData.map((d) => d.value).fold(0.0, max);
    final double scaleMax = maxVal == 0.0 ? 1.0 : maxVal;

    return SizedBox(
      height: 180,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: chartData.map((data) {
            final double barHeight = (data.value / scaleMax) * 120.0;

            return SizedBox(
              width: 56,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Value tooltip on top of bar
                  Text(
                    formatter.money(data.value),
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Bar
                  Container(
                    width: 24,
                    height: max(barHeight, 4.0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // X-axis label
                  Text(
                    data.label,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBreakdownCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (children.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Text('Chưa có dữ liệu.')),
              )
            else
              ...children,
          ],
        ),
      ),
    );
  }

  String _paymentLabel(String value) => switch (value) {
    'CASH' => 'Tiền mặt',
    'CARD' => 'Thẻ',
    'TRANSFER' || 'ONLINE' => 'Chuyển khoản',
    _ => value,
  };
}
