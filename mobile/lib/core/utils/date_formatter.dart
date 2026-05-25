import 'package:intl/intl.dart';

class DateFormatter {
  static final _displayFormat = DateFormat('dd MMM yyyy', 'id_ID');
  static final _apiFormat = DateFormat('yyyy-MM-dd');
  static final _monthYearFormat = DateFormat('MMM yyyy', 'id_ID');
  static final _fullFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

  static String toDisplay(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return _displayFormat.format(date);
    } catch (_) {
      return dateStr;
    }
  }

  static String toApi(DateTime date) => _apiFormat.format(date);

  static String toMonthYear(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return _monthYearFormat.format(date);
    } catch (_) {
      return dateStr;
    }
  }

  static String toFull(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return _fullFormat.format(date);
    } catch (_) {
      return dateStr;
    }
  }

  static String startOfMonth() {
    final now = DateTime.now();
    return _apiFormat.format(DateTime(now.year, now.month, 1));
  }

  static String endOfMonth() {
    final now = DateTime.now();
    return _apiFormat.format(DateTime(now.year, now.month + 1, 0));
  }

  static String today() => _apiFormat.format(DateTime.now());
}

