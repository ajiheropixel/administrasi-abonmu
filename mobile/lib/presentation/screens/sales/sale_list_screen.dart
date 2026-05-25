import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/sale_provider.dart';
import '../../../data/models/sale_model.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/app_confirm_dialog.dart';
import '../../widgets/app_snackbar.dart';
import 'sale_form_screen.dart';
import 'sale_detail_screen.dart';

class SaleListScreen extends StatefulWidget {
  const SaleListScreen({super.key});

  @override
  State<SaleListScreen> createState() => _SaleListScreenState();
}

class _SaleListScreenState extends State<SaleListScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SaleProvider>().loadSales(refresh: true);
    });
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        context.read<SaleProvider>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    final prov = context.watch<SaleProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Penjualan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilter(context, prov),
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _openForm(context),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: AppSearchBar(
              hint: 'Cari nomor invoice...',
              onChanged: (v) => context
                  .read<SaleProvider>()
                  .setFilters(search: v),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: prov.loading
                ? const AppLoading()
                : prov.sales.isEmpty
                    ? AppEmptyState(
                        message: 'Belum ada data penjualan',
                        icon: Icons.receipt_long_outlined,
                        onAction: isAdmin ? () => _openForm(context) : null,
                        actionLabel: 'Tambah Penjualan',
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => prov.loadSales(refresh: true),
                        child: ListView.separated(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.all(16),
                          itemCount:
                              prov.sales.length + (prov.loadingMore ? 1 : 0),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (ctx, i) {
                            if (i == prov.sales.length) {
                              return const Center(
                                  child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(
                                    color: AppColors.primary),
                              ));
                            }
                            final sale = prov.sales[i];
                            return _SaleCard(
                              sale: sale,
                              isAdmin: isAdmin,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        SaleDetailScreen(id: sale.id)),
                              ),
                              onDelete: () => _delete(context, sale),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _openForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SaleFormScreen()),
    ).then((_) => context.read<SaleProvider>().loadSales(refresh: true));
  }

  Future<void> _delete(BuildContext context, SaleModel sale) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Hapus Penjualan',
      message:
          'Hapus penjualan ${sale.invoiceNumber}? Stok produk akan dikembalikan.',
    );
    if (!ok || !mounted) return;
    final success =
        await context.read<SaleProvider>().deleteSale(sale.id);
    if (!mounted) return;
    if (success) {
      showSuccessSnackbar(context, 'Penjualan berhasil dihapus');
    } else {
      showErrorSnackbar(
          context, context.read<SaleProvider>().error ?? 'Gagal menghapus');
    }
  }

  void _showFilter(BuildContext context, SaleProvider prov) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FilterSheet(prov: prov),
    );
  }
}

class _SaleCard extends StatelessWidget {
  final SaleModel sale;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SaleCard({
    required this.sale,
    required this.isAdmin,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: sale.isEcer
                    ? AppColors.successLight
                    : AppColors.infoLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                sale.isEcer
                    ? Icons.storefront_outlined
                    : Icons.local_shipping_outlined,
                color: sale.isEcer ? AppColors.success : AppColors.info,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sale.invoiceNumber,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(
                    sale.customer?.name ?? 'Umum',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        CurrencyFormatter.format(sale.totalAmount),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success),
                      ),
                      const SizedBox(width: 8),
                      sale.isEcer
                          ? AppBadge.success('Ecer')
                          : AppBadge.info('Pesanan'),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormatter.toDisplay(sale.saleDate),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(Icons.delete_outline,
                        size: 18, color: AppColors.error),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final SaleProvider prov;
  const _FilterSheet({required this.prov});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _type;

  @override
  void initState() {
    super.initState();
    _type = widget.prov.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filter Penjualan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          const Text('Tipe',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            _chip(null, 'Semua'),
            _chip('ecer', 'Ecer'),
            _chip('pesanan', 'Pesanan'),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  widget.prov.setFilters();
                  Navigator.pop(context);
                },
                child: const Text('Reset'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  widget.prov.setFilters(type: _type);
                  Navigator.pop(context);
                },
                child: const Text('Terapkan'),
              ),
            ),
          ]),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _chip(String? value, String label) {
    final selected = _type == value;
    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w500)),
      ),
    );
  }
}

