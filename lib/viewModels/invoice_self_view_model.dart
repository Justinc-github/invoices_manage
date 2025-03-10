import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/models/invoice_self_model.dart';
import 'package:management_invoices/models/repositories/invoice_self_respositiory.dart';

class InvoiceSelfViewModel with ChangeNotifier {
  final InvoiceSelfRespositiory _invoiceSelfRespositiory;
  InvoiceSelfViewModel(this._invoiceSelfRespositiory);

  final List<InvoiceModel> _invoicesInfos = [
    InvoiceModel(
      id: 1,
      invoiceType: 'aa',
      invoiceNum: 'invoiceNum',
      invoiceDate: 'invoiceDate',
      purchaserName: 'purchaserName',
      sellerName: 'sellerName',
      amountInFigures: 12.1,
    ),
  ];

  List<InvoiceModel> get invoiceInfos => _invoicesInfos;

  Future<void> invoiceSelf() async {
    _invoiceSelfRespositiory.invoiceSelfGet();
  }
}
