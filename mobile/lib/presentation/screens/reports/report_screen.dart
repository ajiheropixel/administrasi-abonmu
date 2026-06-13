import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/report_pdf_generator.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/report_repository.dart';
import '../../widgets/app_loading.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Report Screen — Main
// ─────────────────────────────────────────────────────────────────────────────
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _repo        = ReportRepository();
  final _productRepo = ProductRepository();

  // ── Filter state ──────────────────────────────────────────────────────────
  String _startDate = DateFormatter.startOfMonth();
  String _endDate   = DateFormatter.endOfMonth();
  String? _category;  // kategori produksi: Abon Sapi, dll
  String? _type;      // jenis produksi: rutin / pesanan
  int?    _productId;
  // Bulan & tahun quick-filter
  int  _selectedMonth = DateTime.now().month;
  int  _selectedYear  = DateTime.now().year;

  // ── Data ──────────────────────────────────────────────────────────────────
  List<ProductModel>    _products       = [];
  Map<String, dynamic>? _integratedData;

  bool    _loading     = false;
  bool    _downloading = false;
  String? _error;

  static const _months = [
    'Januari','Februari','Maret','April','Mei','Juni',
    'Juli','Agustus','September','Oktober','November','Desember',
  ];
  static const _categories = [
    'Abon Sapi','Abon Ayam','Abon Ikan','Abon Lainnya',
  ];
  static const _types = [
    ('rutin',   'Rutin'),
    ('pesanan', 'Pesanan'),
  ];

  List<int> get _years {
    final cur = DateTime.now().year;
    return List.generate(5, (i) => cur - i);
  }

  // ── Tab name → report type string ────────────────────────────────────────
  bool get _hasData => _integratedData?['summary'] != null;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _load();
  }

  // ── Load products for filter dropdown ────────────────────────────────────
  Future<void> _loadProducts() async {
    try {
      final r = await _productRepo.getProducts(perPage: 100);
      if (mounted) setState(() => _products = r['data'] as List<ProductModel>);
    } catch (_) {}
  }

  // ── Load report data ─────────────────────────────────────────────────────
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _integratedData = await _repo.getIntegratedReport(
        startDate: _startDate, endDate: _endDate,
        category: _category, type: _type, productId: _productId,
      );
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  // ── Apply month/year quick filter ────────────────────────────────────────
  void _applyMonthYear() {
    final first = DateTime(_selectedYear, _selectedMonth, 1);
    final last  = DateTime(_selectedYear, _selectedMonth + 1, 0);
    setState(() {
      _startDate = DateFormatter.toApi(first);
      _endDate   = DateFormatter.toApi(last);
    });
    _load();
  }

  // ── Reset all filters ────────────────────────────────────────────────────
  void _resetFilters() {
    final now = DateTime.now();
    setState(() {
      _selectedMonth = now.month;
      _selectedYear  = now.year;
      _startDate = DateFormatter.startOfMonth();
      _endDate   = DateFormatter.endOfMonth();
      _category  = null;
      _type      = null;
      _productId = null;
    });
    _load();
  }

  // ── Generate & show PDF ──────────────────────────────────────────────────
  Future<void> _downloadPdf() async {
    if (!_hasData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data laporan kosong, tidak dapat membuat PDF.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _downloading = true);
    try {
      const reportType = 'integrated';
      final mainData = _integratedData ?? {};

      final pdfBytes = await ReportPdfGenerator.generate(
        reportType:  reportType,
        startDate:   _startDate,
        endDate:     _endDate,
        data:        mainData,
        salesData:   null,
        expenseData: null,
      );

      final fileName = ReportPdfGenerator.buildFileName(
        reportType: reportType,
        startDate:  _startDate,
        endDate:    _endDate,
      );

      if (!mounted) return;

      if (kIsWeb) {
        // Web: tampilkan preview PDF di dialog baru menggunakan Printing.layoutPdf
        await Printing.layoutPdf(
          onLayout: (_) async => pdfBytes,
          name: fileName,
        );
      } else {
        // Mobile: share/save dialog native
        await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF "$fileName" berhasil dibuat'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    if (mounted) setState(() => _downloading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Laporan',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                    ),
                    // Hapus ikon unduh di header — gunakan bar unduh bawah saja
                    const SizedBox(width: 28),
                  ],
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Laporan Terintegrasi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      )),
                ),
              ],
            ),
          ),
          // ── Filter Panel ────────────────────────────────────────
          _FilterPanel(
            startDate:     _startDate,
            endDate:       _endDate,
            selectedMonth: _selectedMonth,
            selectedYear:  _selectedYear,
            category:      _category,
            type:          _type,
            productId:     _productId,
            products:      _products,
            categories:    _categories,
            types:         _types,
            years:         _years,
            months:        _months,
            onMonthChanged: (v) { setState(() => _selectedMonth = v); _applyMonthYear(); },
            onYearChanged:  (v) { setState(() => _selectedYear  = v); _applyMonthYear(); },
            onDateChanged:  (start, end) {
              setState(() { _startDate = start; _endDate = end; });
              _load();
            },
            onCategoryChanged: (v) { setState(() => _category  = v); _load(); },
            onTypeChanged:     (v) { setState(() => _type      = v); _load(); },
            onProductChanged:  (v) { setState(() => _productId = v); _load(); },
            onReset: _resetFilters,
          ),
          const Divider(height: 1),

          // ── Content ─────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const AppLoading()
                : _error != null
                    ? _ErrorView(error: _error!, onRetry: _load)
                    : _IntegratedTab(data: _integratedData),
          ),

          // ── Download bar ─────────────────────────────────────────
          _DownloadBar(
            hasData:     _hasData,
            downloading: _downloading,
            onDownload:  _downloadPdf,
            startDate:   _startDate,
            endDate:     _endDate,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Panel
// ─────────────────────────────────────────────────────────────────────────────
class _FilterPanel extends StatefulWidget {
  final String startDate, endDate;
  final int selectedMonth, selectedYear;
  final String? category, type;
  final int? productId;
  final List<ProductModel> products;
  final List<String> categories, months;
  final List<(String, String)> types;
  final List<int> years;
  final ValueChanged<int> onMonthChanged, onYearChanged;
  final void Function(String start, String end) onDateChanged;
  final ValueChanged<String?> onCategoryChanged, onTypeChanged;
  final ValueChanged<int?> onProductChanged;
  final VoidCallback onReset;

  const _FilterPanel({
    required this.startDate, required this.endDate,
    required this.selectedMonth, required this.selectedYear,
    this.category, this.type, this.productId,
    required this.products, required this.categories,
    required this.types, required this.years, required this.months,
    required this.onMonthChanged, required this.onYearChanged,
    required this.onDateChanged, required this.onCategoryChanged,
    required this.onTypeChanged, required this.onProductChanged,
    required this.onReset,
  });

  @override
  State<_FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<_FilterPanel> {
  bool _expanded = false;

  bool get _hasFilter => widget.category != null ||
      widget.type != null || widget.productId != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          // ── Header row: bulan/tahun + expand ───────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              children: [
                // Bulan dropdown
                Expanded(
                  child: _compactDropdown<int>(
                    value: widget.selectedMonth,
                    icon: Icons.calendar_month_outlined,
                    items: List.generate(12, (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text(widget.months[i], overflow: TextOverflow.ellipsis),
                    )),
                    onChanged: (v) { if (v != null) widget.onMonthChanged(v); },
                  ),
                ),
                const SizedBox(width: 8),
                // Tahun dropdown
                SizedBox(
                  width: 90,
                  child: _compactDropdown<int>(
                    value: widget.selectedYear,
                    icon: Icons.date_range_outlined,
                    items: widget.years.map((y) => DropdownMenuItem(
                      value: y,
                      child: Text('$y'),
                    )).toList(),
                    onChanged: (v) { if (v != null) widget.onYearChanged(v); },
                  ),
                ),
                const SizedBox(width: 8),
                // Custom date range button
                GestureDetector(
                  onTap: () => _pickDateRange(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.date_range,
                        size: 18, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 8),
                // Expand/collapse tombol filter lanjutan
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: (_hasFilter || _expanded)
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: (_hasFilter || _expanded)
                              ? AppColors.primary
                              : AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tune,
                            size: 16,
                            color: (_hasFilter || _expanded)
                                ? AppColors.primary
                                : AppColors.textSecondary),
                        if (_hasFilter)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                                color: AppColors.primary, shape: BoxShape.circle),
                            child: Text(
                              [widget.category, widget.type, widget.productId]
                                  .where((e) => e != null).length.toString(),
                              style: const TextStyle(
                                  fontSize: 8, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Periode badge ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 12, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(
                  'Periode: ${_fmtDisplay(widget.startDate)} – ${_fmtDisplay(widget.endDate)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                ),
              ],
            ),
          ),

          // ── Expanded: filter lanjutan ──────────────────────────
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filter Lanjutan',
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  // Kategori
                  _filterRow(
                    label: 'Kategori',
                    child: _compactDropdown<String?>(
                      value: widget.category,
                      icon: Icons.category_outlined,
                      hint: 'Semua Kategori',
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Semua Kategori')),
                        ...widget.categories.map((c) =>
                            DropdownMenuItem(value: c, child: Text(c))),
                      ],
                      onChanged: widget.onCategoryChanged,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Jenis
                  _filterRow(
                    label: 'Jenis',
                    child: _compactDropdown<String?>(
                      value: widget.type,
                      icon: Icons.swap_horiz,
                      hint: 'Semua Jenis',
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Semua Jenis')),
                        ...widget.types.map((t) =>
                            DropdownMenuItem(value: t.$1, child: Text(t.$2))),
                      ],
                      onChanged: widget.onTypeChanged,
                    ),
                  ),
                  if (widget.products.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _filterRow(
                      label: 'Produk',
                      child: _compactDropdown<int?>(
                        value: widget.productId,
                        icon: Icons.inventory_2_outlined,
                        hint: 'Semua Produk',
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Semua Produk')),
                          ...widget.products.map((p) =>
                              DropdownMenuItem(value: p.id, child: Text(p.name))),
                        ],
                        onChanged: widget.onProductChanged,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  // Reset button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        widget.onReset();
                        setState(() => _expanded = false);
                      },
                      icon: const Icon(Icons.filter_alt_off, size: 16),
                      label: const Text('Reset Semua Filter'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickDateRange(BuildContext context) async {
    DateTime? sDate, eDate;
    try {
      sDate = DateTime.parse(widget.startDate);
      eDate = DateTime.parse(widget.endDate);
    } catch (_) {}

    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 1, 12, 31),
      initialDateRange: (sDate != null && eDate != null)
          ? DateTimeRange(start: sDate, end: eDate)
          : null,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (range != null) {
      widget.onDateChanged(
        DateFormatter.toApi(range.start),
        DateFormatter.toApi(range.end),
      );
    }
  }

  Widget _filterRow({required String label, required Widget child}) => Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ),
          Expanded(child: child),
        ],
      );

  Widget _compactDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    IconData? icon,
    String? hint,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isDense: true,
            isExpanded: true,
            hint: hint != null
                ? Text(hint,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textHint))
                : null,
            icon: const Icon(Icons.keyboard_arrow_down,
                size: 16, color: AppColors.textSecondary),
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500),
            dropdownColor: AppColors.surface,
            items: items,
            onChanged: onChanged,
          ),
        ),
      );

  String _fmtDisplay(String? date) {
    if (date == null) return '-';
    try {
      return DateFormat('dd MMM yyyy', 'id').format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Download Bar (bottom sticky)
// ─────────────────────────────────────────────────────────────────────────────
class _DownloadBar extends StatelessWidget {
  final bool hasData, downloading;
  final VoidCallback onDownload;
  final String startDate, endDate;

  const _DownloadBar({
    required this.hasData,
    required this.downloading,
    required this.onDownload,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: (!hasData || downloading) ? null : onDownload,
          icon: downloading
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.picture_as_pdf, size: 18),
          label: Text(downloading
              ? 'Membuat PDF...'
              : hasData
                  ? 'Unduh Laporan PDF'
                  : 'Data Kosong — PDF Tidak Tersedia'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                (!hasData || downloading) ? AppColors.border : AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: hasData ? 2 : 0,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error View
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            const Text('Gagal memuat laporan',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(error,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Coba Lagi'),
            ),
          ]),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Integrated Tab
// ─────────────────────────────────────────────────────────────────────────────
class _IntegratedTab extends StatelessWidget {
  final Map<String, dynamic>? data;
  const _IntegratedTab({this.data});

  @override
  Widget build(BuildContext context) {
    if (data == null) return const AppLoading();
    final summary = data!['summary'] as Map<String, dynamic>? ?? {};
    final period  = data!['period']  as Map<String, dynamic>? ?? {};
    final netProfit = _toDouble(summary['net_profit']);
    final salesByProduct = data!['sales_by_product'] as List<dynamic>? ?? [];
    final productionByCategory = data!['production_by_category'];

    final bool isEmpty = _toDouble(summary['total_production']) == 0 &&
        _toDouble(summary['total_sales']) == 0;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {},
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: isEmpty
            ? _emptyState()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _periodBadge(period['start_date'], period['end_date']),
                  const SizedBox(height: 12),
                  _SummaryGrid(items: [
                    _SummaryItem('Total Produksi',
                        '${CurrencyFormatter.formatNumber(_toDouble(summary['total_production']).toInt())} pcs',
                        AppColors.info),
                    _SummaryItem('Total Penjualan',
                        CurrencyFormatter.format(_toDouble(summary['total_sales'])),
                        AppColors.success),
                    _SummaryItem('Total Pengeluaran',
                        CurrencyFormatter.format(_toDouble(summary['total_expenses'])),
                        AppColors.error),
                    _SummaryItem('Laba Bersih',
                        CurrencyFormatter.format(netProfit),
                        netProfit >= 0 ? AppColors.success : AppColors.error),
                  ]),
                  const SizedBox(height: 16),
                  if (salesByProduct.isNotEmpty) ...[
                    _SectionCard(
                      title: 'Penjualan per Produk',
                      icon: Icons.shopping_cart_outlined,
                      child: _SalesByProductTable(items: salesByProduct),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (productionByCategory != null)
                    _SectionCard(
                      title: 'Produksi per Kategori',
                      icon: Icons.factory_outlined,
                      child: _ProductionByCategoryTable(items: productionByCategory),
                    ),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Production Tab
// ─────────────────────────────────────────────────────────────────────────────
class _ProductionTab extends StatelessWidget {
  final Map<String, dynamic>? data;
  const _ProductionTab({this.data});

  @override
  Widget build(BuildContext context) {
    if (data == null) return const AppLoading();
    final stats      = data!['statistics'] as Map<String, dynamic>? ?? {};
    final period     = data!['period']     as Map<String, dynamic>? ?? {};
    final productions = data!['productions'] as List<dynamic>? ?? [];

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {},
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _periodBadge(period['start_date'], period['end_date']),
            const SizedBox(height: 12),
            _SummaryGrid(items: [
              _SummaryItem('Total',
                  '${CurrencyFormatter.formatNumber(_toDouble(stats['total_production']).toInt())} pcs',
                  AppColors.primary),
              _SummaryItem('Rutin',
                  '${CurrencyFormatter.formatNumber(_toDouble(stats['total_rutin']).toInt())} pcs',
                  AppColors.info),
              _SummaryItem('Pesanan',
                  '${CurrencyFormatter.formatNumber(_toDouble(stats['total_pesanan']).toInt())} pcs',
                  AppColors.badgeOrangeText),
              _SummaryItem('Transaksi',
                  '${stats['total_transactions'] ?? 0}',
                  AppColors.textSecondary),
            ]),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Detail Produksi (${productions.length})',
              icon: Icons.list_alt_outlined,
              child: productions.isEmpty
                  ? _emptyState()
                  : _ProductionDetailTable(items: productions),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Finance Tab
// ─────────────────────────────────────────────────────────────────────────────
class _FinanceTab extends StatelessWidget {
  final Map<String, dynamic>? salesData;
  final Map<String, dynamic>? expenseData;
  const _FinanceTab({this.salesData, this.expenseData});

  @override
  Widget build(BuildContext context) {
    final salesStats   = salesData?['statistics']   as Map<String, dynamic>? ?? {};
    final expenseStats = expenseData?['statistics']  as Map<String, dynamic>? ?? {};
    final sales   = salesData?['sales']   as List<dynamic>? ?? [];
    final expenses = expenseData?['expenses'] as List<dynamic>? ?? [];
    final totalSales   = _toDouble(salesStats['total_revenue']);
    final totalExpense = _toDouble(expenseStats['total_expense']);
    final netProfit    = totalSales - totalExpense;
    final byCategory   = expenseStats['by_category'] as Map<String, dynamic>?;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {},
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryGrid(items: [
              _SummaryItem('Pendapatan',
                  CurrencyFormatter.format(totalSales), AppColors.success),
              _SummaryItem('Pengeluaran',
                  CurrencyFormatter.format(totalExpense), AppColors.error),
              _SummaryItem('Laba Bersih',
                  CurrencyFormatter.format(netProfit),
                  netProfit >= 0 ? AppColors.success : AppColors.error),
              _SummaryItem('Transaksi',
                  '${salesStats['total_transactions'] ?? 0}',
                  AppColors.textSecondary),
            ]),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Detail Penjualan (${sales.length})',
              icon: Icons.receipt_long_outlined,
              child: sales.isEmpty
                  ? _emptyState()
                  : _SalesDetailTable(items: sales),
            ),
            const SizedBox(height: 12),
            if (byCategory != null && byCategory.isNotEmpty)
              _SectionCard(
                title: 'Pengeluaran per Kategori',
                icon: Icons.pie_chart_outline,
                child: _ExpenseCategoryTable(items: byCategory),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Widgets
// ─────────────────────────────────────────────────────────────────────────────

Widget _periodBadge(String? start, String? end) {
  if (start == null || end == null) return const SizedBox.shrink();
  try {
    final fmt = DateFormat('dd MMM yyyy', 'id');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.infoBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, size: 12, color: AppColors.infoText),
          const SizedBox(width: 6),
          Text(
            'Periode: ${fmt.format(DateTime.parse(start))} – ${fmt.format(DateTime.parse(end))}',
            style: const TextStyle(
                fontSize: 11, color: AppColors.infoText,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  } catch (_) {
    return const SizedBox.shrink();
  }
}

Widget _emptyState() => Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined,
                size: 48, color: AppColors.textHint.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            const Text('Data laporan tidak ditemukan.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const Text('Coba ubah filter periode atau kategori.',
                style: TextStyle(fontSize: 11, color: AppColors.textHint)),
          ],
        ),
      ),
    );

class _SummaryItem {
  final String label, value;
  final Color color;
  const _SummaryItem(this.label, this.value, this.color);
}

class _SummaryGrid extends StatelessWidget {
  final List<_SummaryItem> items;
  const _SummaryGrid({required this.items});

  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.4,
        children: items.map((item) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.label,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textSecondary)),
                  const SizedBox(height: 3),
                  Text(item.value,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: item.color),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            )).toList(),
      );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  Icon(icon, size: 15, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ],
              ),
            ),
            const Divider(height: 1),
            child,
          ],
        ),
      );
}

// ── Table Widgets ─────────────────────────────────────────────────────────────

class _SalesByProductTable extends StatelessWidget {
  final List<dynamic> items;
  const _SalesByProductTable({required this.items});

  @override
  Widget build(BuildContext context) => Column(
        children: items.map((item) {
          final m = item as Map<String, dynamic>;
          return _row(
            m['name'] as String? ?? '-',
            '${CurrencyFormatter.formatNumber(_toDouble(m['total_quantity']).toInt())} pcs',
            CurrencyFormatter.format(_toDouble(m['total_amount'])),
            valueColor: AppColors.success,
          );
        }).toList(),
      );
}

class _ProductionByCategoryTable extends StatelessWidget {
  final dynamic items;
  const _ProductionByCategoryTable({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items == null) return _emptyState();
    final map = items as Map<String, dynamic>;
    if (map.isEmpty) return _emptyState();
    return Column(
      children: map.entries.map((e) {
        final v = e.value as Map<String, dynamic>;
        return _row(
          e.key,
          '${CurrencyFormatter.formatNumber(_toDouble(v['total']).toInt())} pcs',
          'Rutin: ${CurrencyFormatter.formatNumber(_toDouble(v['rutin']).toInt())} | '
          'Pesanan: ${CurrencyFormatter.formatNumber(_toDouble(v['pesanan']).toInt())}',
        );
      }).toList(),
    );
  }
}

class _ProductionDetailTable extends StatelessWidget {
  final List<dynamic> items;
  const _ProductionDetailTable({required this.items});

  @override
  Widget build(BuildContext context) => Column(
        children: items.take(30).map((item) {
          final m    = item as Map<String, dynamic>;
          final prod = m['product'] as Map<String, dynamic>?;
          return _row(
            prod?['name'] as String? ?? 'Produk #${m['product_id']}',
            _fmtDate(m['production_date']),
            '${CurrencyFormatter.formatNumber(_toDouble(m['quantity']).toInt())} '
            '${prod?['unit'] ?? 'pcs'} · ${m['type'] ?? '-'}',
          );
        }).toList(),
      );
}

class _SalesDetailTable extends StatelessWidget {
  final List<dynamic> items;
  const _SalesDetailTable({required this.items});

  @override
  Widget build(BuildContext context) => Column(
        children: items.take(30).map((item) {
          final m    = item as Map<String, dynamic>;
          final cust = m['customer'] as Map<String, dynamic>?;
          return _row(
            m['invoice_number'] as String? ?? '-',
            '${cust?['name'] ?? 'Umum'} · ${_fmtDate(m['sale_date'])}',
            CurrencyFormatter.format(_toDouble(m['total_amount'])),
            valueColor: AppColors.success,
          );
        }).toList(),
      );
}

class _ExpenseCategoryTable extends StatelessWidget {
  final Map<String, dynamic> items;
  const _ExpenseCategoryTable({required this.items});

  @override
  Widget build(BuildContext context) => Column(
        children: items.entries.map((e) {
          final v = e.value as Map<String, dynamic>;
          return _row(
            e.key,
            '${v['count'] ?? 0} transaksi',
            CurrencyFormatter.format(_toDouble(v['total_amount'])),
            valueColor: AppColors.error,
          );
        }).toList(),
      );
}

Widget _row(String label, String sub, String value, {Color? valueColor}) =>
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 1),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? AppColors.textPrimary)),
        ],
      ),
    );

// ── Helpers ───────────────────────────────────────────────────────────────────
double _toDouble(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0;

String _fmtDate(dynamic v) {
  if (v == null) return '-';
  try {
    return DateFormat('dd MMM yyyy', 'id').format(DateTime.parse(v.toString()));
  } catch (_) {
    return v.toString();
  }
}
