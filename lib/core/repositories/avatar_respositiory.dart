import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarRepository {
  static const String _uploadPath = 'http://47.95.171.19/img_upload';
  final _uploadUrl = 'https://www.picgo.net/api/1/upload';
  final Dio dio; // 通过依赖注入 Dio 实例

  AvatarRepository({Dio? dio}) : dio = dio ?? Dio(); // 允许自定义 Dio 实例

  /// 返回头像 URL，失败时返回 null
  Future<String?> uploadAvatarRes(String userId) async {
    try {
      // 选择文件
      final fileResult = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false, // 禁止多选
      );
      if (fileResult == null || fileResult.files.isEmpty) {
        debugPrint('用户取消选择或未选中文件');
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString('avatar').toString();
      }
      final filePath = fileResult.files.single.path;
      if (filePath == null) {
        debugPrint('文件路径无效');
        return null;
      }

      // 创建FormData
      final formData = FormData.fromMap({
        'source': await MultipartFile.fromFile(filePath),
        'key':
            'chv_BoyC_26e5b9a86f444df7731c897fc7031c7e85cd802fb2fd6c32027f3f45b8d7c551482994a1d88529293ce8deabe267f946265a8564d59a77c44b4f8d78c248d016',
        'format': 'json',
        'album_id': 'Sljaq',
      });

      // 发起请求
      final response = await dio.post<String>(
        _uploadUrl,
        data: formData,
        options: Options(sendTimeout: const Duration(seconds: 10)),
      );
      // 处理响应
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.data!) as Map<String, dynamic>;
        var avatarUrl = jsonData['image']['url'] as String?;
        if (avatarUrl != null) {
          // 发起请求
          avatarUrl = await _avatarSave(avatarUrl, userId);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('avatar', avatarUrl);
          return avatarUrl;
        }
      } else if (response.statusCode == 400) {
        return 'error';
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: '上传失败，状态码: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return e.message;
    }
    return null;
  }

  Future<String> _avatarSave(avatarUrl, userId) async {
    try {
      final response = await dio.post<String>(
        _uploadPath,
        data: {'img_url': avatarUrl, 'user_id': userId},
      );
      if (response.statusCode == 200) {
        return avatarUrl;
      }
    } on DioException catch (e) {
      // 处理Dio特有的错误
      if (e.response != null) {
        throw Exception(
          '请求失败，状态码: ${e.response?.statusCode}，错误信息: ${e.response?.data}',
        );
      } else {
        throw Exception('请求失败: ${e.message}');
      }
    }

    return avatarUrl;
  }
}
