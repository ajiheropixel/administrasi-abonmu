import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Generator PDF laporan — dibuat sepenuhnya di device menggunakan package `pdf`
class ReportPdfGenerator {
  /// Buat dokumen PDF dan kembalikan bytes-nya
  static Future<Uint8List> generate({
    required String reportType,    // 'integrated' | 'production' | 'finance'
    required String startDate,
    required String endDate,
    required Map<String, dynamic> data,
    Map<String, dynamic>? salesData,
    Map<String, dynamic>? expenseData,
  }) async {
    final pdf = pw.Document();

    // Load font & logo
    final font      = await PdfGoogleFonts.nunitoRegular();
    final fontBold  = await PdfGoogleFonts.nunitoBold();
    final fontLight = await PdfGoogleFonts.nunitoLight();

    final fmt = DateFormat('dd MMMM yyyy', 'id');
    final fmtShort = DateFormat('dd/MM/yyyy');
    final now  = DateTime.now();
    final sDate = DateTime.parse(startDate);
    final eDate = DateTime.parse(endDate);

    // Nama laporan berdasarkan tipe
    final titleMap = {
      'integrated':  'Laporan Terintegrasi',
      'production':  'Laporan Produksi',
      'finance':     'Laporan Keuangan',
    };
    final title = titleMap[reportType] ?? 'Laporan';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        header: (ctx) => _buildHeader(title, sDate, eDate, now, fontBold, fontLight),
        footer: (ctx) => _buildFooter(ctx, fontLight),
        build: (ctx) => _buildContent(
          reportType: reportType,
          data: data,
          salesData: salesData,
          expenseData: expenseData,
          fontBold: fontBold,
          font: font,
        ),
      ),
    );

    return pdf.save();
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  static pw.Widget _buildHeader(
    String title,
    DateTime startDate,
    DateTime endDate,
    DateTime printDate,
    pw.Font fontBold,
    pw.Font fontLight,
  ) {
    final fmt = DateFormat('dd MMMM yyyy', 'id');
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue800, width: 2)),
      ),
      padding: const pw.EdgeInsets.only(bottom: 8),
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Rumah Produksi AbonMu',
                  style: pw.TextStyle(
                      font: fontBold, fontSize: 14, color: PdfColors.blue800)),
              pw.SizedBox(height: 2),
              pw.Text(title,
                  style: pw.TextStyle(font: fontBold, fontSize: 11)),
              pw.SizedBox(height: 2),
              pw.Text(
                'Periode: ${fmt.format(startDate)} – ${fmt.format(endDate)}',
                style: pw.TextStyle(
                    font: fontLight, fontSize: 9, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Dicetak: ${fmt.format(printDate)}',
                  style: pw.TextStyle(
                      font: fontLight, fontSize: 9, color: PdfColors.grey600)),
              pw.Text(DateFormat('HH:mm').format(printDate) + ' WIB',
                  style: pw.TextStyle(
                      font: fontLight, fontSize: 9, color: PdfColors.grey600)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Footer ──────────────────────────────────────────────────────────────────
  static pw.Widget _buildFooter(pw.Context ctx, pw.Font fontLight) =>
      pw.Container(
        decoration: const pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
        ),
        padding: const pw.EdgeInsets.only(top: 6),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Sistem Administrasi Rumah Produksi AbonMu',
                style: pw.TextStyle(
                    font: fontLight, fontSize: 8, color: PdfColors.grey600)),
            pw.Text('Halaman ${ctx.pageNumber} dari ${ctx.pagesCount}',
                style: pw.TextStyle(
                    font: fontLight, fontSize: 8, color: PdfColors.grey600)),
          ],
        ),
      );

  // ── Content ─────────────────────────────────────────────────────────────────
  static List<pw.Widget> _buildContent({
    required String reportType,
    required Map<String, dynamic> data,
    Map<String, dynamic>? salesData,
    Map<String, dynamic>? expenseData,
    required pw.Font fontBold,
    required pw.Font font,
  }) {
    switch (reportType) {
      case 'production':
        return _buildProductionContent(data, fontBold, font);
      case 'finance':
        return _buildFinanceContent(salesData ?? {}, expenseData ?? {}, fontBold, font);
      default:
        return _buildIntegratedContent(data, fontBold, font);
    }
  }

  // ── Integrated Content ───────────────────────────────────────────────────────
  static List<pw.Widget> _buildIntegratedContent(
    Map<String, dynamic> data,
    pw.Font fontBold,
    pw.Font font,
  ) {
    final summary = data['summary'] as Map<String, dynamic>? ?? {};
    final productions = data['productions'] as List<dynamic>? ?? [];
    final sales = data['sales'] as List<dynamic>? ?? [];
    final expenses = data['expenses'] as List<dynamic>? ?? [];
    final salesByProduct = data['sales_by_product'] as List<dynamic>? ?? [];

    final widgets = <pw.Widget>[];

    // Ringkasan
    widgets.add(_sectionTitle('Ringkasan', fontBold));
    widgets.add(_summaryTable([
      ['Total Produksi', _fmtNum(summary['total_production'])+ ' pcs'],
      ['Total Penjualan', _fmtCur(summary['total_sales'])],
      ['Total Pengeluaran', _fmtCur(summary['total_expenses'])],
      ['Laba Bersih', _fmtCur(summary['net_profit'])],
      ['Jumlah Transaksi', '${summary['total_transactions'] ?? 0}'],
    ], fontBold, font));
    widgets.add(pw.SizedBox(height: 14));

    // Penjualan per produk
    if (salesByProduct.isNotEmpty) {
      widgets.add(_sectionTitle('Penjualan per Produk', fontBold));
      widgets.add(_dataTable(
        headers: ['Produk', 'Qty Terjual', 'Total Pendapatan'],
        rows: salesByProduct.map((e) {
          final m = e as Map<String, dynamic>;
          return [
            m['name'] as String? ?? '-',
            _fmtNum(m['total_quantity']) + ' pcs',
            _fmtCur(m['total_amount']),
          ];
        }).toList(),
        fontBold: fontBold,
        font: font,
        columnWidths: [3, 1.5, 2],
      ));
      widgets.add(pw.SizedBox(height: 14));
    }

    // Detail produksi (max 30)
    if (productions.isNotEmpty) {
      widgets.add(_sectionTitle('Detail Produksi (${productions.length} data)', fontBold));
      widgets.add(_dataTable(
        headers: ['Tanggal', 'Produk', 'Kategori', 'Jumlah', 'Jenis'],
        rows: productions.take(30).map((e) {
          final m    = e as Map<String, dynamic>;
          final prod = m['product'] as Map<String, dynamic>?;
          return [
            _fmtDate(m['production_date']),
            prod?['name'] as String? ?? '-',
            m['category'] as String? ?? '-',
            _fmtNum(m['quantity']) + ' ${prod?['unit'] ?? 'pcs'}',
            m['type'] as String? ?? '-',
          ];
        }).toList(),
        fontBold: fontBold,
        font: font,
        columnWidths: [1.5, 2.5, 1.5, 1.5, 1],
      ));
      widgets.add(pw.SizedBox(height: 14));
    }

    // Detail penjualan (max 30)
    if (sales.isNotEmpty) {
      widgets.add(_sectionTitle('Detail Penjualan (${sales.length} data)', fontBold));
      widgets.add(_dataTable(
        headers: ['Tanggal', 'Invoice', 'Pelanggan', 'Total'],
        rows: sales.take(30).map((e) {
          final m = e as Map<String, dynamic>;
          final cust = m['customer'] as Map<String, dynamic>?;
          return [
            _fmtDate(m['sale_date']),
            m['invoice_number'] as String? ?? '-',
            cust?['name'] as String? ?? 'Umum',
            _fmtCur(m['total_amount']),
          ];
        }).toList(),
        fontBold: fontBold,
        font: font,
        columnWidths: [1.5, 2, 2, 2],
      ));
      widgets.add(pw.SizedBox(height: 14));
    }

    // Detail pengeluaran (max 30)
    if (expenses.isNotEmpty) {
      widgets.add(_sectionTitle('Detail Pengeluaran (${expenses.length} data)', fontBold));
      widgets.add(_dataTable(
        headers: ['Tanggal', 'Kategori', 'Jumlah', 'Keterangan'],
        rows: expenses.take(30).map((e) {
          final m = e as Map<String, dynamic>;
          return [
            _fmtDate(m['expense_date']),
            m['category'] as String? ?? '-',
            _fmtCur(m['amount']),
            m['description'] as String? ?? '-',
          ];
        }).toList(),
        fontBold: fontBold,
        font: font,
        columnWidths: [1.5, 2, 1.8, 2.5],
      ));
    }

    return widgets;
  }

  // ── Production Content ────────────────────────────────────────────────────
  static List<pw.Widget> _buildProductionContent(
    Map<String, dynamic> data,
    pw.Font fontBold,
    pw.Font font,
  ) {
    final stats = data['statistics'] as Map<String, dynamic>? ?? {};
    final productions = data['productions'] as List<dynamic>? ?? [];
    final widgets = <pw.Widget>[];

    widgets.add(_sectionTitle('Statistik Produksi', fontBold));
    widgets.add(_summaryTable([
      ['Total Produksi', _fmtNum(stats['total_production']) + ' pcs'],
      ['Produksi Rutin', _fmtNum(stats['total_rutin']) + ' pcs'],
      ['Produksi Pesanan', _fmtNum(stats['total_pesanan']) + ' pcs'],
      ['Total Transaksi', '${stats['total_transactions'] ?? 0}'],
    ], fontBold, font));
    widgets.add(pw.SizedBox(height: 14));

    if (productions.isNotEmpty) {
      widgets.add(_sectionTitle('Detail Produksi (${productions.length} data)', fontBold));
      widgets.add(_dataTable(
        headers: ['Tanggal', 'Produk', 'Kategori', 'Jumlah', 'Jenis', 'Catatan'],
        rows: productions.map((e) {
          final m    = e as Map<String, dynamic>;
          final prod = m['product'] as Map<String, dynamic>?;
          return [
            _fmtDate(m['production_date']),
            prod?['name'] as String? ?? '-',
            m['category'] as String? ?? '-',
            _fmtNum(m['quantity']) + ' ${prod?['unit'] ?? 'pcs'}',
            m['type'] as String? ?? '-',
            m['notes'] as String? ?? '-',
          ];
        }).toList(),
        fontBold: fontBold,
        font: font,
        columnWidths: [1.5, 2.5, 1.5, 1.5, 1, 2],
      ));
    } else {
      widgets.add(_emptyMessage(font));
    }

    return widgets;
  }

  // ── Finance Content ───────────────────────────────────────────────────────
  static List<pw.Widget> _buildFinanceContent(
    Map<String, dynamic> salesData,
    Map<String, dynamic> expenseData,
    pw.Font fontBold,
    pw.Font font,
  ) {
    final salesStats   = salesData['statistics']  as Map<String, dynamic>? ?? {};
    final expenseStats = expenseData['statistics'] as Map<String, dynamic>? ?? {};
    final sales   = salesData['sales']     as List<dynamic>? ?? [];
    final expenses = expenseData['expenses'] as List<dynamic>? ?? [];
    final totalSales   = _toDouble(salesStats['total_revenue']);
    final totalExpense = _toDouble(expenseStats['total_expense']);

    final widgets = <pw.Widget>[];

    widgets.add(_sectionTitle('Ringkasan Keuangan', fontBold));
    widgets.add(_summaryTable([
      ['Total Pendapatan', _fmtCur(totalSales)],
      ['Total Pengeluaran', _fmtCur(totalExpense)],
      ['Laba Bersih', _fmtCur(totalSales - totalExpense)],
      ['Jumlah Transaksi', '${salesStats['total_transactions'] ?? 0}'],
    ], fontBold, font));
    widgets.add(pw.SizedBox(height: 14));

    // Detail penjualan
    if (sales.isNotEmpty) {
      widgets.add(_sectionTitle('Detail Penjualan (${sales.length} data)', fontBold));
      widgets.add(_dataTable(
        headers: ['Tanggal', 'Invoice', 'Pelanggan', 'Jenis', 'Total'],
        rows: sales.map((e) {
          final m = e as Map<String, dynamic>;
          final cust = m['customer'] as Map<String, dynamic>?;
          return [
            _fmtDate(m['sale_date']),
            m['invoice_number'] as String? ?? '-',
            cust?['name'] as String? ?? 'Umum',
            m['type'] as String? ?? '-',
            _fmtCur(m['total_amount']),
          ];
        }).toList(),
        fontBold: fontBold,
        font: font,
        columnWidths: [1.5, 2, 2, 1, 1.8],
      ));
      widgets.add(pw.SizedBox(height: 14));
    }

    // Detail pengeluaran
    if (expenses.isNotEmpty) {
      widgets.add(_sectionTitle('Detail Pengeluaran (${expenses.length} data)', fontBold));
      widgets.add(_dataTable(
        headers: ['Tanggal', 'Kategori', 'Jumlah', 'Keterangan'],
        rows: expenses.map((e) {
          final m = e as Map<String, dynamic>;
          return [
            _fmtDate(m['expense_date']),
            m['category'] as String? ?? '-',
            _fmtCur(m['amount']),
            m['description'] as String? ?? '-',
          ];
        }).toList(),
        fontBold: fontBold,
        font: font,
        columnWidths: [1.5, 2, 1.8, 3],
      ));
    }

    if (sales.isEmpty && expenses.isEmpty) {
      widgets.add(_emptyMessage(font));
    }

    return widgets;
  }

  // ── Helper Widgets ───────────────────────────────────────────────────────
  static pw.Widget _sectionTitle(String title, pw.Font fontBold) => pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 6),
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: pw.BoxDecoration(
          color: PdfColors.blue800,
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(title,
            style: pw.TextStyle(
                font: fontBold, fontSize: 10, color: PdfColors.white)),
      );

  static pw.Widget _summaryTable(
    List<List<String>> rows,
    pw.Font fontBold,
    pw.Font font,
  ) =>
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
        children: rows.map((row) {
          return pw.TableRow(children: [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: pw.Text(row[0],
                  style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey700)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: pw.Text(row[1],
                  style: pw.TextStyle(font: fontBold, fontSize: 9)),
            ),
          ]);
        }).toList(),
        columnWidths: {
          0: const pw.FlexColumnWidth(2),
          1: const pw.FlexColumnWidth(2),
        },
      );

  static pw.Widget _dataTable({
    required List<String> headers,
    required List<List<String>> rows,
    required pw.Font fontBold,
    required pw.Font font,
    required List<double> columnWidths,
  }) {
    if (rows.isEmpty) return _emptyMessage(font);

    final widthMap = <int, pw.TableColumnWidth>{};
    for (var i = 0; i < columnWidths.length; i++) {
      widthMap[i] = pw.FlexColumnWidth(columnWidths[i]);
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
      columnWidths: widthMap,
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue50),
          children: headers
              .map((h) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8, vertical: 5),
                    child: pw.Text(h,
                        style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 8,
                            color: PdfColors.blue900)),
                  ))
              .toList(),
        ),
        // Data rows
        ...rows.asMap().entries.map((entry) {
          final bg = entry.key.isOdd ? PdfColors.grey50 : PdfColors.white;
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: bg),
            children: entry.value
                .map((cell) => pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      child: pw.Text(cell,
                          style: pw.TextStyle(font: font, fontSize: 8)),
                    ))
                .toList(),
          );
        }),
      ],
    );
  }

  static pw.Widget _emptyMessage(pw.Font font) => pw.Center(
        child: pw.Padding(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Text('Data laporan tidak ditemukan untuk periode ini.',
              style: pw.TextStyle(
                  font: font, fontSize: 9, color: PdfColors.grey500)),
        ),
      );

  // ── Formatters ────────────────────────────────────────────────────────────
  static String _fmtNum(dynamic v) {
    final n = _toDouble(v);
    return NumberFormat('#,##0', 'id').format(n.toInt());
  }

  static String _fmtCur(dynamic v) {
    final n = _toDouble(v);
    return 'Rp ${NumberFormat('#,##0', 'id').format(n.toInt())}';
  }

  static String _fmtDate(dynamic v) {
    if (v == null) return '-';
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(v.toString()));
    } catch (_) {
      return v.toString();
    }
  }

  static double _toDouble(dynamic v) =>
      double.tryParse(v?.toString() ?? '0') ?? 0;

  /// Buat nama file PDF
  static String buildFileName({
    required String reportType,
    required String startDate,
    required String endDate,
  }) {
    final typeMap = {
      'integrated': 'laporan-terintegrasi',
      'production': 'laporan-produksi',
      'finance':    'laporan-keuangan',
    };
    final name = typeMap[reportType] ?? 'laporan';
    // Format: laporan-produksi-2026-06-01_2026-06-30.pdf
    return '$name-${startDate}_$endDate.pdf';
  }
}
