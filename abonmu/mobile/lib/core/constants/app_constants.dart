import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

class AppConstants {
  // ── API Base URL ─────────────────────────────────────────────────────────
  //
  // Aturan penentuan baseUrl:
  //
  //  Flutter Web (flutter run / build):
  //    - Saat development (flutter run): server Laravel di localhost:8000
  //    - Saat production (di-serve dari Laravel /app): pakai path relatif
  //
  //  Flutter Mobile:
  //    - Android emulator : 10.0.2.2:8000
  //    - Device fisik     : ganti dengan IP komputer
  //
  static String get baseUrl {
    if (kIsWeb) {
      // Selalu pakai absolute URL ke Laravel server
      // Ganti port jika server jalan di port lain
      return 'http://localhost:8000/api/v1';
    }
    // Android emulator
    return 'http://10.0.2.2:8000/api/v1';
  }

  /// URL base untuk aset storage (gambar produk, dll)
  static String get storageUrl {
    if (kIsWeb) return 'http://localhost:8000/storage';
    return 'http://10.0.2.2:8000/storage';
  }

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  static const String tokenKey    = 'auth_token';
  static const String userKey     = 'user_data';
  static const String roleKey     = 'user_role';

  static const int defaultPerPage          = 15;
  static const int lowStockThreshold       = 50;
  static const int criticalStockThreshold  = 20;

  static const String appName    = 'AbonMu';
  static const String appVersion = '1.0.0';

  static const String dateFormat     = 'dd MMM yyyy';
  static const String dateFormatApi  = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'dd MMM yyyy, HH:mm';

  static const String roleAdmin    = 'admin';
  static const String roleOwner    = 'owner';
  static const String saleTypeEcer    = 'ecer';
  static const String saleTypePesanan = 'pesanan';
  static const String productionTypeRutin   = 'rutin';
  static const String productionTypePesanan = 'pesanan';
}
