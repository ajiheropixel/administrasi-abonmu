import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/production_provider.dart';
import '../../../data/models/production_model.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_confirm_dialog.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/product_avatar.dart';
import 'production_form_screen.dart';
import 'production_detail_screen.dart';

class ProductionListScreen extends StatefulWidget {
  const ProductionListScreen({super.key});

  @override
  State<ProductionListScreen> createState() => _ProductionListScreenState();
}

class _ProductionListScreenState extends State<ProductionListScreen> {
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductionProvider>().loadProductions(refresh: true);
    });
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        context.read<ProductionProvider>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    final prov = context.watch<ProductionProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Produksi'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Tambah Produksi',
              onPressed: () => _openForm(context),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Search + Filter bar ──────────────────────────────
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) =>
                      context.read<ProductionProvider>().setSearch(v),
                  decoration: InputDecoration(
                    hintText: 'Cari produk, kategori...',
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textHint, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                size: 18, color: AppColors.textHint),
                            onPressed: () {
                              _searchCtrl.clear();
                              context
                                  .read<ProductionProvider>()
                                  .setSearch('');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 8),
                // Filter chips row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Today toggle
                      _FilterChip(
                        label: 'Hari Ini',
                        icon: Icons.today,
                        active: prov.todayOnly,
                        activeColor: AppColors.primary,
                        onTap: () => context
                            .read<ProductionProvider>()
                            .setTodayOnly(!prov.todayOnly),
                      ),
                      const SizedBox(width: 8),
                      // Date range picker
                      _DateRangeChip(
                        startDate: prov.startDate,
                        endDate: prov.endDate,
                        onChanged: (start, end) => context
                            .read<ProductionProvider>()
                            .setDateRange(start, end),
                      ),
                      const SizedBox(width: 8),
                      // Type filter
                      _FilterChip(
                        label: 'Rutin',
                        active: prov.selectedType == 'rutin',
                        activeColor: AppColors.info,
                        onTap: () {
                          final next = prov.selectedType == 'rutin'
                              ? null
                              : 'rutin';
                          context.read<ProductionProvider>().setFilters(
                                type: next,
                                category: prov.selectedCategory,
                                start: prov.startDate,
                                end: prov.endDate,
                              );
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Pesanan',
                        active: prov.selectedType == 'pesanan',
                        activeColor: AppColors.badgeOrangeText,
                        onTap: () {
                          final next = prov.selectedType == 'pesanan'
                              ? null
                              : 'pesanan';
                          context.read<ProductionProvider>().setFilters(
                                type: next,
                                category: prov.selectedCategory,
                                start: prov.startDate,
                                end: prov.endDate,
                              );
                        },
                      ),
                      // Reset
                      if (prov.todayOnly ||
                          prov.startDate != null ||
                          prov.selectedType != null ||
                          (prov.searchQuery?.isNotEmpty ?? false)) ...[
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Reset',
                          icon: Icons.close,
                          active: false,
                          activeColor: AppColors.error,
                          onTap: () {
                            _searchCtrl.clear();
                            context
                                .read<ProductionProvider>()
                                .resetFilters();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Active filter summary
          if (prov.todayOnly || prov.startDate != null)
            Container(
              color: AppColors.infoBg,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 14, color: AppColors.infoText),
                  const SizedBox(width: 6),
                  Text(
                    prov.todayOnly
                        ? 'Menampilkan produksi hari ini'
                        : 'Periode: ${DateFormatter.toDisplay(prov.startDate)} – ${DateFormatter.toDisplay(prov.endDate)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.infoText),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),

          // ── List ────────────────────────────────────────────
          Expanded(
            child: prov.loading
                ? const AppLoading()
                : prov.productions.isEmpty
                    ? AppEmptyState(
                        message: prov.todayOnly
                            ? 'Tidak ada produksi hari ini'
                            : 'Belum ada data produksi',
                        subtitle: prov.todayOnly
                            ? 'Coba hapus filter atau tambah data baru'
                            : null,
                        icon: Icons.factory_outlined,
                        onAction:
                            isAdmin ? () => _openForm(context) : null,
                        actionLabel: 'Tambah Produksi',
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () =>
                            prov.loadProductions(refresh: true),
                        child: ListView.separated(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.all(12),
                          itemCount: prov.productions.length +
                              (prov.loadingMore ? 1 : 0),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (ctx, i) {
                            if (i == prov.productions.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(
                                      color: AppColors.primary),
                                ),
                              );
                            }
                            final prod = prov.productions[i];
                            return _ProductionCard(
                              production: prod,
                              isAdmin: isAdmin,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        ProductionDetailScreen(
                                            id: prod.id)),
                              ),
                              onEdit: () =>
                                  _openForm(context, production: prod),
                              onDelete: () =>
                                  _delete(context, prod),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _openForm(BuildContext context, {ProductionModel? production}) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              ProductionFormScreen(production: production)),
    ).then((_) =>
        context.read<ProductionProvider>().loadProductions(refresh: true));
  }

  Future<void> _delete(
      BuildContext context, ProductionModel prod) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Hapus Produksi',
      message:
          'Hapus data produksi ini? Stok produk akan dikurangi.',
    );
    if (!ok || !mounted) return;
    final success = await context
        .read<ProductionProvider>()
        .deleteProduction(prod.id);
    if (!mounted) return;
    if (success) {
      showSuccessSnackbar(context, 'Data produksi berhasil dihapus');
    } else {
      showErrorSnackbar(
          context,
          context.read<ProductionProvider>().error ??
              'Gagal menghapus');
    }
  }
}

// ── Production Card ──────────────────────────────────────────────────────────
class _ProductionCard extends StatelessWidget {
  final ProductionModel production;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductionCard({
    required this.production,
    required this.isAdmin,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  /// Warna background berdasarkan kategori
  Color _colorForCategory(String category) {
    final c = category.toLowerCase();
    if (c.contains('ayam')) return AppColors.badgeOrangeText;
    if (c.contains('sapi')) return const Color(0xFF92400E); // brown
    if (c.contains('ikan')) return AppColors.info;
    if (c.contains('udang')) return const Color(0xFFBE185D); // pink
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final productName = production.product?.name;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Gambar produk dari database
            ProductAvatar(product: production.product, size: 48),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName ?? 'Produk #${production.productId}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Tanggal — sudah diformat
                  Text(
                    DateFormatter.toDisplay(production.productionDate),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        '${CurrencyFormatter.formatNumber(production.quantity)} pcs',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 8),
                      // Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: production.isRutin
                              ? AppColors.infoBg
                              : AppColors.badgeOrange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          production.isRutin ? 'Rutin' : 'Pesanan',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: production.isRutin
                                ? AppColors.infoText
                                : AppColors.badgeOrangeText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Created by
                  if (production.createdBy != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 11, color: AppColors.textHint),
                        const SizedBox(width: 3),
                        Text(
                          'Dibuat: ${production.createdBy!.name}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textHint),
                        ),
                        if (production.updatedBy != null &&
                            production.updatedBy!.id !=
                                production.createdBy!.id) ...[
                          const SizedBox(width: 8),
                          Text(
                            '· Diubah: ${production.updatedBy!.name}',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textHint),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Actions
            if (isAdmin)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    color: AppColors.textHint, size: 20),
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_outlined, size: 16),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline,
                          size: 16, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Hapus',
                          style: TextStyle(color: AppColors.error)),
                    ]),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ── Filter Chip ──────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? activeColor : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? activeColor : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 13,
                  color: active ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Date Range Chip ──────────────────────────────────────────────────────────
class _DateRangeChip extends StatelessWidget {
  final String? startDate;
  final String? endDate;
  final void Function(String? start, String? end) onChanged;

  const _DateRangeChip({
    this.startDate,
    this.endDate,
    required this.onChanged,
  });

  String get _label {
    if (startDate == null && endDate == null) return 'Pilih Tanggal';
    final fmt = DateFormat('dd MMM');
    final s = startDate != null
        ? fmt.format(DateTime.parse(startDate!))
        : '?';
    final e = endDate != null
        ? fmt.format(DateTime.parse(endDate!))
        : '?';
    return '$s – $e';
  }

  bool get _hasRange => startDate != null || endDate != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange: startDate != null && endDate != null
              ? DateTimeRange(
                  start: DateTime.parse(startDate!),
                  end: DateTime.parse(endDate!),
                )
              : null,
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(
                  primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (range != null) {
          onChanged(
            DateFormatter.toApi(range.start),
            DateFormatter.toApi(range.end),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _hasRange ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hasRange ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.date_range,
                size: 13,
                color: _hasRange ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              _label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _hasRange ? Colors.white : AppColors.textSecondary,
              ),
            ),
            if (_hasRange) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => onChanged(null, null),
                child: const Icon(Icons.close,
                    size: 13, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
