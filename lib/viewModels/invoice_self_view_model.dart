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

  // 分页相关状态
  List<InvoiceModel> _invoicesInfos = [];
  String? _userInfoString;
  int _currentPage = 1;
  int _itemsPerPage = 10;
  int _totalItems = 0;

  List<InvoiceModel> get invoiceInfos => _invoicesInfos;
  bool get isLoading => _isLoading;
  double get totalAmount => _totalAmount;
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  int get totalItems => _totalItems;
  int get totalPages => (_totalItems / _itemsPerPage).ceil();

  // 分页数据
  List<InvoiceModel> get paginatedData {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = start + _itemsPerPage;
    return _invoicesInfos.sublist(
      start.clamp(0, _invoicesInfos.length),
      end.clamp(0, _invoicesInfos.length),
    );
  }

  Future<void> invoiceSelf() async {
    if (_isLoading) return;
    _isLoading = true;

    final prefs = await SharedPreferences.getInstance();
    _userInfoString = prefs.getString('userInfo');

    if (_userInfoString == null || _userInfoString!.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      Map<String, dynamic> userInfo = jsonDecode(_userInfoString!);
      final result = await _invoiceSelfRespositiory.invoiceInfoGet(
        userInfo['user_id'].toString(),
      );

      _invoicesInfos = result ?? [];
      _totalItems = _invoicesInfos.length;
      _isLoading = false;
      notifyListeners();
      calculateTotalAmount();
    } catch (e) {
      debugPrint('Error fetching invoices: $e');
      _invoicesInfos = [];
      _totalAmount = 0.0;
      _isLoading = false;
      notifyListeners();
    }
  }

  void calculateTotalAmount() {
    _totalAmount = _invoicesInfos.fold(
      0,
      (sum, item) => sum + item.amountInFigures,
    );
    notifyListeners();
  }

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void setItemsPerPage(int size) {
    _itemsPerPage = size;
    _currentPage = 1;
    notifyListeners();
  }

  void clearInvoiceData() {
    _invoicesInfos = [];
    _isLoading = false;
  }
}
