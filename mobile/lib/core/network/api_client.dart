import 'dart:convert';
import 'dart:io';
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
    final cleaned = params.map((k, v) => MapEntry(k, v.toString()))
      ..removeWhere((_, v) => v.isEmpty || v == 'null');
    return uri.replace(queryParameters: cleaned);
  }

  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await http
          .get(_uri(path, params), headers: _headers)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet');
    } on HttpException {
      throw ApiException('Terjadi kesalahan jaringan');
    }
  }

  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await http
          .post(_uri(path), headers: _headers, body: jsonEncode(body ?? {}))
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet');
    } on HttpException {
      throw ApiException('Terjadi kesalahan jaringan');
    }
  }

  static Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await http
          .put(_uri(path), headers: _headers, body: jsonEncode(body ?? {}))
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet');
    } on HttpException {
      throw ApiException('Terjadi kesalahan jaringan');
    }
  }

  static Future<Map<String, dynamic>> delete(String path) async {
    try {
      final response = await http
          .delete(_uri(path), headers: _headers)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet');
    } on HttpException {
      throw ApiException('Terjadi kesalahan jaringan');
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    final message = body['message'] as String? ?? 'Terjadi kesalahan';
    throw ApiException(message, statusCode: response.statusCode);
  }
}

