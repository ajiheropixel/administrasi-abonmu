import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/expense_model.dart';
import '../../../providers/expense_provider.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/app_loading.dart';

class ExpenseFormScreen extends StatefulWidget {
  final ExpenseModel? expense;
  const ExpenseFormScreen({super.key, this.expense});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _categoryCtrl = TextEditingController(text: widget.expense?.category);
  late final _amountCtrl = TextEditingController(text: widget.expense?.amount.toStringAsFixed(0) ?? '');
  late final _descCtrl = TextEditingController(text: widget.expense?.description);
  DateTime _date = DateTime.now();
  bool _saving = false;

  bool get _isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _date = DateTime.parse(widget.expense!.expenseDate);
    }
  }

  @override
  void dispose() {
    _categoryCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final data = {
      'expense_date': DateFormatter.toApi(_date),
      'category': _categoryCtrl.text.trim(),
      'amount': double.tryParse(_amountCtrl.text) ?? 0,
      'description': _descCtrl.text.trim(),
    };
    final prov = context.read<ExpenseProvider>();
    final ok = _isEdit
        ? await prov.updateExpense(widget.expense!.id, data)
        : await prov.createExpense(data);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      showSuccessSnackbar(context, _isEdit ? 'Pengeluaran berhasil diperbarui' : 'Pengeluaran berhasil ditambahkan');
      Navigator.pop(context);
    } else {
      showErrorSnackbar(context, prov.error ?? 'Gagal menyimpan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isEdit ? 'Edit Pengeluaran' : 'Tambah Pengeluaran')),
      body: AppLoadingOverlay(
        loading: _saving,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _categoryCtrl,
                        decoration: const InputDecoration(labelText: 'Kategori'),
                        validator: (v) => (v == null || v.isEmpty) ? 'Kategori wajib diisi' : null,
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: _pickDate,
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Tanggal',
                              suffixIcon: Icon(Icons.calendar_today, size: 18),
                            ),
                            controller: TextEditingController(text: DateFormatter.toDisplay(DateFormatter.toApi(_date))),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _amountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Jumlah wajib diisi';
                          if ((double.tryParse(v) ?? 0) <= 0) return 'Jumlah harus > 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Deskripsi (opsional)'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Pengeluaran'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

