import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/employee_model.dart';
import '../../../providers/employee_provider.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/app_loading.dart';

class EmployeeFormScreen extends StatefulWidget {
  final EmployeeModel? employee;
  const EmployeeFormScreen({super.key, this.employee});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.employee?.name);
  late final _positionCtrl = TextEditingController(text: widget.employee?.position);
  late final _phoneCtrl = TextEditingController(text: widget.employee?.phone);
  late final _addressCtrl = TextEditingController(text: widget.employee?.address);
  late final _salaryCtrl = TextEditingController(text: widget.employee?.salary?.toStringAsFixed(0) ?? '');
  bool _saving = false;

  bool get _isEdit => widget.employee != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _positionCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _salaryCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final data = {
      'name': _nameCtrl.text.trim(),
      'position': _positionCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'salary': double.tryParse(_salaryCtrl.text) ?? 0,
    };
    final prov = context.read<EmployeeProvider>();
    final ok = _isEdit
        ? await prov.updateEmployee(widget.employee!.id, data)
        : await prov.createEmployee(data);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      showSuccessSnackbar(context, _isEdit ? 'Karyawan berhasil diperbarui' : 'Karyawan berhasil ditambahkan');
      Navigator.pop(context);
    } else {
      showErrorSnackbar(context, prov.error ?? 'Gagal menyimpan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isEdit ? 'Edit Karyawan' : 'Tambah Karyawan')),
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
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Nama Karyawan'),
                        validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _positionCtrl,
                        decoration: const InputDecoration(labelText: 'Jabatan / Posisi'),
                        validator: (v) => (v == null || v.isEmpty) ? 'Jabatan wajib diisi' : null,
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
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Alamat'),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _salaryCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Gaji (Rp)'),
                        validator: (v) => (v == null || v.isEmpty) ? 'Gaji wajib diisi' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Karyawan'),
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

