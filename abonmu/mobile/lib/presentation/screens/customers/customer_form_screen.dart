import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/customer_model.dart';
import '../../../providers/customer_provider.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/app_loading.dart';

class CustomerFormScreen extends StatefulWidget {
  final CustomerModel? customer;
  const CustomerFormScreen({super.key, this.customer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.customer?.name);
  late final _phoneCtrl = TextEditingController(text: widget.customer?.phone);
  late final _addressCtrl = TextEditingController(text: widget.customer?.address);
  bool _saving = false;

  bool get _isEdit => widget.customer != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final data = {
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
    };
    final prov = context.read<CustomerProvider>();
    final ok = _isEdit
        ? await prov.updateCustomer(widget.customer!.id, data)
        : await prov.createCustomer(data);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      showSuccessSnackbar(context, _isEdit ? 'Pelanggan berhasil diperbarui' : 'Pelanggan berhasil ditambahkan');
      Navigator.pop(context);
    } else {
      showErrorSnackbar(context, prov.error ?? 'Gagal menyimpan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isEdit ? 'Edit Pelanggan' : 'Tambah Pelanggan')),
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
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Nama Pelanggan'),
                        validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _addressCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Alamat'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Pelanggan'),
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



