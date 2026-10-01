import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/entities/order.dart';

class ReceiptPdfHelper {
  static Future<void> printReceipt(
    AppOrder order, {
    String? storeName,
    String? storeAddress,
    String? storePhone,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          80 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 5 * PdfPageFormat.mm,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Store Header
              pw.Center(
                child: pw.Text(
                  storeName ?? 'SMARTSTOCK STORE',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              if (storeAddress != null && storeAddress.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Center(
                  child: pw.Text(
                    storeAddress,
                    style: const pw.TextStyle(fontSize: 7),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
              if (storePhone != null && storePhone.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Center(
                  child: pw.Text(
                    'SĐT: $storePhone',
                    style: const pw.TextStyle(fontSize: 7),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
              pw.SizedBox(height: 10),

              // Order Meta Info
              pw.Text(
                'Order ID: ${order.id}',
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.Text(
                'Date: ${order.createdAt.toLocal().toString().substring(0, 19)}',
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.Text(
                'Created By: ${order.createdBy}',
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.Text(
                'Payment Status: ${order.paymentStatus}',
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.Text(
                'Payment Method: ${order.paymentMethod}',
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.SizedBox(height: 5),
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 5),

              // Items Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Item',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                  pw.Text(
                    'Qty',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                  pw.Text(
                    'Total',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),

              // Items List
              ...order.items.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              item.productName,
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                            pw.Text(
                              '${item.sku} (${item.color}/${item.size})',
                              style: const pw.TextStyle(fontSize: 6),
                            ),
                          ],
                        ),
                      ),
                      pw.Text(
                        '${item.quantity}',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                      pw.Text(
                        '\$${item.totalPrice.toStringAsFixed(2)}',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                );
              }),

              pw.SizedBox(height: 5),
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 5),

              // Pricing Summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(
                    '\$${order.subtotal.toStringAsFixed(2)}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
              if (order.discount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Discount:',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.Text(
                      '-\$${order.discount.toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total:',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                  pw.Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 15),
              pw.Center(
                child: pw.Text(
                  'Thank you for shopping with us!',
                  style: pw.TextStyle(
                    fontStyle: pw.FontStyle.italic,
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }
}
