// invoice_self_respositiory.dart
import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/models/invoice_self_model.dart';

class InvoiceSelfRespositiory {
  static const String _baseUrl = 'http://127.0.0.1:8000';
  static const String _invoiceGetPath = '/admin_invoice/invoice_user';
  InvoiceSelfRespositiory({Dio? dio}) : dio = dio ?? Dio();
  final Dio dio;

  Future<List<InvoiceModel>?> invoiceInfoGet(String userId) async {
    try {
      final response = await dio.get('$_baseUrl$_invoiceGetPath/$userId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => InvoiceModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('Error fetching invoices: ${e.message}');
      return [];
    }
  }
}
