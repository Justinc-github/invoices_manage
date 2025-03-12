import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class InvoiceUploadRespositiory {
  final Dio _dio = Dio();

  // 阿里云 OSS 配置
  final String accessKeyId = 'LTAI5t7H5UivbuturndhsXSL';
  final String accessKeySecret = 'oqnASV1WIzmm7bhFQWPR8RR6AZoMCd';
  final String endpoint =
      'oss-cn-beijing.aliyuncs.com'; // 例如 oss-cn-beijing.aliyuncs.com
  final String bucketName = 'admin-invoice-oss';

  // 初始化配置
  void init() {
    // 配置 Dio
    _dio.options.connectTimeout = Duration(seconds: 5); // 设置连接超时
    _dio.options.receiveTimeout = Duration(seconds: 5); // 请求超时
  }

  // 文件选择方法
  Future<List<File>?> pickFiles() async {
    // 方法名改为复数
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true, // 关键参数：允许选择多个
    );
    if (result == null || result.files.isEmpty) return null;
    debugPrint(result.toString());
    // 过滤掉可能为空的路径
    return result.files
        .where((file) => file.path != null)
        .map((file) => File(file.path!))
        .toList();
  }

  // OSS上传
  Future<String> uploadToOSS(File file, int userId) async {
    await uploadImage(file, userId);
    return 'https://admin-invoice-oss.oss-cn-beijing.aliyuncs.com/invoice/'
        '$userId/${file.uri.pathSegments.last}';
  }

  // 上传图片到阿里云 OSS
  Future<void> uploadImage(File imageFile, int userId) async {
    try {
      final fileName =
          'invoice/$userId/${imageFile.uri.pathSegments.last}'; // 上传时的文件路径
      final formData = FormData.fromMap({
        'key': fileName, // 在 OSS 中存储的文件名
        'file': await MultipartFile.fromFile(imageFile.path),
      });

      final url = 'https://$bucketName.$endpoint';

      final response = await _dio.post(url, data: formData);

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (kDebugMode) {
          print("文件上传成功: ${response.data}");
        }
      } else {
        if (kDebugMode) {
          print("上传失败: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("上传图片时发生错误: $e");
      }
    }
  }

  // 提交到后端使用Dio
  Future<void> submitInvoiceInfo(String imageUrl, int userId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
        'http://47.95.171.19/admin_invoice/invoice_info',
        options: Options(headers: {"Content-Type": "application/json"}),
        data: {'image_url': imageUrl, 'user_id': userId.toString()},
      );

      if (response.statusCode != 200) {
        throw Exception('服务器返回错误: ${response.data}');
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
    } catch (e) {
      throw Exception('未知错误: $e');
    }
  }
}
