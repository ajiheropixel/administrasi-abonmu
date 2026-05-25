import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../widgets/app_loading.dart';
import 'widgets/monthly_chart_widget.dart';
import 'widgets/top_products_widget.dart';
import 'widgets/low_stock_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<DashboardProvider>();
      p.loadStats();
      p.loadMonthlyComparison();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.headerBg,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: dash.loading
          ? const AppLoading()
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                await context.read<DashboardProvider>().loadStats();
                await context.read<DashboardProvider>().loadMonthlyComparison();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (dash.error != null)
                      _errorBanner(context, dash.error!),

                    // 4 stat cards (sama dengan PHP grid)
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _StatCard(
                          label: 'Produksi Bulan Ini',
                          value: CurrencyFormatter.formatNumber(
                              dash.summary?.totalProduction ?? 0),
                          sub: 'bungkus',
                          iconBg: AppColors.infoBg,
                          iconColor: AppColors.info,
                          icon: Icons.factory_outlined,
                        ),
                        _StatCard(
                          label: 'Penjualan Bulan Ini',
                          value: CurrencyFormatter.formatCompact(
                              dash.summary?.totalSales ?? 0),
                          sub: '${dash.summary?.totalTransactions ?? 0} transaksi',
                          iconBg: AppColors.successBg,
                          iconColor: AppColors.success,
                          icon: Icons.shopping_cart_outlined,
                        ),
                        _StatCard(
                          label: 'Pengeluaran Bulan Ini',
                          value: CurrencyFormatter.formatCompact(
                              dash.summary?.totalExpenses ?? 0),
                          sub: 'total biaya',
                          iconBg: AppColors.errorBg,
                          iconColor: AppColors.error,
                          icon: Icons.receipt_outlined,
                        ),
                        _StatCard(
                          label: 'Laba Bersih',
                          value: CurrencyFormatter.formatCompact(
                              dash.summary?.netProfit ?? 0),
                          sub: 'bulan ini',
                          iconBg: AppColors.badgePurple,
                          iconColor: AppColors.badgePurpleText,
                          icon: Icons.trending_up,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Statistik penjualan + top produk (2 kolom di wide, 1 kolom di narrow)
                    LayoutBuilder(builder: (ctx, constraints) {
                      if (constraints.maxWidth > 600) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _SalesStatsCard(summary: dash.summary)),
                            const SizedBox(width: 12),
                            Expanded(child: TopProductsWidget(products: dash.topProducts)),
                          ],
                        );
                      }
                      return Column(children: [
                        _SalesStatsCard(summary: dash.summary),
                        const SizedBox(height: 12),
                        TopProductsWidget(products: dash.topProducts),
                      ]);
                    }),
                    const SizedBox(height: 16),

                    // Produksi & Penjualan terbaru
                    LayoutBuilder(builder: (ctx, constraints) {
                      if (constraints.maxWidth > 600) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _RecentProductionsCard(
                                productions: dash.productionChart)),
                            const SizedBox(width: 12),
                            Expanded(child: _RecentSalesCard(
                                sales: dash.salesChart)),
                          ],
                        );
                      }
                      return Column(children: [
                        _RecentProductionsCard(productions: dash.productionChart),
                        const SizedBox(height: 12),
                        _RecentSalesCard(sales: dash.salesChart),
                      ]);
                    }),
                    const SizedBox(height: 16),

                    // Monthly chart
                    if (dash.monthlyComparison.isNotEmpty)
                      MonthlyChartWidget(data: dash.monthlyComparison),
                    const SizedBox(height: 16),

                    // Low stock
                    if (dash.lowStockProducts.isNotEmpty)
                      LowStockWidget(products: dash.lowStockProducts),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _errorBanner(BuildContext context, String error) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.errorBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(error,
              style: const TextStyle(color: AppColors.errorText, fontSize: 13))),
          TextButton(
            onPressed: () => context.read<DashboardProvider>().loadStats(),
            child: const Text('Coba Lagi'),
          ),
        ]),
      );
}

// Stat card — sama dengan PHP card style
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color iconBg;
  final Color iconColor;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.iconBg,
    required this.iconColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                    maxLines: 2),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textHint)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ],
      ),
    );
  }
}

class _SalesStatsCard extends StatelessWidget {
  final dynamic summary;
  const _SalesStatsCard({this.summary});

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      title: 'Statistik Penjualan',
      icon: Icons.pie_chart_outline,
      iconColor: AppColors.info,
      child: Column(
        children: [
          _row('Total Transaksi',
              '${summary?.totalTransactions ?? 0}'),
          _row('Rata-rata per Transaksi',
              CurrencyFormatter.format(summary?.averageSale ?? 0)),
          _row('Total Pendapatan',
              CurrencyFormatter.format(summary?.totalSales ?? 0),
              valueColor: AppColors.success),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.textPrimary)),
          ],
        ),
      );
}

class _RecentProductionsCard extends StatelessWidget {
  final List<dynamic> productions;
  const _RecentProductionsCard({required this.productions});

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      title: 'Produksi Terbaru',
      icon: Icons.factory_outlined,
      iconColor: AppColors.info,
      child: productions.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('Belum ada data produksi',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),
            )
          : Column(
              children: productions.take(5).map((p) {
                final m = p as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormatter.toDisplay(m['date'] as String? ?? ''),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      Text('${CurrencyFormatter.formatNumber(m['total'] ?? 0)} pcs',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _RecentSalesCard extends StatelessWidget {
  final List<dynamic> sales;
  const _RecentSalesCard({required this.sales});

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      title: 'Penjualan Terbaru',
      icon: Icons.shopping_cart_outlined,
      iconColor: AppColors.success,
      child: sales.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('Belum ada data penjualan',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),
            )
          : Column(
              children: sales.take(5).map((s) {
                final m = s as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormatter.toDisplay(m['date'] as String? ?? ''),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      Text(CurrencyFormatter.format(m['total'] ?? 0),
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success)),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

// Reusable white card dengan header (sama dengan PHP card style)
class _WhiteCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _WhiteCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Icon(icon, size: 16, color: iconColor),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}
