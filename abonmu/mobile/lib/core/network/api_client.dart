import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  static String? _token;

  static void setToken(String? token) => _token = token;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static Uri _uri(String path, [Map<String, dynamic>? params]) {
    final uri = Uri.parse('${AppConstants.baseUrl}/$path');
    if (params == null || params.isEmpty) return uri;
    final cleaned = <String, String>{};
    params.forEach((k, v) {
      final s = v.toString();
      if (s.isNotEmpty && s != 'null') cleaned[k] = s;
    });
    return uri.replace(queryParameters: cleaned);
  }

  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    final url = _uri(path, params);
    debugPrint('[API] GET $url');
    try {
      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
      return _handleResponse(response);
    } catch (e) {
      debugPrint('[API] GET ERROR: $e');
      if (e is ApiException) rethrow;
      throw ApiException(_networkError(e));
    }
  }

  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final url = _uri(path);
    debugPrint('[API] POST $url body=${jsonEncode(body)}');
    try {
      final response = await http
          .post(url, headers: _headers, body: jsonEncode(body ?? {}))
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
      return _handleResponse(response);
    } catch (e) {
      debugPrint('[API] POST ERROR: $e');
      if (e is ApiException) rethrow;
      throw ApiException(_networkError(e));
    }
  }

  static Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final url = _uri(path);
    debugPrint('[API] PUT $url');
    try {
      final response = await http
          .put(url, headers: _headers, body: jsonEncode(body ?? {}))
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
      return _handleResponse(response);
    } catch (e) {
      debugPrint('[API] PUT ERROR: $e');
      if (e is ApiException) rethrow;
      throw ApiException(_networkError(e));
    }
  }

  static Future<Map<String, dynamic>> delete(String path) async {
    final url = _uri(path);
    debugPrint('[API] DELETE $url');
    try {
      final response = await http
          .delete(url, headers: _headers)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
      return _handleResponse(response);
    } catch (e) {
      debugPrint('[API] DELETE ERROR: $e');
      if (e is ApiException) rethrow;
      throw ApiException(_networkError(e));
    }
  }

  /// Multipart POST/PUT — untuk upload file (mobile only)
  static Future<Map<String, dynamic>> multipart(
    String method,
    String path, {
    required Map<String, String> fields,
    String? filePath,
    String fileField = 'image',
  }) async {
    final url = _uri(path);
    debugPrint('[API] MULTIPART $method $url');
    try {
      final request = http.MultipartRequest(method.toUpperCase(), url);
      request.headers.addAll({
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      });
      request.fields.addAll(fields);
      if (filePath != null && !kIsWeb) {
        request.files
            .add(await http.MultipartFile.fromPath(fileField, filePath));
      }
      final streamed = await request
          .send()
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
      final response = await http.Response.fromStream(streamed);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('[API] MULTIPART ERROR: $e');
      if (e is ApiException) rethrow;
      throw ApiException(_networkError(e));
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    debugPrint('[API] RESPONSE ${response.statusCode} ${response.request?.url}');
    try {
      final body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }
      final message = body['message'] as String? ?? 'Terjadi kesalahan';
      throw ApiException(message, statusCode: response.statusCode);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
          'Response tidak valid (${response.statusCode})',
          statusCode: response.statusCode);
    }
  }

  static String _networkError(Object e) {
    final msg = e.toString();
    if (msg.contains('Failed host lookup') ||
        msg.contains('Connection refused') ||
        msg.contains('Network is unreachable') ||
        msg.contains('XMLHttpRequest') ||
        msg.contains('CORS') ||
        msg.contains('SocketException')) {
      return 'Tidak dapat terhubung ke server.\n'
          'Pastikan server Laravel berjalan di ${AppConstants.baseUrl}';
    }
    if (msg.contains('TimeoutException')) {
      return 'Koneksi timeout. Periksa server dan jaringan.';
    }
    return 'Error jaringan: $msg';
  }
}
