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
  int _charType = 0;
  String _otherId = '';
  String _userName = '';
  bool _isLoadingCharType = false;

  int get charType => _charType;
  bool _hasFetchedInvoices = false;
  bool get isLoadingCharType => _isLoadingCharType;
  bool get isLoadingOther => _isLoadingOther;
  String get userName => _userName;
  List<InvoiceModel> get invoiceInfos => _invoicesInfos;
  List<InvoiceModel> get invoicesOtherInfos => _invoicesOtherInfos;
  bool get isLoading => _isLoading;
  Decimal get totalAmount => _totalAmount;
  int get currentPage => _currentPage;
  String get otherId => _otherId;
  int get itemsPerPage => _itemsPerPage;
  int get totalItems => _totalItems;
  int get totalPages => (_totalItems / _itemsPerPage).ceil();

  Future<void> charTypeChange(int type) async {
    _charType = type;
    debugPrint(_charType.toString());
    notifyListeners();
  }

  // 修改发票加载状态
  void setHasFetchedInvoices(bool value) {
    _hasFetchedInvoices = value;
    notifyListeners();
  }

  Future<void> resetInvoice() async {
    _currentPage = 1;
    _itemsPerPage = 10;
    _totalItems = 0;
    _charType = 0;
    _hasFetchedInvoices = false;
    _isLoadingCharType = false;
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
    _totalAmount = _invoicesOtherInfos.fold<Decimal>(
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
    debugPrint(_hasFetchedInvoices.toString()); // 打印是否已加载数据
    if (_hasFetchedInvoices && _invoicesInfos.isNotEmpty) {
      // 如果数据已经加载过，直接返回
      return;
    }
    if (_isLoading) return;
    _isLoading = true;
    _isLoadingCharType = true;
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
      debugPrint(_invoicesInfos.toString()); // 打印结果
      _totalItems = _invoicesInfos.length;
      _isLoading = false;
      notifyListeners();
      calculateTotalAmount();
      _hasFetchedInvoices = true; // 标记数据已加载
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
      _invoicesInfos = [];
      _invoicesOtherInfos = [];
      final result = await _invoiceSelfRespositiory.invoiceInfoGet(userId);
      _invoicesOtherInfos = result ?? [];
      // debugPrint(_invoicesOtherInfos.toString());
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
