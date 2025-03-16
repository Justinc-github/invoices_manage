import 'dart:convert';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/core/repositories/invoice_repository/invoice_upload_respositiory.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class InvoiceUploadViewModel extends ChangeNotifier {
  final InvoiceUploadRespositiory _invoiceUploadRespositiory;
  InvoiceUploadViewModel(this._invoiceUploadRespositiory);

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

      final files = await _invoiceUploadRespositiory.pickFiles();
      if (files == null || files.isEmpty) {
        _isUploading = false;
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final userInfo = jsonDecode(prefs.getString('userInfo')!);
      final userId = userInfo['user_id'];

      final tempMessages = <String>[];

      for (final file in files) {
        try {
          final fileName = path.basename(file.path);

          // 上传到OSS
          final imageUrl = await _invoiceUploadRespositiory.uploadToOSS(
            file,
            userId,
          );

          // 提交到服务器
          final result = await _invoiceUploadRespositiory.submitInvoiceInfo(
            imageUrl,
            userId,
          );

          tempMessages.add('✅ $fileName 上传成功: $result');
          notifyListeners();
          successCount++;
        } catch (e) {
          final fileName = path.basename(file.path);
          tempMessages.add('❌ $fileName 上传失败: 发票数据已存在！');
          notifyListeners();
        }
      }

      _messages.addAll(tempMessages);
      _isUploaded = true;
    } catch (e) {
      _messages.add('🚨 系统错误: ${e.toString()}');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
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
