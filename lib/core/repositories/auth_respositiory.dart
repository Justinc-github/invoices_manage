import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRespositiory {
  final Dio _dio = Dio();
  static const String _baseUrl = 'http://47.95.171.19';
  static const String _login = '/admin_invoice/user/login';
  Future<void> login(username, password) async {
    try {
      final loginUrl = Uri.parse('$_baseUrl$_login').toString();
      var body = {'username': username, 'password': password};
      // 发送请求
      Response response = await _dio.post(
        loginUrl,
        data: jsonEncode(body),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      // 登录成功存储用户信息，否则显示登录失败
      if (response.statusCode == 200) {
        var responseData = response.data as Map<String, dynamic>;
        saveUserInfo(responseData);
      } else {
        if (kDebugMode) {
          print('登录失败: ${response.statusCode}');
        }
        var errorData = response.data;
        if (kDebugMode) {
          print('错误信息: $errorData');
        }
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('发生异常: $e');
      }
    }
  }

  // 保存用户信息到 SharedPreferences
  Future<void> saveUserInfo(Map<String, dynamic> info) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userInfo', jsonEncode(info));
  }
}
