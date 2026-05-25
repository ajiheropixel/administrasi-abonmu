import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../data/models/product_model.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/app_confirm_dialog.dart';
import '../../widgets/app_snackbar.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProductProvider>();
      p.loadProducts(refresh: true);
      p.loadCategories();
    });
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        context.read<ProductProvider>().loadMore();
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
    final prov = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Produk'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _openForm(context),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search & filter
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                AppSearchBar(
                  hint: 'Cari produk...',
                  onChanged: (v) =>
                      context.read<ProductProvider>().setSearch(v),
                ),
                if (prov.categories.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _categoryChip(context, null, prov.selectedCategory),
                        ...prov.categories.map((c) =>
                            _categoryChip(context, c, prov.selectedCategory)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          // List
          Expanded(
            child: prov.loading
                ? const AppLoading()
                : prov.products.isEmpty
                    ? AppEmptyState(
                        message: 'Belum ada produk',
                        subtitle: 'Tambah produk baru untuk memulai',
                        icon: Icons.inventory_2_outlined,
                        onAction: isAdmin ? () => _openForm(context) : null,
                        actionLabel: 'Tambah Produk',
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => prov.loadProducts(refresh: true),
                        child: ListView.separated(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.all(16),
                          itemCount: prov.products.length +
                              (prov.loadingMore ? 1 : 0),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (ctx, i) {
                            if (i == prov.products.length) {
                              return const Center(
                                  child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(
                                    color: AppColors.primary),
                              ));
                            }
                            return _ProductCard(
                              product: prov.products[i],
                              isAdmin: isAdmin,
                              onEdit: () =>
                                  _openForm(context, product: prov.products[i]),
                              onDelete: () =>
                                  _delete(context, prov.products[i]),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(
      BuildContext context, String? category, String? selected) {
    final isSelected = category == selected;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () =>
            context.read<ProductProvider>().setCategory(category),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            category ?? 'Semua',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  void _openForm(BuildContext context, {ProductModel? product}) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ProductFormScreen(product: product)),
    ).then((_) => context.read<ProductProvider>().loadProducts(refresh: true));
  }

  Future<void> _delete(BuildContext context, ProductModel product) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Hapus Produk',
      message: 'Hapus "${product.name}"? Tindakan ini tidak dapat dibatalkan.',
    );
    if (!ok || !mounted) return;
    final success =
        await context.read<ProductProvider>().deleteProduct(product.id);
    if (!mounted) return;
    if (success) {
      showSuccessSnackbar(context, 'Produk berhasil dihapus');
    } else {
      showErrorSnackbar(
          context, context.read<ProductProvider>().error ?? 'Gagal menghapus');
    }
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: AppColors.primaryLight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory_2_outlined,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(product.category,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      CurrencyFormatter.format(product.price),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    if (product.isCriticalStock)
                      AppBadge.error('Kritis: ${product.stock}')
                    else if (product.isLowStock)
                      AppBadge.warning('Stok: ${product.stock}')
                    else
                      AppBadge.success('Stok: ${product.stock}'),
                  ],
                ),
              ],
            ),
          ),
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
                      Text('Edit')
                    ])),
                const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline,
                          size: 16, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Hapus',
                          style: TextStyle(color: AppColors.error))
                    ])),
              ],
            ),
        ],
      ),
    );
  }
}

