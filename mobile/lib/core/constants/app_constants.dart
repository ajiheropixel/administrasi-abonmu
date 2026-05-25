class AppConstants {
  // API
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String roleKey = 'user_role';

  // Pagination
  static const int defaultPerPage = 15;

  // Stock thresholds
  static const int lowStockThreshold = 50;
  static const int criticalStockThreshold = 20;

  // App info
  static const String appName = 'AbonMu';
  static const String appVersion = '1.0.0';

  // Date formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateFormatApi = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'dd MMM yyyy, HH:mm';

  // Roles
  static const String roleAdmin = 'admin';
  static const String roleOwner = 'owner';

  // Sale types
  static const String saleTypeEcer = 'ecer';
  static const String saleTypePesanan = 'pesanan';

  // Production types
  static const String productionTypeRutin = 'rutin';
  static const String productionTypePesanan = 'pesanan';
}

