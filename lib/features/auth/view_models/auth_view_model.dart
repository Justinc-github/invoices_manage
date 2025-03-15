import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:management_invoices/shared/view_models/avatar_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:management_invoices/core/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository; // 初始化认证仓库
  final AvatarViewModel _avatarViewModel; // 新增
  AuthViewModel(this._repository, this._avatarViewModel) {
    checkLoginStatus();
  } // 登录弹窗是否显示

  final TextEditingController usernameController =
      TextEditingController(); // 用户名
  final TextEditingController passwordController =
      TextEditingController(); // 密码

  bool _isLoading = false; // 加载状态
  bool get isLoading => _isLoading;

  bool _isLoggedIn = false; // 登录状态
  bool get isLoggedIn => _isLoggedIn;

  String? _errorMessage; // 错误信息
  String? get errorMessage => _errorMessage;

  bool _isDialogShow = true;
  bool get isDialogShow => _isDialogShow;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getString('auth_token') != null;
    debugPrint('登录状态$isLoggedIn'.toString());
    notifyListeners();
  }

  Future<void> login(context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final (success, message) = await _repository.login(
        usernameController.text,
        passwordController.text,
      );
      if (success) {
        _errorMessage = null;

        Navigator.pop(context);
        await clearCredentials();
        _avatarViewModel.avatarUrlGet();
        notifyListeners();
      } else {
        _errorMessage = message;
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }
  }

  // 不允许打开登录弹窗
  Future<void> dialogClose() async {
    _isDialogShow = false;
    debugPrint(_isDialogShow.toString());
  }

  // 允许打开登录弹窗
  Future<void> dialogOpen() async {
    _isDialogShow = true;
    debugPrint(_isDialogShow.toString());
  }

  // 退出登录
  Future<void> logout() async {
    await clearCredentials();
    await dialogOpen();
    await clearAllPreferences();
    await checkLoginStatus();
    notifyListeners();
  }

  // 清除所有保存的登录信息
  Future<void> clearAllPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // 清除所有数据
      await prefs.reload(); // 确保数据立即生效
      debugPrint('所有 SharedPreferences 数据已清除');
    } catch (e) {
      debugPrint('清除失败: $e');
    }
  }

  // 获取用户信息
  static Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('userInfo');
    return jsonString != null ? jsonDecode(jsonString) : null;
  }

  // 清空输入框
  Future<void> clearCredentials() async {
    usernameController.clear();
    passwordController.clear();
  }
}
