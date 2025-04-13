import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:management_invoices/core/repositories/invoice_repository/invoice_upload_respositiory.dart';

class InvoiceUploadViewModel extends ChangeNotifier {
  final InvoiceUploadRepository _invoiceUploadRepository;
  InvoiceUploadViewModel(this._invoiceUploadRepository);
  final TextEditingController invoiceTypeController = TextEditingController();
  final TextEditingController invoiceNumController = TextEditingController();
  final TextEditingController invoiceDateController = TextEditingController();
  final TextEditingController purchaserNameController = TextEditingController();
  final TextEditingController purchaserRegisterNumController =
      TextEditingController();
  final TextEditingController sellerNameController = TextEditingController();
  final TextEditingController sellerRegisterNumController =
      TextEditingController();
  final TextEditingController commodityNameController = TextEditingController();
  final TextEditingController commodityTypeController = TextEditingController();
  final TextEditingController commodityUnitController = TextEditingController();
  final TextEditingController commodityNumController = TextEditingController();
  final TextEditingController commodityPriceController =
      TextEditingController();
  final TextEditingController commodityAmountController =
      TextEditingController();
  final TextEditingController commodityTaxRateController =
      TextEditingController();
  final TextEditingController commodityTaxController = TextEditingController();
  final TextEditingController amountInFiguresController =
      TextEditingController();
  final TextEditingController amountInWordsController = TextEditingController();
  final TextEditingController serviceTypeController = TextEditingController();

  bool _isUploading = false;
  bool _isUploaded = false;
  final List<String> _messages = [];
  int successCount = 0;

  bool get isUploading => _isUploading;
  bool get isUploaded => _isUploaded;
  List<String> get messages => _messages;

  Future<void> submitHandInvoiceInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userInfo = jsonDecode(prefs.getString('userInfo')!);
      final userId = userInfo['user_id'] as int;
      debugPrint('用户ID: $userId');

      // Construct invoiceData to match the server's expected structure
      final invoiceData = {
        'InvoiceType': invoiceTypeController.text,
        'InvoiceNum': invoiceNumController.text,
        'InvoiceDate': invoiceDateController.text,
        'PurchaserName': purchaserNameController.text,
        'PurchaserRegisterNum': purchaserRegisterNumController.text,
        'SellerName': sellerNameController.text,
        'SellerRegisterNum': sellerRegisterNumController.text,
        'CommodityName': [
          {'row': '1', 'word': commodityNameController.text},
        ],
        'CommodityType': [
          {'row': '1', 'word': commodityTypeController.text},
        ],
        'CommodityUnit': [
          {'row': '1', 'word': commodityUnitController.text},
        ],
        'CommodityNum': [
          {'row': '1', 'word': commodityNumController.text},
        ],
        'CommodityPrice': [
          {'row': '1', 'word': commodityPriceController.text},
        ],
        'CommodityAmount': [
          {'row': '1', 'word': commodityAmountController.text},
        ],
        'CommodityTaxRate': [
          {'row': '1', 'word': commodityTaxRateController.text},
        ],
        'CommodityTax': [
          {'row': '1', 'word': commodityTaxController.text},
        ],
        'AmountInFigures': amountInFiguresController.text,
        'AmountInWords': amountInWordsController.text,
        'ServiceType': serviceTypeController.text,
      };
      debugPrint('准备提交的发票数据: $invoiceData');
      // Call repository method to submit data
      final response = await _invoiceUploadRepository.submitHandInvoiceInfo(
        invoiceData,
        userId,
      );
      debugPrint('上传成功: $response');
      _messages.add('✅ 手动发票上传成功');
      successCount++;
    } catch (e) {
      debugPrint(_getErrorMessage(e));
      _messages.add('❌ 上传失败: 发票已存在'); // 显示具
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

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
          debugPrint('上传成功: $imageUrl');
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

  Future<void> uploadPDFInvoice() async {
    try {
      if (_isUploading) return;
      _isUploading = true;
      notifyListeners();
      final files = await _invoiceUploadRepository.pickPDFFiles();
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
          final result2 = await _invoiceUploadRepository.submitPDFInvoiceInfo(
            file,
            userId,
          );

          debugPrint('发票存储成功: $result2');
          tempMessages.add('✅ ${path.basename(file.path)} 上传成功: $result2');
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
    return e.toString().replaceAll('Exception: ', '');
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
