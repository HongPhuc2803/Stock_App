import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../providers/reports_providers.dart';

class ReportExportService {
  const ReportExportService._();

  static Future<void> sharePdf(
    ReportMetrics metrics, {
    required String period,
    String storeName = 'SmartStock',
  }) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Text(
            '$storeName - Sales report',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text('Period: $period'),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: const ['Metric', 'Value'],
            data: [
              ['Revenue', metrics.totalRevenue.toStringAsFixed(0)],
              ['Profit', metrics.totalProfit.toStringAsFixed(0)],
              ['Orders', metrics.totalOrders.toString()],
              ['Average order', metrics.avgOrderValue.toStringAsFixed(0)],
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Top products',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.TableHelper.fromTextArray(
            headers: const ['Product', 'Quantity', 'Revenue'],
            data: metrics.topProducts
                .take(10)
                .map(
                  (item) => [
                    item.name,
                    '${item.quantity}',
                    item.revenue.toStringAsFixed(0),
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );
    await Printing.sharePdf(
      bytes: await document.save(),
      filename: 'smartstock-report-$period.pdf',
    );
  }

  static String buildCsv(ReportMetrics metrics) {
    String cell(Object? value) => '"${value.toString().replaceAll('"', '""')}"';
    final rows = <List<Object?>>[
      ['product', 'quantity', 'revenue'],
      ...metrics.topProducts.map(
        (item) => [item.name, item.quantity, item.revenue.toStringAsFixed(2)],
      ),
    ];
    return rows.map((row) => row.map(cell).join(',')).join('\r\n');
  }

  static Future<void> copyCsv(ReportMetrics metrics) =>
      Clipboard.setData(ClipboardData(text: '\uFEFF${buildCsv(metrics)}'));

  static Uint8List csvBytes(ReportMetrics metrics) =>
      Uint8List.fromList(utf8.encode('\uFEFF${buildCsv(metrics)}'));
}
