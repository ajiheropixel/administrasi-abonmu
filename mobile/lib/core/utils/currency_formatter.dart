import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final _compactFormatter = NumberFormat.compactCurrency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 1,
  );

  static final _numberFormatter = NumberFormat('#,###', 'id_ID');

  static String format(dynamic value) {
    final num = double.tryParse(value.toString()) ?? 0;
    return _formatter.format(num);
  }

  static String formatCompact(dynamic value) {
    final num = double.tryParse(value.toString()) ?? 0;
    if (num >= 1000000) return _compactFormatter.format(num);
    return _formatter.format(num);
  }

  static String formatNumber(dynamic value) {
    final num = double.tryParse(value.toString()) ?? 0;
    return _numberFormatter.format(num);
  }
}

