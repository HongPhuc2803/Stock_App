import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:smartstock/features/reports/presentation/providers/reports_providers.dart';
import 'package:smartstock/features/reports/presentation/services/report_export_service.dart';

void main() {
  final metrics = ReportMetrics(
    totalRevenue: 125000,
    totalProfit: 25000,
    totalOrders: 2,
    avgOrderValue: 62500,
    categorySales: const {'Áo': 125000},
    chartData: [RevenueBarData('T1', 125000)],
    topProducts: const [
      ProductSalesMetric(
        productId: 'p1',
        name: 'Áo "Premium"',
        quantity: 2,
        revenue: 125000,
      ),
    ],
    paymentMethods: const {'CASH': 2},
    recentOrders: const [],
  );

  test('CSV export uses stable columns and escapes values', () {
    final csv = ReportExportService.buildCsv(metrics);
    expect(csv, startsWith('"product","quantity","revenue"'));
    expect(csv, contains('"Áo ""Premium"""'));
    expect(csv, contains('"125000.00"'));
  });

  test('CSV bytes contain UTF-8 BOM for spreadsheet compatibility', () {
    final bytes = ReportExportService.csvBytes(metrics);
    expect(bytes.take(3), utf8.encode('\uFEFF'));
  });
}
