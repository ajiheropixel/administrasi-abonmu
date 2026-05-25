import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/product_provider.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/app_loading.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductModel? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.product?.name);
  late final _categoryCtrl =
      TextEditingController(text: widget.product?.category);
  late final _descCtrl =
      TextEditingController(text: widget.product?.description);
  late final _priceCtrl = TextEditingController(
      text: widget.product?.price.toStringAsFixed(0) ?? '');
  late final _unitCtrl =
      TextEditingController(text: widget.product?.unit ?? 'bungkus');
  bool _saving = false;

  bool get _isEdit => widget.product != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final data = {
      'name': _nameCtrl.text.trim(),
      'category': _categoryCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price': double.tryParse(_priceCtrl.text) ?? 0,
      'unit': _unitCtrl.text.trim(),
    };
    final prov = context.read<ProductProvider>();
    final ok = _isEdit
        ? await prov.updateProduct(widget.product!.id, data)
        : await prov.createProduct(data);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      showSuccessSnackbar(
          context, _isEdit ? 'Produk berhasil diperbarui' : 'Produk berhasil ditambahkan');
      Navigator.pop(context);
    } else {
      showErrorSnackbar(context, prov.error ?? 'Gagal menyimpan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Produk' : 'Tambah Produk'),
      ),
      body: AppLoadingOverlay(
        loading: _saving,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _card([
                  _field(_nameCtrl, 'Nama Produk', required: true),
                  const SizedBox(height: 14),
                  _field(_categoryCtrl, 'Kategori',
                      hint: 'Abon Ayam, Abon Sapi...', required: true),
                  const SizedBox(height: 14),
                  _field(_descCtrl, 'Deskripsi', maxLines: 3),
                ]),
                const SizedBox(height: 12),
                _card([
                  _field(_priceCtrl, 'Harga (Rp)',
                      keyboardType: TextInputType.number, required: true),
                  const SizedBox(height: 14),
                  _field(_unitCtrl, 'Satuan',
                      hint: 'bungkus, kg, pcs...', required: true),
                ]),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Produk'),
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
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _field(
    TextEditingController ctrl,
    String label, {
    String? hint,
    bool required = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label, hintText: hint),
        validator: required
            ? (v) => (v == null || v.isEmpty) ? '$label wajib diisi' : null
            : null,
      );
}

