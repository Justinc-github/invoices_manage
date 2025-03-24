import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/core/models/team_info_model.dart';
import 'package:management_invoices/core/repositories/members_repository.dart';
import 'package:management_invoices/core/models/auth_info_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MembersViewModel extends ChangeNotifier {
  final MembersRepository _membersRepository;
  MembersViewModel(this._membersRepository);

  bool _isLoading = false;
  List<AuthInfoModel> _membersInfos = [];
  TeamInfoModel? _teamInfo;

  List<AuthInfoModel> get membersInfos => _membersInfos;
  bool get isLoading => _isLoading;
  TeamInfoModel? get teamInfo => _teamInfo;

  /// 获取所有成员信息
  Future<void> memberInfosGet() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _membersRepository.allMumberInfoGet();
      final prefs = await SharedPreferences.getInstance();
      final currentTeamId = prefs.getString('team_id') ?? '';
      if (response != null) {
        _membersInfos =
            response.where((member) {
              // debugPrint(member.teamId.toString());
              return member.teamId.toString() != currentTeamId;
            }).toList();
      } else {
        _membersInfos = [];
      }
    } catch (e) {
      debugPrint('Error fetching member info: $e');
      _membersInfos = [];
    } finally {
      _isLoading = false;
      notifyListeners(); // 通知 UI 更新
    }
  }

  /// 获取队伍信息
  Future<void> teamSelfMumbersGet() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final teamId = prefs.getString('team_id') ?? '';
      final response = await _membersRepository.teamSelfMumbers(teamId);
      if (response != null) {
        _teamInfo = TeamInfoModel.fromJson(response);
      }
    } catch (e) {
      debugPrint('Error fetching team info: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 添加队伍成员
  Future<void> teamSelfMumberAdd(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final teamId = prefs.getString('team_id') ?? '';
      await _membersRepository.teamSelfMumberAdd(teamId, userId);
      await teamSelfMumbersGet(); // 刷新队伍信息
    } catch (e) {
      debugPrint('Error adding team member: $e');
    }
  }

  /// 删除队伍成员
  Future<void> teamSelfMumberDelete(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final teamId = prefs.getString('team_id') ?? '';
      await _membersRepository.teamSelfMumberDelete(teamId, userId);
      await teamSelfMumbersGet(); // 刷新队伍信息
    } catch (e) {
      debugPrint('Error deleting team member: $e');
    }
  }
}
