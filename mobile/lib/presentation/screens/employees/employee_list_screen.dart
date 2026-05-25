import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/employee_provider.dart';
import '../../../data/models/employee_model.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/app_confirm_dialog.dart';
import '../../widgets/app_snackbar.dart';
import 'employee_form_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().loadEmployees(refresh: true);
    });
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
        context.read<EmployeeProvider>().loadMore();
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
    final prov = context.watch<EmployeeProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Karyawan'),
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
              hint: 'Cari nama karyawan...',
              onChanged: (v) => context.read<EmployeeProvider>().setSearch(v),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: prov.loading
                ? const AppLoading()
                : prov.employees.isEmpty
                    ? AppEmptyState(
                        message: 'Belum ada karyawan',
                        icon: Icons.badge_outlined,
                        onAction: isAdmin ? () => _openForm(context) : null,
                        actionLabel: 'Tambah Karyawan',
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => prov.loadEmployees(refresh: true),
                        child: ListView.separated(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.all(16),
                          itemCount: prov.employees.length + (prov.loadingMore ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (ctx, i) {
                            if (i == prov.employees.length) {
                              return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppColors.primary)));
                            }
                            final e = prov.employees[i];
                            return _EmployeeCard(
                              employee: e,
                              isAdmin: isAdmin,
                              onEdit: () => _openForm(context, employee: e),
                              onDelete: () => _delete(context, e),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _openForm(BuildContext context, {EmployeeModel? employee}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => EmployeeFormScreen(employee: employee)))
        .then((_) => context.read<EmployeeProvider>().loadEmployees(refresh: true));
  }

  Future<void> _delete(BuildContext context, EmployeeModel e) async {
    final ok = await showConfirmDialog(context, title: 'Hapus Karyawan', message: 'Hapus "${e.name}"?');
    if (!ok || !mounted) return;
    final success = await context.read<EmployeeProvider>().deleteEmployee(e.id);
    if (!mounted) return;
    if (success) showSuccessSnackbar(context, 'Karyawan berhasil dihapus');
    else showErrorSnackbar(context, context.read<EmployeeProvider>().error ?? 'Gagal menghapus');
  }
}

class _EmployeeCard extends StatelessWidget {
  final EmployeeModel employee;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EmployeeCard({required this.employee, required this.isAdmin, required this.onEdit, required this.onDelete});

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
          CircleAvatar(
            backgroundColor: AppColors.secondaryLight.withValues(alpha: 0.3),
            radius: 22,
            child: Text(employee.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(employee.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                if (employee.position != null)
                  Text(employee.position!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                if (employee.salary != null)
                  Text(CurrencyFormatter.format(employee.salary!), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
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

