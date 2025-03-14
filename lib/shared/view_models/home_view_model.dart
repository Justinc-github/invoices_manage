import 'package:fluent_ui/fluent_ui.dart';

import 'package:window_manager/window_manager.dart';

class HomeViewModel with ChangeNotifier, WindowListener {
  HomeViewModel() {
    windowManager.addListener(this);
  }

  int _selectedIndex = 0; // 当前页面
  bool _isClosing = false; // 是否关闭

  // 状态暴露
  int get selectedIndex => _selectedIndex;
  bool get isClosing => _isClosing;

  // 更新索引导航
  void updateSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
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
    if (_isClosing) notifyListeners(); // 只有需要关闭时才通知
  }
}
