import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/repositories/report_repository.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/app_date_range_picker.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  late final _tabCtrl = TabController(length: 3, vsync: this);
  final _repo = ReportRepository();

  String _startDate = DateFormatter.startOfMonth();
  String _endDate = DateFormatter.endOfMonth();

  Map<String, dynamic>? _integratedData;
  Map<String, dynamic>? _productionData;
  Map<String, dynamic>? _salesData;
  Map<String, dynamic>? _expenseData;

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) _load();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      switch (_tabCtrl.index) {
        case 0:
          _integratedData = await _repo.getIntegratedReport(startDate: _startDate, endDate: _endDate);
          break;
        case 1:
          _productionData = await _repo.getProductionReport(startDate: _startDate, endDate: _endDate);
          break;
        case 2:
          _salesData = await _repo.getSalesReport(startDate: _startDate, endDate: _endDate);
          _expenseData = await _repo.getExpenseReport(startDate: _startDate, endDate: _endDate);
          break;
      }
    } catch (e) {
      _error = e.toString();
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Laporan'),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Terintegrasi'),
            Tab(text: 'Produksi'),
            Tab(text: 'Keuangan'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Date range picker
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Text('Periode: ', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                AppDateRangePicker(
                  startDate: _startDate,
                  endDate: _endDate,
                  onChanged: (range) {
                    if (range != null) {
                      setState(() {
                        _startDate = DateFormatter.toApi(range.start);
                        _endDate = DateFormatter.toApi(range.end);
                      });
                    } else {
                      setState(() {
                        _startDate = DateFormatter.startOfMonth();
                        _endDate = DateFormatter.endOfMonth();
                      });
                    }
                    _load();
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const AppLoading()
                : _error != null
                    ? Center(child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 40),
                          const SizedBox(height: 8),
                          Text(_error!, style: const TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 12),
                          ElevatedButton(onPressed: _load, child: const Text('Coba Lagi')),
                        ],
                      ))
                    : TabBarView(
                        controller: _tabCtrl,
                        children: [
                          _IntegratedTab(data: _integratedData),
                          _ProductionTab(data: _productionData),
                          _FinanceTab(salesData: _salesData, expenseData: _expenseData),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _IntegratedTab extends StatelessWidget {
  final Map<String, dynamic>? data;
  const _IntegratedTab({this.data});

  @override
  Widget build(BuildContext context) {
    if (data == null) return const AppLoading();
    final summary = data!['summary'] as Map<String, dynamic>? ?? {};
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _summaryCard('Ringkasan', [
            _row('Total Produksi', '${CurrencyFormatter.formatNumber(summary['total_production'] ?? 0)} pcs'),
            _row('Total Penjualan', CurrencyFormatter.format(summary['total_sales'] ?? 0), color: AppColors.success),
            _row('Total Pengeluaran', CurrencyFormatter.format(summary['total_expenses'] ?? 0), color: AppColors.error),
            _row('Laba Bersih', CurrencyFormatter.format(summary['net_profit'] ?? 0),
                color: (double.tryParse(summary['net_profit'].toString()) ?? 0) >= 0 ? AppColors.success : AppColors.error,
                bold: true),
            _row('Total Transaksi', '${summary['total_transactions'] ?? 0}'),
          ]),
          const SizedBox(height: 16),
          if (data!['sales_by_product'] != null)
            _tableCard('Penjualan per Produk', data!['sales_by_product'] as List<dynamic>),
        ],
      ),
    );
  }
}

class _ProductionTab extends StatelessWidget {
  final Map<String, dynamic>? data;
  const _ProductionTab({this.data});

  @override
  Widget build(BuildContext context) {
    if (data == null) return const AppLoading();
    final stats = data!['statistics'] as Map<String, dynamic>? ?? {};
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _summaryCard('Statistik Produksi', [
            _row('Total Produksi', '${CurrencyFormatter.formatNumber(stats['total_production'] ?? 0)} pcs'),
            _row('Produksi Rutin', '${CurrencyFormatter.formatNumber(stats['total_rutin'] ?? 0)} pcs'),
            _row('Produksi Pesanan', '${CurrencyFormatter.formatNumber(stats['total_pesanan'] ?? 0)} pcs'),
            _row('Total Transaksi', '${stats['total_transactions'] ?? 0}'),
          ]),
        ],
      ),
    );
  }
}

class _FinanceTab extends StatelessWidget {
  final Map<String, dynamic>? salesData;
  final Map<String, dynamic>? expenseData;
  const _FinanceTab({this.salesData, this.expenseData});

  @override
  Widget build(BuildContext context) {
    final salesStats = salesData?['statistics'] as Map<String, dynamic>? ?? {};
    final expenseStats = expenseData?['statistics'] as Map<String, dynamic>? ?? {};
    final totalSales = double.tryParse(salesStats['total_revenue'].toString()) ?? 0;
    final totalExpense = double.tryParse(expenseStats['total_expense'].toString()) ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _summaryCard('Penjualan', [
            _row('Total Pendapatan', CurrencyFormatter.format(totalSales), color: AppColors.success, bold: true),
            _row('Jumlah Transaksi', '${salesStats['total_transactions'] ?? 0}'),
            _row('Rata-rata Transaksi', CurrencyFormatter.format(salesStats['average_transaction'] ?? 0)),
          ]),
          const SizedBox(height: 16),
          _summaryCard('Pengeluaran', [
            _row('Total Pengeluaran', CurrencyFormatter.format(totalExpense), color: AppColors.error, bold: true),
            _row('Jumlah Transaksi', '${expenseStats['total_transactions'] ?? 0}'),
          ]),
          const SizedBox(height: 16),
          _summaryCard('Laba Bersih', [
            _row('Pendapatan', CurrencyFormatter.format(totalSales), color: AppColors.success),
            _row('Pengeluaran', CurrencyFormatter.format(totalExpense), color: AppColors.error),
            const Divider(),
            _row('Laba Bersih', CurrencyFormatter.format(totalSales - totalExpense),
                color: (totalSales - totalExpense) >= 0 ? AppColors.success : AppColors.error,
                bold: true),
          ]),
        ],
      ),
    );
  }
}

Widget _summaryCard(String title, List<Widget> rows) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );

Widget _row(String label, String value, {Color? color, bool bold = false}) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                  color: color ?? AppColors.textPrimary)),
        ],
      ),
    );

Widget _tableCard(String title, List<dynamic> items) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...items.map((item) {
            final m = item as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(child: Text(m['name'] as String? ?? '-', style: const TextStyle(fontSize: 13))),
                  Text('${CurrencyFormatter.formatNumber(m['total_quantity'] ?? 0)} pcs',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(width: 12),
                  Text(CurrencyFormatter.format(m['total_amount'] ?? 0),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success)),
                ],
              ),
            );
          }),
        ],
      ),
    );

