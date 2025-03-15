import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final Dio _dio = Dio();
  static const String _baseUrl = 'http://47.95.171.19';
  static const String _login = '/admin_invoice/user/login';

  Future<(bool success, String message)> login(
    String username,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '$_baseUrl$_login',
        data: jsonEncode({'username': username, 'password': password}),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      final responseData = response.data as Map<String, dynamic>;
      String message = (responseData['message']?.toString() ?? '登录失败').trim();

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userInfo', jsonEncode(responseData));
        prefs.setString('auth_token', jsonEncode(responseData['token']));
        prefs.setString('user_id', jsonEncode(responseData['user_id']));
        prefs.setString('username', jsonEncode(responseData['username']));
        prefs.setString('avatar', responseData['avatar']);
        prefs.setString('message', jsonEncode(responseData['message']));
        // 调试输出
        debugPrint('Stored UserID: ${prefs.getString('user_id')}');
        return (true, message);
      }
      return (false, message);
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.response?.data?['message'] ?? e.message}');
    }
  }
}
