import 'package:intl/intl.dart';

class DateFormatter {
  static final _displayFormat = DateFormat('dd MMM yyyy', 'id_ID');
  static final _apiFormat = DateFormat('yyyy-MM-dd');
  static final _monthYearFormat = DateFormat('MMM yyyy', 'id_ID');
  static final _fullFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

  /// Parse tanggal dari berbagai format:
  /// - "2026-05-19"
  /// - "2026-05-19T00:00:00.000000Z"  (ISO 8601)
  /// - "2026-05-19T00:00:00Z"
  static DateTime? _parse(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      // DateTime.parse handles ISO 8601 including timezone suffix
      return DateTime.parse(dateStr).toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Tampilkan sebagai "19 Mei 2026"
  static String toDisplay(String? dateStr) {
    final date = _parse(dateStr);
    if (date == null) return '-';
    try {
      return _displayFormat.format(date);
    } catch (_) {
      // Fallback manual jika locale belum siap
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${date.day.toString().padLeft(2, '0')} ${months[date.month]} ${date.year}';
    }
  }

  static String toApi(DateTime date) => _apiFormat.format(date);

  static String toMonthYear(String? dateStr) {
    final date = _parse(dateStr);
    if (date == null) return '-';
    try {
      return _monthYearFormat.format(date);
    } catch (_) {
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${months[date.month]} ${date.year}';
    }
  }

  static String toFull(String? dateStr) {
    final date = _parse(dateStr);
    if (date == null) return '-';
    try {
      return _fullFormat.format(date);
    } catch (_) {
      return toDisplay(dateStr);
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
