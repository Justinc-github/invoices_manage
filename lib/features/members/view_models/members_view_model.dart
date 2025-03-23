import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/core/models/team_info_model.dart';

import 'package:management_invoices/core/repositories/members_repository.dart';
import 'package:management_invoices/core/models/auth_info_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MembersViewModel extends ChangeNotifier {
  final MembersRepository _membersRepository;
  MembersViewModel(this._membersRepository);

  bool _isLoading = false; // 加载状态
  // 分页相关状态
  List<AuthInfoModel> _membersInfos = [];
  int _currentPage = 1;
  int _itemsPerPage = 10;
  int _totalItems = 0;

  List<AuthInfoModel> get membersInfos => _membersInfos;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  int get totalItems => _totalItems;
  int get totalPages => (_totalItems / _itemsPerPage).ceil();

  TeamInfoModel? _teamInfo;
  TeamInfoModel? get teamInfo => _teamInfo;
  // 分页数据
  List<AuthInfoModel> get paginatedData {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = start + _itemsPerPage;
    return _membersInfos.sublist(
      start.clamp(0, _membersInfos.length),
      end.clamp(0, _membersInfos.length),
    );
  }

  Future<void> memberInfosGet() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final result = await _membersRepository.allMumberInfoGet();

      _membersInfos = result ?? [];
      _totalItems = _membersInfos.length;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching invoices: $e');
      _membersInfos = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> teamSelfMumbersGet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id').toString();
      final response = await _membersRepository.teamSelfMumbers(userId);
      if (response != null) {
        _teamInfo = TeamInfoModel.fromJson(response);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching team info: $e');
      notifyListeners();
    }
  }

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void setItemsPerPage(int size) {
    _itemsPerPage = size;
    _currentPage = 1;
    notifyListeners();
  }

  void clearInvoiceData() {
    _membersInfos = [];
    _isLoading = false;
  }
}
