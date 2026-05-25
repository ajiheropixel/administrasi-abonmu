import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../providers/sale_provider.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/app_loading.dart';

class _SaleItem {
  ProductModel product;
  int quantity;
  double price;
  _SaleItem({required this.product, required this.quantity, required this.price});
  double get subtotal => quantity * price;
}

class SaleFormScreen extends StatefulWidget {
  const SaleFormScreen({super.key});

  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  final _productRepo = ProductRepository();
  final _customerRepo = CustomerRepository();

  List<ProductModel> _products = [];
  List<CustomerModel> _customers = [];
  final List<_SaleItem> _items = [];
  CustomerModel? _selectedCustomer;
  String _type = 'ecer';
  DateTime _date = DateTime.now();
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final pr = await _productRepo.getProducts(perPage: 100);
      final cr = await _customerRepo.getCustomers(perPage: 100);
      setState(() {
        _products = pr['data'] as List<ProductModel>;
        _customers = cr['data'] as List<CustomerModel>;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _total => _items.fold(0, (s, i) => s + i.subtotal);

  void _addItem() {
    if (_products.isEmpty) return;
    setState(() {
      _items.add(_SaleItem(product: _products.first, quantity: 1, price: _products.first.price));
    });
  }

  void _removeItem(int idx) => setState(() => _items.removeAt(idx));

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
    if (_items.isEmpty) {
      showErrorSnackbar(context, 'Tambahkan minimal 1 item');
      return;
    }
    setState(() => _saving = true);
    final data = {
      'customer_id': _selectedCustomer?.id,
      'sale_date': DateFormatter.toApi(_date),
      'type': _type,
      'notes': _notesCtrl.text.trim(),
      'items': _items.map((i) => {
        'product_id': i.product.id,
        'quantity': i.quantity,
        'price': i.price,
      }).toList(),
    };
    final prov = context.read<SaleProvider>();
    final ok = await prov.createSale(data);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      showSuccessSnackbar(context, 'Penjualan berhasil ditambahkan');
      Navigator.pop(context);
    } else {
      showErrorSnackbar(context, prov.error ?? 'Gagal menyimpan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tambah Penjualan')),
      body: AppLoadingOverlay(
        loading: _saving,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Header info
                    _card([
                      DropdownButtonFormField<CustomerModel>(
                        value: _selectedCustomer,
                        decoration: const InputDecoration(labelText: 'Pelanggan (opsional)'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Umum / Tanpa Pelanggan')),
                          ..._customers.map((c) => DropdownMenuItem(value: c, child: Text(c.name))),
                        ],
                        onChanged: (v) => setState(() => _selectedCustomer = v),
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: _pickDate,
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Tanggal Penjualan',
                              suffixIcon: Icon(Icons.calendar_today, size: 18),
                            ),
                            controller: TextEditingController(
                                text: DateFormatter.toDisplay(DateFormatter.toApi(_date))),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text('Tipe Penjualan',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Row(children: [
                        _typeChip('ecer', 'Ecer'),
                        const SizedBox(width: 10),
                        _typeChip('pesanan', 'Pesanan'),
                      ]),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _notesCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
                      ),
                    ]),
                    const SizedBox(height: 12),

                    // Items
                    _card([
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Item Produk',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          TextButton.icon(
                            onPressed: _addItem,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Tambah'),
                          ),
                        ],
                      ),
                      if (_items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text('Belum ada item. Tap "Tambah" untuk menambahkan.',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                textAlign: TextAlign.center),
                          ),
                        ),
                      ..._items.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<ProductModel>(
                                      value: item.product,
                                      decoration: const InputDecoration(
                                          labelText: 'Produk', isDense: true),
                                      items: _products.map((p) => DropdownMenuItem(
                                          value: p, child: Text(p.name, overflow: TextOverflow.ellipsis))).toList(),
                                      onChanged: (p) {
                                        if (p != null) {
                                          setState(() {
                                            _items[idx].product = p;
                                            _items[idx].price = p.price;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () => _removeItem(idx),
                                    icon: const Icon(Icons.close, color: AppColors.error, size: 18),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: item.quantity.toString(),
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'Qty', isDense: true),
                                      onChanged: (v) => setState(() => _items[idx].quantity = int.tryParse(v) ?? 1),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: item.price.toStringAsFixed(0),
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'Harga', isDense: true),
                                      onChanged: (v) => setState(() => _items[idx].price = double.tryParse(v) ?? 0),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Subtotal', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                      Text(CurrencyFormatter.format(item.subtotal),
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ]),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // Bottom total & save
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.cardBorder)),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text(CurrencyFormatter.format(_total),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.success)),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: const Text('Simpan Penjualan'),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
}

