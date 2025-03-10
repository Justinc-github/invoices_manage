import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/models/repositories/auth_respositiory.dart';
import 'package:window_manager/window_manager.dart';

class HomeViewModel with ChangeNotifier, WindowListener {
  final AuthRespositiory _authRespositiory;
  HomeViewModel(this._authRespositiory) {
    windowManager.addListener(this);
    _checkLoginStatus();
  }

  int _selectedIndex = 0; // 当前页面
  bool _isClosing = false; // 是否关闭
  bool _isLoggedIn = false; // 登录状态
  bool _isLoggingIn = false; // 是否正在登录
  bool _isCloseLoginDialog = false; // 是否关闭显示登录弹窗
  String? _loginError; // 登录的错误
  VoidCallback? onLoginSuccess; // 新增回调

  // 用户登录输入的账号密码
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 状态暴露
  int get selectedIndex => _selectedIndex;
  bool get isClosing => _isClosing;
  bool get isCloseLoginDialog => _isCloseLoginDialog;
  bool get isLoggingIn => _isLoggingIn;
  String? get loginError => _loginError;
  TextEditingController get usernameController => _usernameController;
  TextEditingController get passwordController => _passwordController;

  // 更新索引导航
  void updateSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // 登录处理方法（含延时）
  Future<void> handleLogin() async {
    _isLoggingIn = true;
    _loginError = null;
    notifyListeners();

    try {
      // 使用真实输入值（示例）
      await _authRespositiory.login(
        _usernameController.text,
        _passwordController.text,
      );
      await handleLoginSuccess();
    } catch (e) {
      _loginError = '登录失败: ${e.toString()}';
    } finally {
      _isLoggingIn = false; // 确保状态重置
      notifyListeners();
    }
  }

  // 检查登录状态
  Future<void> _checkLoginStatus() async {
    if (!_isLoggedIn) {
      _isCloseLoginDialog = false;
      notifyListeners();
    } else {
      _isCloseLoginDialog = true;
      notifyListeners();
    }
  }

  // 关闭登录弹窗
  void hideLoginDialog() {
    _isCloseLoginDialog = true;
    debugPrint(_isCloseLoginDialog.toString());
    notifyListeners();
  }

  // 处理登录成功
  Future<void> handleLoginSuccess() async {
    _isLoggedIn = true;
    hideLoginDialog();
    if (onLoginSuccess != null) {
      onLoginSuccess!(); // 触发回调
    }
  }

  // 关闭窗口
  Future<void> confirmClose(BuildContext context, bool shouldClose) async {
    if (shouldClose) {
      await windowManager.hide(); // 立即隐藏窗口
      await windowManager.destroy(); // 关闭窗口并释放资源
    } else {
      _isClosing = false;
      Navigator.pop(context);
      notifyListeners();
    }
  }

  // 修改关闭弹窗的状态
  @override
  void onWindowClose() async {
    _isClosing = await windowManager.isPreventClose();
    notifyListeners();
  }

  // 清理资源
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
