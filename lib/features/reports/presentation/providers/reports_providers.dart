import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../../products/presentation/providers/product_providers.dart';

final reportsFilterProvider = StateProvider<String>((ref) => 'MONTH');
final reportsCustomRangeProvider =
    StateProvider<({DateTime start, DateTime end})?>((ref) => null);

final filteredOrdersProvider = Provider<AsyncValue<List<AppOrder>>>((ref) {
  final ordersAsync = ref.watch(ordersStreamProvider);
  final filter = ref.watch(reportsFilterProvider);
  final customRange = ref.watch(reportsCustomRangeProvider);

  return ordersAsync.whenData((orders) {
    final now = DateTime.now();
    DateTime threshold;
    DateTime? end;
    if (filter == 'CUSTOM' && customRange != null) {
      threshold = DateTime(
        customRange.start.year,
        customRange.start.month,
        customRange.start.day,
      );
      end = DateTime(
        customRange.end.year,
        customRange.end.month,
        customRange.end.day + 1,
      );
    } else if (filter == 'TODAY') {
      threshold = DateTime(now.year, now.month, now.day);
    } else if (filter == 'WEEK') {
      threshold = now.subtract(const Duration(days: 7));
    } else if (filter == 'YEAR') {
      threshold = DateTime(now.year, 1, 1);
    } else {
      // MONTH
      threshold = DateTime(now.year, now.month, 1);
    }

    return orders
        .where(
          (order) =>
              !order.createdAt.isBefore(threshold) &&
              (end == null || order.createdAt.isBefore(end)),
        )
        .toList();
  });
});

class RevenueBarData {
  final String label;
  final double value;

  RevenueBarData(this.label, this.value);
}

class ReportMetrics {
  final double totalRevenue;
  final double totalProfit;
  final int totalOrders;
  final double avgOrderValue;
  final Map<String, double> categorySales; // categoryName -> total sales amount
  final List<RevenueBarData> chartData;
  final List<ProductSalesMetric> topProducts;
  final Map<String, int> paymentMethods;
  final List<AppOrder> recentOrders;

  ReportMetrics({
    required this.totalRevenue,
    required this.totalProfit,
    required this.totalOrders,
    required this.avgOrderValue,
    required this.categorySales,
    required this.chartData,
    required this.topProducts,
    required this.paymentMethods,
    required this.recentOrders,
  });
}

class ProductSalesMetric {
  const ProductSalesMetric({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.revenue,
  });

  final String productId;
  final String name;
  final int quantity;
  final double revenue;
}

final reportsMetricsProvider = Provider<AsyncValue<ReportMetrics>>((ref) {
  final ordersAsync = ref.watch(filteredOrdersProvider);
  final productsAsync = ref.watch(productsStreamProvider);
  final categoriesAsync = ref.watch(categoriesStreamProvider);
  final filter = ref.watch(reportsFilterProvider);

  if (ordersAsync.isLoading ||
      productsAsync.isLoading ||
      categoriesAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (ordersAsync.hasError) {
    return AsyncValue.error(ordersAsync.error!, ordersAsync.stackTrace!);
  }
  if (productsAsync.hasError) {
    return AsyncValue.error(productsAsync.error!, productsAsync.stackTrace!);
  }
  if (categoriesAsync.hasError) {
    return AsyncValue.error(
      categoriesAsync.error!,
      categoriesAsync.stackTrace!,
    );
  }

  final orders = (ordersAsync.value ?? [])
      .where((order) => order.paymentStatus == 'PAID')
      .toList();
  final products = productsAsync.value ?? [];
  final categories = categoriesAsync.value ?? [];

  // 1. Core KPIs
  double totalRevenue = 0.0;
  double totalProfit = 0.0;
  final int totalOrders = orders.length;

  for (final order in orders) {
    totalRevenue += order.total;

    double profitWithoutDiscount = 0.0;
    for (final item in order.items) {
      profitWithoutDiscount += (item.price - item.costPrice) * item.quantity;
    }
    // Net profit for this order
    final netProfit = profitWithoutDiscount - order.discount;
    totalProfit += netProfit;
  }

  final double avgOrderValue = totalOrders > 0
      ? totalRevenue / totalOrders
      : 0.0;

  // 2. Sales by Category
  final Map<String, double> categorySales = {};
  final productSales = <String, ProductSalesMetric>{};
  final paymentMethods = <String, int>{};
  for (final order in orders) {
    paymentMethods.update(
      order.paymentMethod,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
    for (final item in order.items) {
      // Find category of the product
      final product = products.where((p) => p.id == item.productId).firstOrNull;
      final categoryId = product?.categoryId;
      final category = categories.where((c) => c.id == categoryId).firstOrNull;
      final categoryName = category?.name ?? 'Chưa phân loại';

      categorySales[categoryName] =
          (categorySales[categoryName] ?? 0.0) + item.totalPrice;
      final current = productSales[item.productId];
      productSales[item.productId] = ProductSalesMetric(
        productId: item.productId,
        name: item.productName,
        quantity: (current?.quantity ?? 0) + item.quantity,
        revenue: (current?.revenue ?? 0) + item.totalPrice,
      );
    }
  }

  // 3. Chart Data Generation based on Filter Type
  final List<RevenueBarData> chartData = [];
  final now = DateTime.now();

  if (filter == 'CUSTOM') {
    final sorted = orders.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    for (final order in sorted) {
      final label = '${order.createdAt.day}/${order.createdAt.month}';
      final index = chartData.indexWhere((item) => item.label == label);
      if (index == -1) {
        chartData.add(RevenueBarData(label, order.total));
      } else {
        chartData[index] = RevenueBarData(
          label,
          chartData[index].value + order.total,
        );
      }
    }
  } else if (filter == 'TODAY') {
    // Group by hours (last 6 hours or specific slots)
    for (int i = 5; i >= 0; i--) {
      final hour = now.hour - i;
      if (hour < 0) continue;
      final hourStr = '${hour.toString().padLeft(2, '0')}:00';
      final sum = orders
          .where((o) => o.createdAt.hour == hour && o.createdAt.day == now.day)
          .fold<double>(0.0, (sum, o) => sum + o.total);
      chartData.add(RevenueBarData(hourStr, sum));
    }
  } else if (filter == 'WEEK') {
    // Group by last 7 days
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final label = weekdays[date.weekday - 1];
      final sum = orders
          .where(
            (o) =>
                o.createdAt.day == date.day && o.createdAt.month == date.month,
          )
          .fold<double>(0.0, (sum, o) => sum + o.total);
      chartData.add(RevenueBarData(label, sum));
    }
  } else if (filter == 'YEAR') {
    // Group by month of year
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    for (int i = 1; i <= 12; i++) {
      final label = months[i - 1];
      final sum = orders
          .where((o) => o.createdAt.month == i && o.createdAt.year == now.year)
          .fold<double>(0.0, (sum, o) => sum + o.total);
      chartData.add(RevenueBarData(label, sum));
    }
  } else {
    // MONTH (Group by weeks of month: Week 1, Week 2, Week 3, Week 4)
    for (int i = 1; i <= 4; i++) {
      final label = 'W$i';
      final startDay = (i - 1) * 7 + 1;
      final endDay = i * 7;
      final sum = orders
          .where(
            (o) =>
                o.createdAt.day >= startDay &&
                o.createdAt.day <= endDay &&
                o.createdAt.month == now.month,
          )
          .fold<double>(0.0, (sum, o) => sum + o.total);
      chartData.add(RevenueBarData(label, sum));
    }
  }

  return AsyncValue.data(
    ReportMetrics(
      totalRevenue: totalRevenue,
      totalProfit: totalProfit,
      totalOrders: totalOrders,
      avgOrderValue: avgOrderValue,
      categorySales: categorySales,
      chartData: chartData,
      topProducts: productSales.values.toList()
        ..sort((a, b) => b.quantity.compareTo(a.quantity)),
      paymentMethods: paymentMethods,
      recentOrders:
          (orders.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt)))
              .take(5)
              .toList(),
    ),
  );
});

extension IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
