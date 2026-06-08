import '../constants/app_constants.dart';

class ImageHelper {
  /// Normalisasi URL gambar dari server.
  ///
  /// Server mengembalikan: http://localhost:8000/api/v1/image/products/xxx.jpg
  /// Kita ganti host:port agar cocok dengan baseUrl Flutter.
  ///
  /// Contoh (web)    : http://localhost:8000/api/v1/image/... → sama
  /// Contoh (mobile) : http://localhost:8000/... → http://10.0.2.2:8000/...
  static String? normalize(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return null;
    try {
      final imageUri  = Uri.parse(rawUrl);
      final serverUri = Uri.parse(AppConstants.baseUrl);

      return Uri(
        scheme: serverUri.scheme,
        host:   serverUri.host,
        port:   serverUri.port,
        path:   imageUri.path,
      ).toString();
    } catch (_) {
      return rawUrl;
    }
  }
}
