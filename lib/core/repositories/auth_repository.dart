import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final Dio _dio = Dio();
  static const String _baseUrl = 'http://127.0.0.1:8000';
  static const String _login = '/admin_invoice/user/login';
  static const String _register = '/register';
  static const String _sendCode = '/register/code';
  static const String _retrieveCode = '/retrieve/password/code';
  static const String _retrievePassword = '/retrieve/password';

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
        debugPrint(responseData.toString());
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userInfo', jsonEncode(responseData));
        prefs.setString('auth_token', jsonEncode(responseData['token']));
        prefs.setString('user_id', jsonEncode(responseData['user_id']));
        prefs.setString('username', jsonEncode(responseData['username']));
        prefs.setString('avatar', responseData['avatar']);
        prefs.setString('message', jsonEncode(responseData['message']));
        // 调试输出
        debugPrint('Stored UserID: ${prefs.getString('user_id')}');
        debugPrint('所属队伍编号: ${prefs.getString('team_id')}');
        return (true, message);
      }
      return (false, message);
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  Future<(bool success, String message)> register(
    String username,
    String email,
    String password,
    String code,
  ) async {
    try {
      final response = await _dio.post(
        '$_baseUrl$_register',
        data: jsonEncode({
          'username': username,
          'password': password,
          'email': email,
          'code': code,
        }),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final message = responseData['message'].toString();
        return (true, message);
      }
    } on DioException catch (e) {
      // 捕获 Dio 异常
      if (e.response?.statusCode == 400) {
        // 解析 FastAPI 返回的 detail
        final errorDetail = e.response!.data['detail'].toString();
        debugPrint('400错误详情: $errorDetail');
        return (false, errorDetail);
      } else {
        debugPrint('其他错误: ${e.message}');
      }
    } catch (e) {
      debugPrint('未知错误: $e');
    }
    return (false, '注册失败');
  }

  Future<String?> sendCode(String email) async {
    try {
      final response = await _dio.post(
        '$_baseUrl$_sendCode',
        data: jsonEncode({'email': email}),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final code = responseData['code'];
        final String message = code.toString();
        debugPrint(message);
        return message;
      }
    } catch (e) {
      debugPrint('未知错误: $e');
    }
    return null;
  }

  Future<String?> sendPasswordResetCode(String email) async {
    try {
      final response = await _dio.post(
        '$_baseUrl$_retrieveCode',
        data: jsonEncode({'email': email}),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final code = responseData['code'];
        final String message = code.toString();
        debugPrint(message);
        return message;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<(bool success, String message)> resetPassword(
    String email,
    String code,
    String newpassword,
  ) async {
    try {
      final response = await _dio.post(
        '$_baseUrl$_retrievePassword',
        data: jsonEncode({
          'email': email,
          'code': code,
          'newpassword': newpassword,
        }),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final username = responseData['username'];
        final String message = username.toString();
        debugPrint(message);
        return (true, message);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return (false, '找回失败，用户不存在');
  }
}
