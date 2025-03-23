import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:management_invoices/core/models/auth_info_model.dart';

class MembersRepository {
  MembersRepository({Dio? dio}) : dio = dio ?? Dio(); // 允许自定义 Dio 实例
  final Dio dio; // 通过依赖注入 Dio 实例
  List<AuthInfoModel> allMumberInfo = <AuthInfoModel>[];

  static const String _urlAllMumberInfo = 'http://47.95.171.19/users';
  static const String _teamSelfMumbers = 'http://127.0.0.1:8000/teams/';
  Future<List<AuthInfoModel>?> allMumberInfoGet() async {
    try {
      final response = await dio.get(_urlAllMumberInfo);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => AuthInfoModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('Error fetching invoices: ${e.message}');
      return [];
    }
  }

  Future<Map<String, dynamic>?> teamSelfMumbers(String teamId) async {
    try {
      final response = await dio.get(_teamSelfMumbers + teamId);
      if (response.statusCode == 200) {
        // print(response.data);
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      debugPrint(e.message);
      return null;
    }
  }
}
