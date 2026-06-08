import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthRepository {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await ApiClient.post('login', body: {
      'email': email,
      'password': password,
    });
    final data = response['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

    // Persist token & user
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));

    ApiClient.setToken(token);
    return {'token': token, 'user': user};
  }

  Future<void> logout() async {
    try {
      await ApiClient.post('logout');
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    ApiClient.setToken(null);
  }

  Future<UserModel?> getProfile() async {
    final response = await ApiClient.get('profile');
    return UserModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<UserModel?> loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final userJson = prefs.getString(AppConstants.userKey);
    if (token == null || userJson == null) return null;
    ApiClient.setToken(token);
    return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  }
}



