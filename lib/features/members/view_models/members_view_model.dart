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

  Future<void> memberInfosGet() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final userTeamIds = await _membersRepository.teamIds(userId);

      if (userTeamIds.isNotEmpty) {
        // 1. 获取user_ids列表（需要修改userIds方法返回类型）
        final teamUserIdsResponse = await _membersRepository.userIds(
          userTeamIds.first.toString(),
        );

        // 假设userIds方法返回的response.data是Map结构
        final List<dynamic> userIds = teamUserIdsResponse['user_ids'] ?? [];
        Set<int> userIdsSet =
            userIds.map((e) => int.parse(e.toString())).toSet();

        // 2. 获取所有成员信息
        final allMembers = await _membersRepository.allMumberInfoGet() ?? [];

        // 3. 过滤掉在user_ids中的成员
        _membersInfos =
            allMembers.where((member) {
              return !userIdsSet.contains(member.id);
            }).toList();

        // debugPrint(_membersInfos.toString());
      } else {
        debugPrint('No teams found for the user.');
        _teamInfo = null;
      }
    } catch (e) {
      debugPrint('Error fetching team info: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 获取队伍信息
  Future<void> teamSelfMumbersGet() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final teamIds = await _membersRepository.teamIds(userId);
      if (teamIds.isNotEmpty) {
        // 假设只获取第一个队伍的信息
        final response = await _membersRepository.teamSelfMumbers(
          teamIds.first.toString(),
        );
        if (response != null) {
          _teamInfo = TeamInfoModel.fromJson(response);
        }
      } else {
        debugPrint('No teams found for the user.');
        _teamInfo = null;
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
      final userIdCurrent = prefs.getString('user_id').toString();
      final teamIds = await _membersRepository.teamIds(userIdCurrent);
      if (teamIds.isNotEmpty) {
        await _membersRepository.teamSelfMumberAdd(
          teamIds.first.toString(),
          userId,
        );
      } else {
        debugPrint('No teams found for the user.');
        _teamInfo = null;
      }
      await teamSelfMumbersGet(); // 刷新队伍信息
    } catch (e) {
      debugPrint('Error adding team member: $e');
    }
  }

  /// 删除队伍成员
  Future<void> teamSelfMumberDelete(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdCurrent = prefs.getString('user_id').toString();
      final teamIds = await _membersRepository.teamIds(userIdCurrent);
      if (teamIds.isNotEmpty) {
        await _membersRepository.teamSelfMumberDelete(
          teamIds.first.toString(),
          userId,
        );
      } else {
        debugPrint('No teams found for the user.');
        _teamInfo = null;
      }
      await teamSelfMumbersGet(); // 刷新队伍信息
    } catch (e) {
      debugPrint('Error deleting team member: $e');
    }
  }
}
