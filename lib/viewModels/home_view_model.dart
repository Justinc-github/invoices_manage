import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/models/repositories/auth_respositiory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class HomeViewModel with ChangeNotifier, WindowListener {
  final AuthRespositiory _authRespositiory;
  HomeViewModel(this._authRespositiory) {
    windowManager.addListener(this);
    checkLoginStatus().then((_) {
      notifyListeners();
    });
  }

  int _selectedIndex = 0; // 当前页面
  bool _isClosing = false; // 是否关闭
  bool _isLoggingIn = false; // 是否正在登录
  bool _isCloseLoginDialog = false; // 是否显示登录弹窗
  String? _loginError; // 登录的错误

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
  Future<String> handleLogin(context, dialogcontext) async {
    _isLoggingIn = true;
    _loginError = null;
    notifyListeners();
    try {
      await _authRespositiory.login(
        _usernameController.text,
        _passwordController.text,
      );
      notifyListeners();
      Navigator.of(context).pop(); // 关闭弹窗
      Navigator.of(dialogcontext).pop(); // 关闭登录中弹窗
      return '登录成功';
    } catch (e) {
      _loginError = '登录失败: ${e.toString()}';

      notifyListeners();
      return _loginError.toString();
    } finally {
      _isLoggingIn = false;
      checkLoginStatus();
      notifyListeners();
    }
  }

  // 将 _checkLoginStatus 改为公共方法
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isCloseLoginDialog = (prefs.getString('userInfo') == null); // 直接赋值布尔值
    notifyListeners(); // 确保通知监听者
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
