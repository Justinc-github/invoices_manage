import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:management_invoices/core/repositories/avatar_respositiory.dart';

import 'package:management_invoices/core/config/shared_preferences.dart';

class AvatarViewModel extends ChangeNotifier {
  final AppPreferences _prefs = AppPreferences();
  final AvatarRepository _avatarRepository;
  AvatarViewModel(this._avatarRepository) {
    _prefs.avatarNotifier.addListener(_handleAvatarChange);
    avatarUrlGet(); // 自动加载头像
  }

  String? _avatarUser;
  String? _error;
  String? _message;
  bool _isLoading = false; // 新增加载状态

  String? get avatarUser => _avatarUser;
  String? get error => _error;
  bool get isLoading => _isLoading; // 暴露加载状态

  Future<void> avatarUrlGet() async {
    final prefs = await SharedPreferences.getInstance();
    _avatarUser = prefs.getString('avatar');
    // debugPrint(_avatarUser);
    notifyListeners(); // 通知 UI 更新
  }

  void _handleAvatarChange() {
    _avatarUser = _prefs.avatarNotifier.value;
    notifyListeners();
  }

  Future<void> uploadAvatar() async {
    _error = null; // 重置错误状态
    _isLoading = true; // 开始加载
    notifyListeners();
    try {
      // 调用封装的上传用户头像的api
      final prefs = await SharedPreferences.getInstance();
      _message = await _avatarRepository.uploadAvatarRes(
        prefs.getString('user_id').toString(),
      );
      if (_message == 'error') {
        _error = '头像上传失败，该头像已被使用';
      } else {
        _avatarUser = _message;
      }

      debugPrint(_avatarUser);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false; // 结束加载
      notifyListeners();
    }
  }

  void errorClose() {
    _error = null;
    notifyListeners();
  }
}
