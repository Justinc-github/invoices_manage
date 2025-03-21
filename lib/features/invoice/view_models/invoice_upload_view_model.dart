import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:management_invoices/core/repositories/invoice_repository/invoice_upload_respositiory.dart';

class InvoiceUploadViewModel extends ChangeNotifier {
  final InvoiceUploadRepository _invoiceUploadRepository;
  InvoiceUploadViewModel(this._invoiceUploadRepository);

  bool _isUploading = false;
  bool _isUploaded = false;
  final List<String> _messages = [];
  int successCount = 0;

  bool get isUploading => _isUploading;
  bool get isUploaded => _isUploaded;
  List<String> get messages => _messages;

  Future<void> uploadInvoice() async {
    try {
      if (_isUploading) return;
      _isUploading = true;
      notifyListeners();
      final files = await _invoiceUploadRepository.pickFiles();
      if (files == null || files.isEmpty) {
        _isUploading = false;
        notifyListeners();
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      final userInfo = jsonDecode(prefs.getString('userInfo')!);
      final userId = userInfo['user_id'] as int; // 明确类型转换
      final tempMessages = <String>[];
      for (final file in files) {
        try {
          final imageUrl = await _invoiceUploadRepository.uploadToOSS(
            file,
            userId,
          );
          final result = await _invoiceUploadRepository.submitInvoiceInfo(
            imageUrl,
            userId,
          );
          tempMessages.add('✅ ${path.basename(file.path)} 上传成功: $result');
          successCount++;
        } catch (e) {
          debugPrint(_getErrorMessage(e));
          tempMessages.add(
            '❌ ${path.basename(file.path)} 上传失败: 发票已存在',
          ); // 显示具体错误
        }
        notifyListeners();
      }
      _messages.addAll(tempMessages);
      _isUploaded = true;
    } catch (e) {
      _messages.add('🚨 系统错误: ${_getErrorMessage(e)}');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  String _getErrorMessage(dynamic e) {
    if (e is DioException) {
      return e.response?.data?['error'] ?? e.message ?? '未知网络错误';
    }
    return e.toString().replaceAll('Exception: ', ''); // 去除冗余信息
  }

  void resetUploadStatus() {
    _isUploaded = false;
    _messages.clear();
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
