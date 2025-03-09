import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:file_picker/file_picker.dart';

class AvatarRepository {
  static const String _baseUrl = 'http://47.95.171.19';
  static const String _uploadPath = '/img_upload'; // 路径常量提取
  final Dio dio; // 通过依赖注入 Dio 实例

  AvatarRepository({Dio? dio}) : dio = dio ?? Dio(); // 允许自定义 Dio 实例

  /// 上传用户头像并返回图片 URL
  ///
  /// [userId] 用户唯一标识符
  /// 返回头像 URL，失败时返回 null
  Future<String?> uploadAvatar(String userId) async {
    try {
      // 1. 构建完整的请求 URL（避免字符串拼接错误）
      final uploadUrl =
          Uri.parse(
            '$_baseUrl$_uploadPath',
          ).replace(queryParameters: {'user_id': userId}).toString();

      // 2. 选择文件（添加更安全的空检查）
      final fileResult = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false, // 明确禁止多选
      );

      if (fileResult == null || fileResult.files.isEmpty) {
        debugPrint('用户取消选择或未选中文件');
        return null;
      }

      final filePath = fileResult.files.single.path;
      if (filePath == null) {
        debugPrint('文件路径无效');
        return null;
      }

      // 3. 创建 FormData
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      // 4. 发起请求（添加超时和内容类型）
      final response = await dio.post<String>(
        uploadUrl,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      // 5. 处理响应（使用更安全的 JSON 解析）
      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: '上传失败，状态码: ${response.statusCode}',
        );
      }

      final jsonData = jsonDecode(response.data!) as Map<String, dynamic>;
      final avatarUrl = jsonData['img_url'] as String?;
      return avatarUrl;
    } on DioException catch (e) {
      // 捕获 Dio 特定错误
      debugPrint('头像上传失败: ${e.message}');
      return null;
    }
  }
}
