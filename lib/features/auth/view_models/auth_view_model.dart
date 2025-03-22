import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:management_invoices/features/auth/views/login_view.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:management_invoices/core/repositories/auth_repository.dart';

import 'package:management_invoices/shared/view_models/avatar_view_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository; // 初始化认证仓库
  final AvatarViewModel _avatarViewModel; // 新增

  AuthViewModel(this._repository, this._avatarViewModel) {
    checkLoginStatus();
  }

  // 注册相关控制器
  final TextEditingController usernameController =
      TextEditingController(); // 用户名
  final TextEditingController passwordController =
      TextEditingController(); // 密码

  final TextEditingController emailController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController codeController = TextEditingController();

  int registerStep = 1; // 1-邮箱验证 2-设置账户
  bool _isCodeSent = false;
  String? _code;
  int _countdown = 60;
  Timer? _timer;

  bool get isCodeSent => _isCodeSent;
  int get countdown => _countdown;

  bool _isLoginForm = true; // 当前是否显示登录表单
  bool get isLoginForm => _isLoginForm;

  bool _isLoading = false; // 加载状态
  bool get isLoading => _isLoading;

  bool _isLoggedIn = false; // 登录状态
  bool get isLoggedIn => _isLoggedIn;

  String? _errorMessage; // 错误信息
  String? get errorMessage => _errorMessage;

  bool _isDialogShow = true;
  bool get isDialogShow => _isDialogShow;

  String? _retrieveUsername;
  String? get retrieveUsername => _retrieveUsername;

  bool _isUsernameValid = false;
  bool get isUsernameValid => _isUsernameValid;
  set isUsernameValid(bool value) {
    _isUsernameValid = value;
    notifyListeners();
  }

  bool _isPasswordValid = false;
  bool get isPasswordValid => _isPasswordValid;
  set isPasswordValid(bool value) {
    _isPasswordValid = value;
    notifyListeners();
  }

  bool _isConfirmPasswordValid = false;
  bool get isConfirmPasswordValid => _isConfirmPasswordValid;
  set isConfirmPasswordValid(bool value) {
    _isConfirmPasswordValid = value;
    notifyListeners();
  }

  bool _isLoginUsernameValid = false;
  bool get isLoginUsernameValid => _isLoginUsernameValid;
  set isLoginUsernameValid(bool value) {
    _isLoginUsernameValid = value;
    notifyListeners(); // 关键：触发界面更新
  }

  bool _isLoginPasswordValid = false;
  bool get isLoginPasswordValid => _isLoginPasswordValid;
  set isLoginPasswordValid(bool value) {
    _isLoginPasswordValid = value;
    notifyListeners(); // 关键：触发界面更新
  }

  bool _isEmailValid = false;
  bool get isEmailValid => _isEmailValid;
  set isEmailValid(bool value) {
    _isEmailValid = value;
    notifyListeners();
  }

  bool _isCodeValid = false;
  bool get isCodeValid => _isCodeValid;
  set isCodeValid(bool value) {
    _isCodeValid = value;
    notifyListeners();
  }

  // 找回密码相关状态
  int _retrieveStep = 1; // 1-邮箱验证 2-设置密码
  int get retrieveStep => _retrieveStep;

  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();

  bool _isNewPasswordValid = false;
  bool get isNewPasswordValid => _isNewPasswordValid;
  set isNewPasswordValid(bool value) {
    _isNewPasswordValid = value;
    notifyListeners();
  }

  bool _isConfirmNewPasswordValid = false;
  bool get isConfirmNewPasswordValid => _isConfirmNewPasswordValid;
  set isConfirmNewPasswordValid(bool value) {
    _isConfirmNewPasswordValid = value;
    notifyListeners();
  }

  // 找回密码方法
  Future<void> sendPasswordResetCode() async {
    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(emailController.text)) {
      _errorMessage = "请输入有效的邮箱地址";
      notifyListeners();
      return;
    }

    try {
      _isCodeSent = true;
      notifyListeners();
      _code = await _repository.sendPasswordResetCode(emailController.text);
      _startCountdown();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> resetPassword(BuildContext context) async {
    if (newPasswordController.text != confirmNewPasswordController.text) {
      _errorMessage = "两次输入的密码不一致";
      notifyListeners();
      return;
    }

    try {
      final (success, message) = await _repository.resetPassword(
        emailController.text,
        codeController.text,
        newPasswordController.text,
      );
      if (success) {
        // 新增：将找回的用户名赋给控制器
        _retrieveUsername = message;
        Navigator.pop(context);
        showDialog(
          context: context,
          barrierDismissible: false, // 阻止点击外部关闭
          builder: (context) => const LoginDialog(),
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void verifyCodeRetrieveCode(BuildContext context) {
    debugPrint(_code);
    if (codeController.text != _code) {
      _errorMessage = "验证码错误，请重新输入";
      notifyListeners();
      return;
    }

    _retrieveStep = 2;
    _errorMessage = null;
    notifyListeners();
  }

  void resetRetrieveProcess() {
    _retrieveStep = 1;
    emailController.clear();
    codeController.clear();
    newPasswordController.clear();
    confirmNewPasswordController.clear();
    _isCodeSent = false;
    _countdown = 60;
    _timer?.cancel();
    _errorMessage = null;
    notifyListeners();
  }

  // 更新倒计时逻辑
  void _startCountdown() {
    _countdown = 60;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        _countdown--;
      } else {
        _timer?.cancel();
        _isCodeSent = false;
      }
      notifyListeners();
    });
  }

  // 清空登录字段和状态
  void resetLoginFields() {
    usernameController.clear();
    passwordController.clear();
    isLoginUsernameValid = false;
    isLoginPasswordValid = false;
    notifyListeners();
  }

  // 设置错误信息的公共方法
  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // 清除错误信息的方法
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // 发送验证码
  Future<void> sendVerificationCode() async {
    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(emailController.text)) {
      _errorMessage = "请输入有效的邮箱地址";
      notifyListeners();
      return;
    }
    _isCodeSent = true;
    notifyListeners();
    try {
      _code = await _repository.sendCode(emailController.text.toString());
      _startCountdown();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      debugPrint("发生错误$e");
    }
  }

  // 验证验证码
  Future<void> verifyCode(BuildContext context) async {
    debugPrint(_code);
    if (codeController.text != _code) {
      _errorMessage = "验证码错误，请重新输入";
      notifyListeners();
      return;
    }

    registerStep = 2;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getString('auth_token') != null;
    debugPrint('登录状态$isLoggedIn'.toString());
    notifyListeners();
  }

  Future<void> resetRegistration() async {
    registerStep = 1; // 重置到第一步
    _isCodeSent = false; // 重置验证码状态
    _countdown = 60; // 重置倒计时
    _timer?.cancel(); // 取消定时器
    codeController.clear(); // 清空验证码输入
    _errorMessage = null; // 清除错误信息
    _isUsernameValid = false;
    _isPasswordValid = false;
    _isConfirmPasswordValid = false;
    _isEmailValid = false;
    _isCodeValid = false;
    notifyListeners(); // 通知界面更新
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

  // 切换表单
  void toggleForm() {
    _isLoginForm = !_isLoginForm;
    clearCredentials();
    _errorMessage = null;
    notifyListeners();
  }

  // 注册方法
  Future<void> register(context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final (success, message) = await _repository.register(
        usernameController.text,
        emailController.text,
        passwordController.text,
        codeController.text,
      );

      if (success) {
        _errorMessage = message;
        // 注册成功或用户已存在后自动登录
        Navigator.pop(context); // 关闭对话框
        showDialog(context: context, builder: (context) => const LoginDialog());
      } else if (message == '用户名或邮箱已存在，请登录') {
        _errorMessage = message;
        Navigator.pop(context); // 关闭对话框
        showDialog(context: context, builder: (_) => const LoginDialog());
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    emailController.clear();
    confirmPasswordController.clear();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
