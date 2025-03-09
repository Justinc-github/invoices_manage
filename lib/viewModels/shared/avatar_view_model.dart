import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/models/repositories/avatar_repositiory.dart';

class AvatarViewModel extends ChangeNotifier {
  final AvatarRepository _avatarRepository;
  String? _avatarUser;
  String? _error;
  bool _isLoading = false; // 新增加载状态
  AvatarViewModel(this._avatarRepository);

  String? get avatarUser => _avatarUser;
  String? get error => _error;
  bool get isLoading => _isLoading; // 暴露加载状态

  Future<void> uploadAvatar() async {
    _error = null; // 重置错误状态
    _isLoading = true; // 开始加载
    notifyListeners();
    try {
      // 调用封装的上传用户头像的api
      _avatarUser = await _avatarRepository.uploadAvatar('1');
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
