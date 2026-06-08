import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  // File yang dipilih
  String? _pickedFilePath;    // path untuk mobile/desktop
  PlatformFile? _pickedFile;  // untuk web (bytes) dan mobile (path+bytes)
  Uint8List? _pickedBytes;    // bytes preview — kompatibel web & mobile
  bool _saving = false;

  bool get _isEdit => widget.product != null;
  bool get _hasNewImage => _pickedFilePath != null || _pickedBytes != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true, // selalu baca bytes — kompatibel web & mobile
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    setState(() {
      _pickedFile = file;
      _pickedFilePath = file.path; // null di web, ada di mobile
      _pickedBytes = file.bytes;   // selalu ada karena withData: true
    });
  }

  void _removeImage() {
    setState(() {
      _pickedFilePath = null;
      _pickedFile = null;
      _pickedBytes = null;
    });
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
        ? await prov.updateProduct(
            widget.product!.id,
            data,
            imagePath: _pickedFilePath,
          )
        : await prov.createProduct(
            data,
            imagePath: _pickedFilePath,
          );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      showSuccessSnackbar(context,
          _isEdit ? 'Produk berhasil diperbarui' : 'Produk berhasil ditambahkan');
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
                // ── Foto Produk ────────────────────────────────
                _card([
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Foto Produk',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary)),
                      if (_hasNewImage || (widget.product?.hasImage ?? false))
                        GestureDetector(
                          onTap: _removeImage,
                          child: const Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  size: 14, color: AppColors.error),
                              SizedBox(width: 4),
                              Text('Hapus',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.error)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: _buildImagePreview(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.upload_outlined,
                          size: 13, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        _hasNewImage
                            ? 'Gambar dipilih — ketuk untuk ganti'
                            : (widget.product?.hasImage ?? false)
                                ? 'Ketuk untuk ganti foto'
                                : 'Ketuk untuk upload foto produk',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textHint),
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 12),
                // ── Info Produk ────────────────────────────────
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

  Widget _buildImagePreview() {
    // Gambar baru dipilih — pakai bytes (kompatibel web & mobile)
    if (_pickedBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(
          _pickedBytes!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 160,
        ),
      );
    }
    // Gambar dari server (edit mode)
    if (widget.product?.hasImage ?? false) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          widget.product!.imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 160,
          errorBuilder: (_, __, ___) => _emptyPlaceholder(),
        ),
      );
    }
    return _emptyPlaceholder();
  }

  Widget _emptyPlaceholder() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              size: 44,
              color: AppColors.textHint.withValues(alpha: 0.5)),
          const SizedBox(height: 10),
          const Text('Upload Foto Produk',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textHint)),
          const SizedBox(height: 4),
          const Text('JPG, PNG, WebP • Maks 2MB',
              style: TextStyle(fontSize: 11, color: AppColors.textHint)),
        ],
      );

  Widget _card(List<Widget> children) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
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
