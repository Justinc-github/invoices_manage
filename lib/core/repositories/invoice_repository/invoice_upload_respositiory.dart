import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';

class InvoiceUploadRepository {
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

  Future<Response> submitHandInvoiceInfo(
    Map<String, dynamic> invoiceData,
    int userId,
  ) async {
    try {
      final String url =
          'http://47.95.171.19/admin_invoice/invoice_hand_info?userId=$userId';
      final response = await _dio.post(
        url,
        data: invoiceData, // 直接发送发票数据，不再嵌套
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );
      return response;
    } catch (e) {
      throw Exception('网络请求失败: ${e.toString()}');
    }
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

  Future<List<File>?> pickPDFFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    return result?.files
        .where((file) => file.path?.isNotEmpty ?? false)
        .map((file) => File(file.path!))
        .toList();
  }

  Future<String> uploadToOSS(File file, int userId) async {
    final fileName = path.basename(file.path); // 获取正确文件名
    final encodedinvoiceUrl = Uri.encodeComponent(fileName); // 文件编码
    await uploadFile(file, userId, 'images');

    return 'https://fapiao-1355161607.cos.ap-beijing.myqcloud.com/images/$userId/$encodedinvoiceUrl'; // 路径拼接
  }

  Future<String> uploadPDFToOSS(File file, int userId) async {
    final fileName = path.basename(file.path); // 获取正确文件名
    final encodedinvoiceUrl = Uri.encodeComponent(fileName); // 新增编码步骤
    await uploadFile(file, userId, 'PDF');

    return 'https://fapiao-1355161607.cos.ap-beijing.myqcloud.com/PDF/$userId/$encodedinvoiceUrl'; // 路径拼接
  }

  Future<void> uploadFile(File imageFile, int userId, String type) async {
    try {
      final fileName = path.basename(imageFile.path); // 获取正确文件名
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });
      await _dio.post(
        'http://47.95.171.19/upload?user_id=$userId&type=$type',
        data: formData,
      );
    } on DioException catch (e) {
      // 明确捕获 Dio 异常
      throw Exception('上传到服务器失败: ${e.response?.data ?? e.message}');
    }
  }

  Future<String> submitInvoiceInfo(String imageUrl, int userId) async {
    try {
      final response = await _dio.post(
        'http://47.95.171.19/admin_invoice/invoice_info',
        data: {'image_url': imageUrl, 'user_id': userId.toString()},
      );

      if (response.statusCode != 200) {
        throw Exception('服务器返回错误: ${response.data}');
      }
      return response.data['message'] as String;
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    }
  }

  Future<String> submitPDFInvoiceInfo(File file, int userId) async {
    try {
      final fileName = path.basename(file.path); // 获取正确文件名
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      await uploadPDFToOSS(file, userId); // 上传文件到OSS
      final response = await _dio.post(
        'http://47.95.171.19/admin_invoice/invoice_file?user_id=$userId',
        data: formData,
      );

      if (response.statusCode != 200) {
        throw Exception('服务器返回错误: ${response.data}');
      }
      return response.data['message'] as String;
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    }
  }
}
