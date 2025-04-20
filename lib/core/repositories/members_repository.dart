import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/core/models/auth_info_model.dart';
import 'package:management_invoices/core/models/team_info_model.dart';

class MembersRepository {
  MembersRepository({Dio? dio}) : dio = dio ?? Dio();
  final Dio dio;

  static const String _baseUrl = 'http://47.95.171.19';
  static const String _urlAllMumberInfo = 'http://47.95.171.19/users';
  static const String _teamSelfMumbers = '$_baseUrl/teams';
  static const String _teamIds = '$_baseUrl/teams/user/';
  static const String _userIds = '$_baseUrl/teams/members/team/';
  static const String _team = '$_baseUrl/team';

  // 获取队伍的 user_ids
  Future<Map<String, dynamic>> userIds(String userId) async {
    // 修改返回类型
    try {
      final response = await dio.get('$_userIds$userId');
      if (response.statusCode == 200) {
        // debugPrint(response.data.toString());
        return response.data; // 返回原始数据
      }
      return {};
    } on DioException catch (e) {
      debugPrint('Error fetching team ids: ${e.message}');
      return {};
    }
  }

  // 获取所有队伍信息
  Future<List<Team>> teamSelfMumbersGet() async {
    try {
      final response = await dio.get(_teamSelfMumbers);
      // debugPrint('获取队伍成员: ${response.data}');
      return (response.data as List)
          .map((teamJson) => Team.fromJson(teamJson as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('获取队伍成员失败: ${e.message}');
      return [];
    }
  }

  // 创建新的队伍
  Future<void> teamCreate(String userId, String teamName) async {
    try {
      await dio.post(_team, data: {'headman_id': userId, 'name': teamName});

      debugPrint('队伍创建成功');
    } on DioException catch (e) {
      debugPrint('队伍创建失败: ${e.message}');
    }
  }

  // 删除队伍
  Future<void> teamDelete(String teamId) async {
    try {
      await dio.delete('$_team/$teamId');

      debugPrint('队伍删除成功');
    } on DioException catch (e) {
      debugPrint('队伍删除成功: ${e.message}');
    }
  }

  // 编辑队伍
  Future<void> teamUpload(String teamId, String teamName) async {
    try {
      await dio.put('$_team/$teamId', data: {'name': teamName});

      debugPrint('队伍编辑成功');
    } on DioException catch (e) {
      debugPrint('队伍编辑成功: ${e.message}');
    }
  }

  Future<List<int>> teamIds(String userId) async {
    try {
      final response = await dio.get('$_teamIds$userId');
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        // 从返回的数据中提取 team_ids 列表
        return List<int>.from(data['team_ids'] ?? []);
      }
      return [];
    } on DioException catch (e) {
      debugPrint('Error fetching team ids: ${e.message}');
      return [];
    }
  }

  // 获取所有所有成员信息
  Future<List<AuthInfoModel>?> allMumberInfoGet() async {
    try {
      final response = await dio.get(_urlAllMumberInfo);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => AuthInfoModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('Error fetching all members: ${e.message}');
      return [];
    }
  }

  /// 获取队伍信息
  Future<Map<String, dynamic>?> teamSelfMumbers(String teamId) async {
    try {
      final response = await dio.get('$_teamSelfMumbers/$teamId');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      debugPrint('Error fetching team members: ${e.message}');
      return null;
    }
  }

  /// 添加队伍成员
  Future<void> teamSelfMumberAdd(String teamId, String userId) async {
    final url = '$_baseUrl/teams/$teamId/members';
    debugPrint('Adding member to team: $url');
    try {
      final response = await dio.post(
        url,
        data: {'user_id': userId, 'role': '队员'},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200) {
        debugPrint('Member added successfully');
      }
    } on DioException catch (e) {
      debugPrint('Error adding team member: ${e.message}');
    }
  }

  /// 删除队伍成员
  Future<void> teamSelfMumberDelete(String teamId, String userId) async {
    final url = '$_baseUrl/teams/$teamId/members/$userId';
    try {
      final response = await dio.delete(url);
      if (response.statusCode == 200) {
        debugPrint('Member deleted successfully');
      }
    } on DioException catch (e) {
      debugPrint('Error deleting team member: ${e.message}');
    }
  }
}
