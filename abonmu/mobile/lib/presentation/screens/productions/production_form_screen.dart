import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/production_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../providers/production_provider.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/app_loading.dart';
class ProductionFormScreen extends StatefulWidget {
  final ProductionModel? production;
  const ProductionFormScreen({super.key, this.production});

  @override
  State<ProductionFormScreen> createState() => _ProductionFormScreenState();
}

class _ProductionFormScreenState extends State<ProductionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productRepo = ProductRepository();

  List<ProductModel> _products = [];
  int? _selectedProductId;
  String _type = 'rutin';
  String _category = '';
  DateTime _date = DateTime.now();
  late final _qtyCtrl = TextEditingController(
      text: widget.production?.quantity.toString() ?? '');
  late final _notesCtrl =
      TextEditingController(text: widget.production?.notes ?? '');
  bool _saving = false;

  bool get _isEdit => widget.production != null;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    if (_isEdit) {
      _selectedProductId = widget.production!.productId;
      _type = widget.production!.type;
      _category = widget.production!.category;
      _date = DateTime.parse(widget.production!.productionDate);
    }
  }

  Future<void> _loadProducts() async {
    try {
      final result = await _productRepo.getProducts(perPage: 100);
      setState(() => _products = result['data'] as List<ProductModel>);
    } catch (_) {}
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductId == null) {
      showErrorSnackbar(context, 'Pilih produk terlebih dahulu');
      return;
    }
    setState(() => _saving = true);
    final data = {
      'product_id': _selectedProductId,
      'production_date': DateFormatter.toApi(_date),
      'quantity': int.tryParse(_qtyCtrl.text) ?? 0,
      'type': _type,
      'category': _category.isEmpty
          ? (_products.firstWhere((p) => p.id == _selectedProductId,
                  orElse: () => _products.first)
              .category)
          : _category,
      'notes': _notesCtrl.text.trim(),
    };
    final prov = context.read<ProductionProvider>();
    final ok = _isEdit
        ? await prov.updateProduction(widget.production!.id, data)
        : await prov.createProduction(data);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      showSuccessSnackbar(context,
          _isEdit ? 'Produksi berhasil diperbarui' : 'Produksi berhasil ditambahkan');
      Navigator.pop(context);
    } else {
      showErrorSnackbar(context, prov.error ?? 'Gagal menyimpan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isEdit ? 'Edit Produksi' : 'Tambah Produksi')),
      body: AppLoadingOverlay(
        loading: _saving,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _card([
                  // Product dropdown
                  DropdownButtonFormField<int>(
                    value: _selectedProductId,
                    decoration: const InputDecoration(labelText: 'Produk'),
                    items: _products
                        .map((p) => DropdownMenuItem(
                            value: p.id, child: Text(p.name)))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedProductId = v;
                        if (v != null) {
                          final prod = _products.firstWhere((p) => p.id == v);
                          _category = prod.category;
                        }
                      });
                    },
                    validator: (v) => v == null ? 'Pilih produk' : null,
                  ),
                  const SizedBox(height: 14),
                  // Date picker
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Produksi',
                          suffixIcon: Icon(Icons.calendar_today, size: 18),
                        ),
                        controller: TextEditingController(
                            text: DateFormatter.toDisplay(
                                DateFormatter.toApi(_date))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Jumlah (pcs)'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Jumlah wajib diisi';
                      if ((int.tryParse(v) ?? 0) <= 0) return 'Jumlah harus > 0';
                      return null;
                    },
                  ),
                ]),
                const SizedBox(height: 12),
                _card([
                  const Text('Tipe Produksi',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _typeChip('rutin', 'Rutin'),
                      const SizedBox(width: 10),
                      _typeChip('pesanan', 'Pesanan'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    onChanged: (v) => _category = v,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
                  ),
                ]),
                // Info created_by / updated_by (edit mode)
                if (_isEdit && widget.production != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Riwayat',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        if (widget.production!.createdBy != null)
                          _infoRow(Icons.person_add_outlined, 'Dibuat oleh',
                              widget.production!.createdBy!.name),
                        if (widget.production!.updatedBy != null)
                          _infoRow(Icons.edit_outlined, 'Diubah oleh',
                              widget.production!.updatedBy!.name),
                        _infoRow(Icons.access_time, 'Dibuat',
                            DateFormatter.toDisplay(widget.production!.createdAt)),
                        _infoRow(Icons.update, 'Diperbarui',
                            DateFormatter.toDisplay(widget.production!.updatedAt)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Produksi'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _typeChip(String value, String label) {
    final selected = _type == value;
    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Icon(icon, size: 12, color: AppColors.textHint),
            const SizedBox(width: 6),
            Text('$label: ',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
            Text(value,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
          ],
        ),
      );
}



