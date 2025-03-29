import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:management_invoices/core/repositories/invoice_repository/invoice_self_respositiory.dart';

import 'package:management_invoices/core/models/invoice_self_model.dart';

class InvoiceSelfViewModel with ChangeNotifier {
  final InvoiceSelfRespositiory _invoiceSelfRespositiory;
  InvoiceSelfViewModel(this._invoiceSelfRespositiory);

  bool _isLoading = false; // 新增加载状态
  bool _isLoadingOther = false; // 新增加载状态
  Decimal _totalAmount = Decimal.zero; // 存储发票的总金额
  Decimal _totalOtherAmount = Decimal.zero; // 存储发票的总金额

  // 分页相关状态
  List<InvoiceModel> _invoicesInfos = [];
  List<InvoiceModel> _invoicesOtherInfos = [];
  String? _userInfoString;
  int _currentPage = 1;
  int _itemsPerPage = 10;
  int _totalItems = 0;
  String _otherId = '';
  String _userName = '';

  bool get isLoadingOther => _isLoadingOther;
  String get userName => _userName;
  List<InvoiceModel> get invoiceInfos => _invoicesInfos;
  List<InvoiceModel> get invoicesOtherInfos => _invoicesOtherInfos;
  bool get isLoading => _isLoading;
  Decimal get totalAmount => _totalAmount;
  Decimal get totalOtherAmount => _totalOtherAmount;
  int get currentPage => _currentPage;
  String get otherId => _otherId;
  int get itemsPerPage => _itemsPerPage;
  int get totalItems => _totalItems;
  int get totalPages => (_totalItems / _itemsPerPage).ceil();

  Future<void> resetInvoiceData() async {
    _currentPage = 1;
    _itemsPerPage = 10;
    _totalItems = 0;
    _invoicesInfos = [];
    notifyListeners();
  }

  Future<void> userInvoiceSelfGet(String userId, String userName) async {
    _otherId = userId;
    _userName = userName;
    await getInvoiceOther(userId);
    notifyListeners();
  }

  void calculateOtherTotalAmount() {
    _totalOtherAmount = _invoicesOtherInfos.fold<Decimal>(
      Decimal.zero,
      (sum, item) => sum + item.amountInFigures,
    );
    notifyListeners();
  }

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
      _totalAmount = Decimal.zero;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getInvoiceOther(String userId) async {
    _isLoadingOther = true;
    notifyListeners();
    try {
      final result = await _invoiceSelfRespositiory.invoiceInfoGet(userId);
      _invoicesOtherInfos = result ?? [];
      debugPrint(_invoicesOtherInfos.toString());
      _totalItems = _invoicesOtherInfos.length;
      _isLoading = false;
      notifyListeners();
      calculateOtherTotalAmount();
    } catch (e) {
      debugPrint('Error fetching invoices: $e');
      _invoicesOtherInfos = [];
      _totalAmount = Decimal.zero;
      _isLoading = false;
      notifyListeners();
    }
    _isLoadingOther = false;
    notifyListeners();
  }

  void calculateTotalAmount() {
    _totalAmount = _invoicesInfos.fold<Decimal>(
      Decimal.zero,
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
