import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class InvoiceUploadRespositiory {
  final Dio _dio = Dio();

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
    // 过滤掉可能为空的路径
    return result.files
        .where((file) => file.path != null)
        .map((file) => File(file.path!))
        .toList();
  }

  // OSS上传
  Future<String> uploadToOSS(File file, int userId) async {
    await uploadImage(file, userId);
    return 'https://fapiao.s3.bitiful.net/images/$userId/${file.uri.pathSegments.last}';
  }

  // 上传图片到缤纷云
  Future<void> uploadImage(File imageFile, int userId) async {
    try {
      final fileName = '$userId/${imageFile.uri.pathSegments.last}'; // 上传时的文件路径
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });
      final url = 'http://127.0.0.1:8000/upload';
      await _dio.post(url, data: formData);
    } catch (e) {
      if (kDebugMode) {
        print("上传图片时发生错误: $e");
      }
    }
  }

  // 提交到后端使用Dio
  Future<String?> submitInvoiceInfo(String imageUrl, int userId) async {
    final dio = Dio();
    try {
      final response = await dio.post(
        'http://127.0.0.1:8000/admin_invoice/invoice_info',
        options: Options(headers: {"Content-Type": "application/json"}),
        data: {'image_url': imageUrl, 'user_id': userId.toString()},
      );
      debugPrint(response.statusCode.toString());
      debugPrint(response.data['message'].toString());

      if (response.statusCode == 200) {
        return response.data['message'];
      }
    } catch (e) {
      throw Exception('未知错误: $e');
    }
    return null;
  }
}
