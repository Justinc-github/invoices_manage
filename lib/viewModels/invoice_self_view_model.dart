import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/models/invoice_self_model.dart';
import 'package:management_invoices/models/repositories/invoice_self_respositiory.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvoiceSelfViewModel with ChangeNotifier {
  final InvoiceSelfRespositiory _invoiceSelfRespositiory;
  InvoiceSelfViewModel(this._invoiceSelfRespositiory);

  bool _isLoading = false; // 新增加载状态
  double _totalAmount = 0.0; // 存储发票的总金额
  List<InvoiceModel> _invoicesInfos = [];
  String? _userInfoString;

  List<InvoiceModel> get invoiceInfos => _invoicesInfos;
  bool get isLoading => _isLoading;
  double get totalAmount => _totalAmount;

  Future<void> invoiceSelf() async {
    if (_isLoading) return;
    _isLoading = true;
    final prefs = await SharedPreferences.getInstance();
    _userInfoString = prefs.getString('userInfo');

    // 新增检查：如果 userInfoString 为空，直接返回并重置状态
    if (_userInfoString == null || _userInfoString!.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      Map<String, dynamic> userInfo = jsonDecode(_userInfoString!);
      final result = await _invoiceSelfRespositiory.invoiceInfoGet(
        userInfo['user_id'],
      );
      _invoicesInfos = result ?? []; // 处理可能的 null 返回值
      calculateTotalAmount();
    } catch (e) {
      // 捕获并处理异常（如 JSON 解析错误、API 错误等）
      debugPrint('Error fetching invoices: $e');
      _invoicesInfos = []; // 发生错误时清空数据
      _totalAmount = 0.0;
    } finally {
      _isLoading = false;
      notifyListeners(); // 最终通知状态更新
    }
  }

  // 计算发票总金额
  void calculateTotalAmount() {
    double sum = _invoicesInfos.fold(
      0,
      (sum, item) => sum + item.amountInFigures,
    );
    _totalAmount = sum;
  }

  void clearInvoiceData() {
    _invoicesInfos = [];
    _isLoading = false;
  }
}
