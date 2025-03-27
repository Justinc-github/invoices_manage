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

  List<dynamic> _teamInfos = [];
  List<dynamic> get teamInfos => _teamInfos;
  // 在 MembersViewModel 类中添加
  String? _currentUserRole;
  String? get currentUserRole => _currentUserRole;
  String? _currentUserId;
  String? get currentUserId => _currentUserId;

  // 分页相关状态
  int _currentPage = 1;
  int _itemsPerPage = 10;
  int _totalItems = 0;

  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  int get totalItems => _totalItems;
  int get totalPages => (_totalItems / _itemsPerPage).ceil();
  // 分页数据
  List<AuthInfoModel> get paginatedData {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = start + _itemsPerPage;
    return _membersInfos.sublist(
      start.clamp(0, _membersInfos.length),
      end.clamp(0, _membersInfos.length),
    );
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

  // 获取所有成员信息
  Future<void> memberAllInfosGet() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    _membersInfos = [];
    try {
      // 获取所有成员信息
      final allMembers = await _membersRepository.allMumberInfoGet() ?? [];
      // debugPrint('All fetched members: $allMembers');

      final seenIds = <int>{};
      final uniqueMembers = <AuthInfoModel>[];

      for (var member in allMembers) {
        if (!seenIds.contains(member.id)) {
          seenIds.add(member.id!);
          uniqueMembers.add(member);
        }
      }
      _membersInfos = uniqueMembers;
      _totalItems = _membersInfos.length;
      debugPrint('Unique members: $_membersInfos');
    } catch (e) {
      debugPrint('Error fetching team info: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 获取相关队伍成员信息
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
        _totalItems = allMembers.length;
        // 3. 过滤掉在user_ids中的成员
        _membersInfos =
            allMembers.where((member) {
              return !userIdsSet.contains(member.id);
            }).toList();

        debugPrint(_membersInfos.toString());
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

  // 修改队伍信息获取方法
  Future<void> teamSelfMumbersGet() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('user_id'); // 存储当前用户ID

      final userId = prefs.getString('user_id') ?? '';
      final teamIds = await _membersRepository.teamIds(userId);
      _teamInfos = [];
      for (final teamId in teamIds) {
        final response = await _membersRepository.teamSelfMumbers(
          teamId.toString(),
        );
        if (response != null) {
          _teamInfo = TeamInfoModel.fromJson(response);
          final List<dynamic> members = response['members'] ?? [];
          final currentUser = members.firstWhere(
            (member) => member['user_id'].toString() == userId,
            orElse: () => null,
          );
          // 设置当前用户角色
          _currentUserRole = currentUser != null ? currentUser['role'] : null;
          _teamInfos.add(_teamInfo);
          // debugPrint(_teamInfos.toString());
        } else {
          debugPrint('No teams found for the user.');
          _teamInfo = null;
        }
      }
    } catch (e) {
      debugPrint('Error fetching team info: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 修改添加成员方法，接受队伍ID参数
  Future<void> teamSelfMumberAdd(String userId, String teamId) async {
    if (_isLoading) return; // 添加重复请求拦截
    _isLoading = true;
    notifyListeners();

    try {
      await _membersRepository.teamSelfMumberAdd(teamId, userId);
      // 使用单独的await来确保每个操作完成
      await teamSelfMumbersGet();
      await memberInfosGet();
    } catch (e) {
      debugPrint('添加成员失败: $e');
      // 触发错误提示
      // _errorMessage = '添加失败: ${e.toString()}';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMembersNotInTeam(String teamId) async {
    final response = await _membersRepository.allMumberInfoGet();
    if (response != null) {
      final allMembers = response;
      final teamMembersResponse = await _membersRepository.userIds(teamId);
      final List<dynamic> teamMemberIds = teamMembersResponse['user_ids'] ?? [];
      Set<int> teamMemberIdsSet =
          teamMemberIds.map((e) => int.parse(e.toString())).toSet();

      // Filter out members that are already in the team
      _membersInfos =
          allMembers.where((member) {
            return !teamMemberIdsSet.contains(member.id);
          }).toList();
      notifyListeners();
    }
  }

  // 修改删除成员方法，接受队伍ID参数
  Future<void> teamSelfMumberDelete(String userId, String teamId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _membersRepository.teamSelfMumberDelete(teamId, userId);
      // 重新获取队伍信息
      await teamSelfMumbersGet();
    } catch (e) {
      debugPrint('Error deleting team member: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
