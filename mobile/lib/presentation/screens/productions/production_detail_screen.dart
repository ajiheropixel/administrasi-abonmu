import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/production_model.dart';
import '../../../data/repositories/production_repository.dart';
import '../../widgets/app_loading.dart';

class ProductionDetailScreen extends StatefulWidget {
  final int id;
  const ProductionDetailScreen({super.key, required this.id});

  @override
  State<ProductionDetailScreen> createState() => _ProductionDetailScreenState();
}

class _ProductionDetailScreenState extends State<ProductionDetailScreen> {
  final _repo = ProductionRepository();
  ProductionModel? _production;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await _repo.getProduction(widget.id);
      setState(() { _production = p; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detail Produksi')),
      body: _loading
          ? const AppLoading()
          : _error != null
              ? Center(child: Text(_error!))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final p = _production!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.product?.name ?? 'Produk #${p.productId}',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(p.category,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                const SizedBox(height: 16),
                Row(children: [
                  _headerStat('Jumlah', '${CurrencyFormatter.formatNumber(p.quantity)} pcs'),
                  const SizedBox(width: 24),
                  _headerStat('Tanggal', DateFormatter.toDisplay(p.productionDate)),
                  const SizedBox(width: 24),
                  _headerStat('Tipe', p.type.toUpperCase()),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _infoCard('Informasi Produksi', [
            _infoRow('Produk', p.product?.name ?? '-'),
            _infoRow('Kategori', p.category),
            _infoRow('Tipe', p.isRutin ? 'Rutin' : 'Pesanan'),
            _infoRow('Tanggal', DateFormatter.toDisplay(p.productionDate)),
            _infoRow('Jumlah', '${CurrencyFormatter.formatNumber(p.quantity)} ${p.product?.unit ?? 'pcs'}'),
            if (p.notes != null && p.notes!.isNotEmpty) _infoRow('Catatan', p.notes!),
          ]),
          if (p.expenses != null && p.expenses!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pengeluaran Terkait',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  ...p.expenses!.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.category, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          if (e.description != null)
                            Text(e.description!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      )),
                      Text(CurrencyFormatter.format(e.amount),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error)),
                    ]),
                  )),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
                      Text(
                        CurrencyFormatter.format(p.expenses!.fold(0.0, (s, e) => s + e.amount)),
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.error),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _headerStat(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
    ],
  );

  Widget _infoCard(String title, List<Widget> rows) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.cardBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        ...rows,
      ],
    ),
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
      ],
    ),
  );
}

