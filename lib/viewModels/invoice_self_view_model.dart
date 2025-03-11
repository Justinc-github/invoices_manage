import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/models/invoice_self_model.dart';
import 'package:management_invoices/models/repositories/invoice_self_respositiory.dart';

class InvoiceSelfViewModel with ChangeNotifier {
  final InvoiceSelfRespositiory _invoiceSelfRespositiory;
  InvoiceSelfViewModel(this._invoiceSelfRespositiory);

  bool _isLoading = false; // 新增加载状态
  double _totalAmount = 0.0; // 存储发票的总金额
  List<InvoiceModel> _invoicesInfos = [];

  List<InvoiceModel> get invoiceInfos => _invoicesInfos;
  bool get isLoading => _isLoading;
  double get totalAmount => _totalAmount;

  Future<void> invoiceSelf() async {
    if (_isLoading) return;
    _isLoading = true;
    final result = await _invoiceSelfRespositiory.invoiceInfoGet('1');
    _invoicesInfos = result!; // 这里需要确保 _invoicesInfos 是 List<InvoiceModel> 类型
    calculateTotalAmount();
    notifyListeners(); // 如果使用状态管理
  }

  // 计算发票总金额
  void calculateTotalAmount() {
    double sum = _invoicesInfos.fold(
      0,
      (sum, item) => sum + item.amountInFigures,
    );
    _totalAmount = sum;
  }
}
