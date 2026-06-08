import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/customer_provider.dart';
import '../../../data/models/customer_model.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/app_confirm_dialog.dart';
import '../../widgets/app_snackbar.dart';
import 'customer_form_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers(refresh: true);
    });
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
        context.read<CustomerProvider>().loadMore();
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
    final prov = context.watch<CustomerProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pelanggan'),
        actions: [
          if (isAdmin)
            IconButton(icon: const Icon(Icons.add), onPressed: () => _openForm(context)),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: AppSearchBar(
              hint: 'Cari nama atau telepon...',
              onChanged: (v) => context.read<CustomerProvider>().setSearch(v),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: prov.loading
                ? const AppLoading()
                : prov.customers.isEmpty
                    ? AppEmptyState(
                        message: 'Belum ada pelanggan',
                        icon: Icons.people_outline,
                        onAction: isAdmin ? () => _openForm(context) : null,
                        actionLabel: 'Tambah Pelanggan',
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => prov.loadCustomers(refresh: true),
                        child: ListView.separated(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.all(16),
                          itemCount: prov.customers.length + (prov.loadingMore ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (ctx, i) {
                            if (i == prov.customers.length) {
                              return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppColors.primary)));
                            }
                            final c = prov.customers[i];
                            return _CustomerCard(
                              customer: c,
                              isAdmin: isAdmin,
                              onEdit: () => _openForm(context, customer: c),
                              onDelete: () => _delete(context, c),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _openForm(BuildContext context, {CustomerModel? customer}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerFormScreen(customer: customer)))
        .then((_) => context.read<CustomerProvider>().loadCustomers(refresh: true));
  }

  Future<void> _delete(BuildContext context, CustomerModel c) async {
    final ok = await showConfirmDialog(context, title: 'Hapus Pelanggan', message: 'Hapus "${c.name}"?');
    if (!ok || !mounted) return;
    final success = await context.read<CustomerProvider>().deleteCustomer(c.id);
    if (!mounted) return;
    if (success) showSuccessSnackbar(context, 'Pelanggan berhasil dihapus');
    else showErrorSnackbar(context, context.read<CustomerProvider>().error ?? 'Gagal menghapus');
  }
}

class _CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CustomerCard({required this.customer, required this.isAdmin, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.infoBg,
            radius: 22,
            child: Text(customer.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: AppColors.info, fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                if (customer.phone != null)
                  Text(customer.phone!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                if (customer.address != null)
                  Text(customer.address!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (isAdmin)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.textHint, size: 20),
              onSelected: (v) { if (v == 'edit') onEdit(); if (v == 'delete') onDelete(); },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('Edit')])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: AppColors.error), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: AppColors.error))])),
              ],
            ),
        ],
      ),
    );
  }
}



