import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path; // 新增路径处理

class InvoiceUploadRepository {
  // 类名拼写修正
  final Dio _dio = Dio();

  void init() {
    _dio.options.connectTimeout = Duration(seconds: 5);
    _dio.options.receiveTimeout = Duration(seconds: 5);
    // 添加请求日志拦截器
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  Future<List<File>?> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    return result?.files
        .where((file) => file.path?.isNotEmpty ?? false)
        .map((file) => File(file.path!))
        .toList();
  }

  Future<String> uploadToOSS(File file, int userId) async {
    final fileName = path.basename(file.path); // 使用 path 包获取正确文件名
    await uploadImage(file, userId);
    return 'https://fapiao.s3.bitiful.net/images/$userId/$fileName'; // 修正路径拼接
  }

  Future<void> uploadImage(File imageFile, int userId) async {
    try {
      final fileName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}'; // 添加时间戳防止重复
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });
      await _dio.post('http://127.0.0.1:8000/upload', data: formData);
    } on DioException catch (e) {
      // 明确捕获 Dio 异常
      throw Exception('上传到服务器失败: ${e.response?.data ?? e.message}');
    }
  }

  Future<String> submitInvoiceInfo(String imageUrl, int userId) async {
    try {
      final response = await _dio.post(
        'http://127.0.0.1:8000/admin_invoice/invoice_info',
        data: {'image_url': imageUrl, 'user_id': userId},
      );

      if (response.statusCode != 200) {
        // 处理非200状态码
        throw Exception('服务器返回错误: ${response.data}');
      }
      return response.data['message'] as String;
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    }
  }
}
