import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/core/repositories/invoice_repository/invoice_upload_respositiory.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvoiceUploadViewModel extends ChangeNotifier {
  final InvoiceUploadRespositiory _invoiceUploadRespositiory;
  InvoiceUploadViewModel(this._invoiceUploadRespositiory);

  bool _isUploading = false;
  bool _isUploaed = false;
  String? _userInfoString;
  int successCount = 0;

  bool get isUploading => _isUploading;
  bool get isUploaed => _isUploaed;

  // 文件上传方法
  Future<void> uploadInvoice() async {
    try {
      if (_isUploading) return;
      _isUploading = true;

      // 1. 选择多个文件
      final files = await _invoiceUploadRespositiory.pickFiles();
      if (files == null || files.isEmpty) {
        _isUploading = false;
        return;
      }

      // 2. 批量上传

      for (final file in files) {
        try {
          // 上传到OSS
          final prefs = await SharedPreferences.getInstance();
          _userInfoString = prefs.getString('userInfo');
          Map<String, dynamic> userInfo = jsonDecode(_userInfoString!);
          final userId = await userInfo['user_id'];

          final imageUrl = await _invoiceUploadRespositiory.uploadToOSS(
            file,
            userId,
          );

          // 提交到服务器
          await _invoiceUploadRespositiory.submitInvoiceInfo(imageUrl, userId);
          successCount++;
        } catch (e) {
          debugPrint('文件 ${file.path} 上传失败: $e');
        }
      }
      _isUploaed = true;
      notifyListeners();
    } catch (e) {
      debugPrint('上传失败: $e');
    } finally {
      _isUploading = false;
    }
  }

  // 重置上传状态
  void resetUploadStatus() {
    _isUploaed = false;
    notifyListeners();
  }
}
