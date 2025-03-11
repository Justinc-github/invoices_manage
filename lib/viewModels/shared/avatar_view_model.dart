import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/models/repositories/avatar_respositiory.dart';
import 'package:management_invoices/viewModels/home_view_model.dart';
import 'package:management_invoices/viewModels/invoice_self_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarViewModel extends ChangeNotifier {
  final AvatarRepository _avatarRepository;
  AvatarViewModel(this._avatarRepository);
  String? _avatarUser;
  String? _error;
  bool _isLoading = false; // 新增加载状态

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

  // 退出登录
  Future<void> toggleLoginStatus(BuildContext context) async {
    try {
      await clearUserInfo();
      // 获取并清除发票数据
      final invoiceSelfVM = Provider.of<InvoiceSelfViewModel>(
        context,
        listen: false,
      );
      invoiceSelfVM.clearInvoiceData();
      final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
      homeViewModel.updateSelectedIndex(0);
      await homeViewModel.checkLoginStatus();
    } catch (e) {
      debugPrint('退出登录错误: $e');
    }
  }

  // 清楚用户登录信息
  Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    // debugPrint(prefs.getString('userInfo'));
    await prefs.remove('userInfo');
  }

  void errorClose() {
    _error = null;
    notifyListeners();
  }
}
