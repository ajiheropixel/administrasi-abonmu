import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/expense_provider.dart';
import '../../../data/models/expense_model.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_confirm_dialog.dart';
import '../../widgets/app_snackbar.dart';
import 'expense_form_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ExpenseProvider>();
      p.loadExpenses(refresh: true);
      p.loadCategories();
    });
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        context.read<ExpenseProvider>().loadMore();
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
    final prov = context.watch<ExpenseProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pengeluaran'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _openForm(context),
            ),
        ],
      ),
      body: prov.loading
          ? const AppLoading()
          : prov.expenses.isEmpty
              ? AppEmptyState(
                  message: 'Belum ada data pengeluaran',
                  icon: Icons.payments_outlined,
                  onAction: isAdmin ? () => _openForm(context) : null,
                  actionLabel: 'Tambah Pengeluaran',
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => prov.loadExpenses(refresh: true),
                  child: ListView.separated(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        prov.expenses.length + (prov.loadingMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      if (i == prov.expenses.length) {
                        return const Center(
                            child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ));
                      }
                      final expense = prov.expenses[i];
                      return _ExpenseCard(
                        expense: expense,
                        isAdmin: isAdmin,
                        onEdit: () => _openForm(context, expense: expense),
                        onDelete: () => _delete(context, expense),
                      );
                    },
                  ),
                ),
    );
  }

  void _openForm(BuildContext context, {ExpenseModel? expense}) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ExpenseFormScreen(expense: expense)),
    ).then((_) => context.read<ExpenseProvider>().loadExpenses(refresh: true));
  }

  Future<void> _delete(BuildContext context, ExpenseModel expense) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Hapus Pengeluaran',
      message: 'Hapus pengeluaran "${expense.category}"?',
    );
    if (!ok || !mounted) return;
    final success =
        await context.read<ExpenseProvider>().deleteExpense(expense.id);
    if (!mounted) return;
    if (success) {
      showSuccessSnackbar(context, 'Pengeluaran berhasil dihapus');
    } else {
      showErrorSnackbar(
          context, context.read<ExpenseProvider>().error ?? 'Gagal menghapus');
    }
  }
}

class _ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpenseCard({
    required this.expense,
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
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.payments_outlined,
                color: AppColors.error, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.category,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  expense.description ?? DateFormatter.toDisplay(expense.expenseDate),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  CurrencyFormatter.format(expense.amount),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(DateFormatter.toDisplay(expense.expenseDate),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
              if (isAdmin) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onEdit,
                      child: const Icon(Icons.edit_outlined,
                          size: 16, color: AppColors.info),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(Icons.delete_outline,
                          size: 16, color: AppColors.error),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

