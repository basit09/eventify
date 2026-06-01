import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/entities/event_category_item.dart';
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
            // ── Header ───────────────────────────────────────────────────
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'EVENT RECEIPT',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.Text(
                      'ID: ${event.id.toUpperCase()}',
                      style: const pw.TextStyle(
                          fontSize: 10, color: PdfColors.grey700),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: event.isCompleted
                        ? PdfColors.green100
                        : PdfColors.blue100,
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Text(
                    event.isCompleted ? 'COMPLETED' : 'UPCOMING',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: event.isCompleted
                          ? PdfColors.green900
                          : PdfColors.blue900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Divider(thickness: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 16),

            // ── Event Info ───────────────────────────────────────────────
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left: Name + Location
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Event Name'),
                      pw.Text(
                        event.name,
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 12),
                      _sectionTitle('Location'),
                      pw.Text(event.address),
                    ],
                  ),
                ),
                // Right: Schedule + Setup Date + Contact
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Event Schedule'),
                      pw.Text('From:   ${dateFormat.format(event.startDate)}'),
                      pw.Text('To:       ${dateFormat.format(event.endDate)}'),
                      pw.Text(
                          'Setup:  ${dateFormat.format(event.setupDate)}'),
                      if (event.contactPerson?.isNotEmpty == true) ...[
                        pw.SizedBox(height: 12),
                        _sectionTitle('Contact Person'),
                        pw.Text(event.contactPerson!),
                        if (event.contactPhone?.isNotEmpty == true)
                          pw.Text(event.contactPhone!),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 32),

            // ── Category Requirements Table ───────────────────────────────
            pw.Text(
              'CATEGORY REQUIREMENTS',
              style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(70),  // Category  (reduced)
                1: const pw.FixedColumnWidth(90),  // Subcategory
                2: const pw.FixedColumnWidth(28),  // Qty
                3: const pw.FixedColumnWidth(40),  // L
                4: const pw.FixedColumnWidth(40),  // W
                5: const pw.FixedColumnWidth(40),  // H
                6: const pw.FixedColumnWidth(40),  // D
                7: const pw.FlexColumnWidth(),     // Notes
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration:
                      const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    _tableCell('Category', isHeader: true),
                    _tableCell('Subcategory', isHeader: true),
                    _tableCell('Qty', isHeader: true),
                    _tableCell('L', isHeader: true),
                    _tableCell('W', isHeader: true),
                    _tableCell('H', isHeader: true),
                    _tableCell('D', isHeader: true),
                    _tableCell('Notes', isHeader: true),
                  ],
                ),
                // Data rows
                ...event.items.map((item) => pw.TableRow(
                      children: [
                        _tableCell(item.categoryName),
                        _tableCell(item.subcategoryName == '—'
                            ? ''
                            : item.subcategoryName),
                        _tableCell(item.quantity.toString()),
                        _tableCell(_dimL(item)),
                        _tableCell(_dimW(item)),
                        _tableCell(_dimH(item)),
                        _tableCell(_dimD(item)),
                        _tableCell(item.additionalNotes ?? ''),
                      ],
                    )),
              ],
            ),

            pw.SizedBox(height: 48),
            pw.Divider(thickness: 1, color: PdfColors.grey300),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ── Dimension helpers ─────────────────────────────────────────────────────

  /// L column: length (row-1) and/or lengthB (row-2), separated by " / "
  static String _dimL(EventCategoryItem item) {
    final parts = [
      if (item.length?.isNotEmpty == true) item.length!,
      if (item.lengthB?.isNotEmpty == true) item.lengthB!,
    ];
    return parts.join(' / ');
  }

  /// W column: width (row-2)
  static String _dimW(EventCategoryItem item) => item.width ?? '';

  /// H column: height (row-1) and/or itemHeight (row-3), separated by " / "
  static String _dimH(EventCategoryItem item) {
    final parts = [
      if (item.height?.isNotEmpty == true) item.height!,
      if (item.itemHeight?.isNotEmpty == true) item.itemHeight!,
    ];
    // Legacy fallback: old "size" field used when all new fields are empty
    if (parts.isEmpty && item.size?.isNotEmpty == true) return item.size!;
    return parts.join(' / ');
  }

  /// D column: depth (row-3)
  static String _dimD(EventCategoryItem item) => item.depth ?? '';

  // ── Shared widgets ────────────────────────────────────────────────────────

  static pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(
        title.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 9,
          color: PdfColors.grey600,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 8,
          fontWeight:
              isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
