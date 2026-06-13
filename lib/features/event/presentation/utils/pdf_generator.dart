import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/entities/event_entity.dart';

class EventPdfGenerator {
  static Future<Uint8List> generateReceipt(EventEntity event) async {
    final pdf       = pw.Document();
    final dateFmt   = DateFormat('EEE, MMM d, yyyy');

    // Load the app icon as a PDF image
    final logoBytes = await rootBundle.load('assets/app_icon.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin:     const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // ── Header: App Logo + Status badge ──────────────────────────
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // ── App Logo block ────────────────────────────────────────
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Actual app icon
                    pw.Container(
                      width:  52,
                      height: 52,
                      decoration: pw.BoxDecoration(
                        borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(10)),
                      ),
                      child: pw.ClipRRect(
                        horizontalRadius: 10,
                        verticalRadius:   10,
                        child: pw.Image(logoImage,
                            width: 52, height: 52, fit: pw.BoxFit.cover),
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'MA Productions',
                          style: pw.TextStyle(
                            fontSize:   18,
                            fontWeight: pw.FontWeight.bold,
                            color:      PdfColors.blue900,
                          ),
                        ),
                        pw.Text(
                          'Event Receipt  ·  ID: ${event.id.substring(0, 8).toUpperCase()}',
                          style: const pw.TextStyle(
                              fontSize: 9, color: PdfColors.grey600),
                        ),
                      ],
                    ),
                  ],
                ),

                // ── Status badge ──────────────────────────────────────────
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: event.isCompleted
                        ? PdfColors.green100
                        : PdfColors.blue100,
                    borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(4)),
                  ),
                  child: pw.Text(
                    event.isCompleted ? 'COMPLETED' : 'UPCOMING',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color:      event.isCompleted
                          ? PdfColors.green900
                          : PdfColors.blue900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 20),
            pw.Divider(thickness: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 14),

            // ── Event Info ────────────────────────────────────────────────
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
                        _s(event.name),
                        style: pw.TextStyle(
                            fontSize:   16,
                            fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 10),
                      _sectionTitle('Location'),
                      pw.Text(_s(event.address)),
                    ],
                  ),
                ),
                // Right: Schedule + Setup Date + Contact
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Event Schedule'),
                      pw.Text('From:    ${dateFmt.format(event.startDate)}'),
                      pw.Text('To:        ${dateFmt.format(event.endDate)}'),
                      if (event.setupDate.isNotEmpty) ...[
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Setup Date:  ${_s(event.setupDate)}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ],
                      if (event.contactPerson?.isNotEmpty == true) ...[
                        pw.SizedBox(height: 10),
                        _sectionTitle('Contact Person'),
                        pw.Text(_s(event.contactPerson)),
                        if (event.contactPhone?.isNotEmpty == true)
                          pw.Text(_s(event.contactPhone)),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 28),

            // ── Category Requirements Table ───────────────────────────────
            pw.Text(
              'CATEGORY REQUIREMENTS',
              style: pw.TextStyle(
                  fontSize:   13,
                  fontWeight: pw.FontWeight.bold,
                  color:      PdfColors.blue900),
            ),
            pw.SizedBox(height: 6),
            pw.Table(
              border:        pw.TableBorder.all(
                  color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                // Column order: Category | Subcategory | L | W | H | D | Qty | Notes
                0: const pw.FixedColumnWidth(72),  // Category
                1: const pw.FixedColumnWidth(88),  // Subcategory
                2: const pw.FixedColumnWidth(38),  // L
                3: const pw.FixedColumnWidth(38),  // W
                4: const pw.FixedColumnWidth(38),  // H
                5: const pw.FixedColumnWidth(38),  // D
                6: const pw.FixedColumnWidth(28),  // Qty
                7: const pw.FlexColumnWidth(),     // Notes
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                      color: PdfColors.grey100),
                  children: [
                    _tableCell('Category',    isHeader: true),
                    _tableCell('Subcategory', isHeader: true),
                    _tableCell('L',           isHeader: true),
                    _tableCell('W',           isHeader: true),
                    _tableCell('H',           isHeader: true),
                    _tableCell('D',           isHeader: true),
                    _tableCell('Qty',         isHeader: true),
                    _tableCell('Notes',       isHeader: true),
                  ],
                ),
                // Data rows
                ...event.items.map(
                  (item) => pw.TableRow(children: [
                    _tableCell(_s(item.categoryName)),
                    _tableCell(item.subcategoryName == '—'
                        ? ''
                        : _s(item.subcategoryName)),
                    _tableCell(_s(item.length)),
                    _tableCell(_s(item.width)),
                    _tableCell(_s(item.height)),
                    _tableCell(_s(item.depth)),
                    _tableCell(item.quantity.toString()),
                    _tableCell(_s(item.additionalNotes)),
                  ]),
                ),
              ],
            ),

            pw.SizedBox(height: 40),
            pw.Divider(thickness: 1, color: PdfColors.grey300),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ── Latin-1 / cp1252 sanitiser ────────────────────────────────────────────
  /// Replaces characters outside the cp1252 range used by built-in PDF fonts
  /// (Helvetica etc.) so they don't render as blank boxes.
  static String _s(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    return raw
        .replaceAll('–', '-')  // en-dash  → hyphen
        .replaceAll('—', '-')  // em-dash  → hyphen
        .replaceAll('‘', "'")  // left  '  → apostrophe
        .replaceAll('’', "'")  // right '  → apostrophe
        .replaceAll('“', '"')  // left  "  → quote
        .replaceAll('”', '"'); // right "  → quote
    // U+00B7 (·, middle dot) is valid in Latin-1 — no substitution needed.
  }

  // ── Shared widgets ────────────────────────────────────────────────────────

  static pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Text(
        title.toUpperCase(),
        style: pw.TextStyle(
          fontSize:   9,
          color:      PdfColors.grey600,
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
          fontSize:   isHeader ? 9 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
