import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/entities/event_entity.dart';

class EventPdfGenerator {
  static Future<Uint8List> generateReceipt(EventEntity event) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('EVENT RECEIPT', 
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.Text('ID: ${event.id.toUpperCase()}', 
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: event.isCompleted ? PdfColors.green100 : PdfColors.blue100,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Text(
                    event.isCompleted ? 'COMPLETED' : 'UPCOMING',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, 
                      color: event.isCompleted ? PdfColors.green900 : PdfColors.blue900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Divider(thickness: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 16),

            // Event Info
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Event Name'),
                      pw.Text(event.name, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 12),
                      _sectionTitle('Location'),
                      pw.Text(event.address),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Event Schedule'),
                      pw.Text('From: ${dateFormat.format(event.startDate)}'),
                      pw.Text('To:     ${dateFormat.format(event.endDate)}'),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 32),

            // Items Table
            pw.Text('CATEGORY REQUIREMENTS', 
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(120),
                1: const pw.FixedColumnWidth(120),
                2: const pw.FixedColumnWidth(60),
                3: const pw.FixedColumnWidth(80),
                4: const pw.FlexColumnWidth(),
              },
              children: [
                // Table Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    _tableCell('Category', isHeader: true),
                    _tableCell('Subcategory', isHeader: true),
                    _tableCell('Qty', isHeader: true),
                    _tableCell('Size', isHeader: true),
                    _tableCell('Notes', isHeader: true),
                  ],
                ),
                // Table Rows
                ...event.items.map((item) {
                  return pw.TableRow(
                    children: [
                      _tableCell(item.categoryName),
                      _tableCell(item.subcategoryName == '—' ? '' : item.subcategoryName),
                      _tableCell(item.quantity.toString()),
                      _tableCell(item.size ?? ''),
                      _tableCell(item.additionalNotes ?? ''),
                    ],
                  );
                }),
              ],
            ),
            
            pw.SizedBox(height: 48),
            pw.Divider(thickness: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text('Generated by Event Management App', 
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(title.toUpperCase(), 
        style: pw.TextStyle(
          fontSize: 9, 
          color: PdfColors.grey600, 
          fontWeight: pw.FontWeight.bold,
        )),
    );
  }

  static pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
