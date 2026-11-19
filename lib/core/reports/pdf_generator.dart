import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/models.dart';

class PdfReportGenerator {
  static Future<void> printReceipt({
    required Payment payment,
    required Tenant tenant,
    required Invoice invoice,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('LandLord Remastered',
                            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                        pw.Text('Official Money Receipt',
                            style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Receipt No: ${payment.id.toUpperCase()}',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Date: ${payment.date}'),
                      ],
                    ),
                  ],
                ),
                pw.Divider(thickness: 1.5, color: PdfColors.indigo900),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Received From:', style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 10)),
                          pw.Text(tenant.name, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Phone: ${tenant.phone}'),
                          pw.Text('NID: ${tenant.nationalId}'),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('Billing Period:', style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 10)),
                          pw.Text(invoice.period, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Payment Method: ${payment.method.toUpperCase()}'),
                          pw.Text('Ref: ${payment.transactionRef}'),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.TableHelper.fromTextArray(
                  headers: ['Description', 'Amount (BDT)'],
                  data: [
                    ['Monthly Unit Rent', '৳ ${invoice.rent.toStringAsFixed(0)}'],
                    ['Utility & Service Line Charges', '৳ ${invoice.utilityTotal.toStringAsFixed(0)}'],
                    ['Total Invoice Amount', '৳ ${invoice.amount.toStringAsFixed(0)}'],
                    ['Amount Received in this Transaction', '৳ ${payment.amount.toStringAsFixed(0)}'],
                    ['Remaining Due Balance', '৳ ${invoice.balance.toStringAsFixed(0)}'],
                  ],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo800),
                  cellHeight: 28,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerRight,
                  },
                ),
                pw.SizedBox(height: 40),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Container(width: 140, height: 1, color: PdfColors.grey500),
                        pw.SizedBox(height: 4),
                        pw.Text('Tenant Signature', style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Container(width: 140, height: 1, color: PdfColors.grey500),
                        pw.SizedBox(height: 4),
                        pw.Text('Authorized Signature', style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                pw.Spacer(),
                pw.Center(
                  child: pw.Text('Generated electronically by LandLord Remastered — Offline Edition',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static Future<void> printFinancialReport({
    required String startDate,
    required String endDate,
    required double totalIncome,
    required double totalExpense,
    required List<Payment> payments,
    required List<Expense> expenses,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('LandLord Portfolio Financial Statement',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                pw.Text('$startDate to $endDate', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.indigo50,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(children: [
                  pw.Text('Total Collected', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  pw.Text('৳ ${totalIncome.toStringAsFixed(0)}',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                ]),
                pw.Column(children: [
                  pw.Text('Total Expenses', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  pw.Text('৳ ${totalExpense.toStringAsFixed(0)}',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                ]),
                pw.Column(children: [
                  pw.Text('Net Operating Surplus', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  pw.Text('৳ ${(totalIncome - totalExpense).toStringAsFixed(0)}',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                ]),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Revenue Collections', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Txn Ref', 'Method', 'Amount (BDT)'],
            data: payments.map((p) => [p.date, p.transactionRef, p.method.toUpperCase(), '৳ ${p.amount.toStringAsFixed(0)}']).toList(),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo800),
            headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
            cellHeight: 22,
          ),
          pw.SizedBox(height: 20),
          pw.Text('Operating Expenses', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Category', 'Description', 'Amount (BDT)'],
            data: expenses.map((e) => [e.date, e.category, e.description, '৳ ${e.amount.toStringAsFixed(0)}']).toList(),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
            headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
            cellHeight: 22,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
