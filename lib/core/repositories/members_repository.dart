import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/core/models/auth_info_model.dart';

class MembersRepository {
  MembersRepository({Dio? dio}) : dio = dio ?? Dio();
  final Dio dio;

  static const String _baseUrl = 'http://127.0.0.1:8000';
  static const String _urlAllMumberInfo = 'http://47.95.171.19/users';
  static const String _teamSelfMumbers = '$_baseUrl/teams/';

  /// 获取所有不在同一队伍的成员信息
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
      final response = await dio.get('$_teamSelfMumbers$teamId');
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
    try {
      final response = await dio.post(
        url,
        data: {'user_id': userId},
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
