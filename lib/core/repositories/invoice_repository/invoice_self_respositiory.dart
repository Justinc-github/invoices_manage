import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:management_invoices/core/models/invoice_self_model.dart';

class InvoiceSelfRespositiory {
  static const String _baseUrl = 'http://47.95.171.19';
  static const String _invoiceGetPath = '/admin_invoice/invoice_user';
  static const String _invoiceOperationPath =
      '/admin_invoice/invoice_operation';
  InvoiceSelfRespositiory({Dio? dio}) : dio = dio ?? Dio();
  final Dio dio;

  Future<List<InvoiceModel>?> invoiceInfoGet(String userId) async {
    try {
      final response = await dio.get('$_baseUrl$_invoiceGetPath/$userId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        // print('Fetched invoices: $data');
        return data.map((json) => InvoiceModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('Error fetching invoices: ${e.message}');
      return [];
    }
  }

  Future<void> invoiceInfoDelete(String invoiceNum) async {
    try {
      final response = await dio.delete(
        '$_baseUrl$_invoiceOperationPath/$invoiceNum',
      );
      if (response.statusCode == 200) {
        debugPrint("发票ID为$invoiceNum的发票成功删除");
      }
    } on DioException catch (e) {
      debugPrint('Error fetching invoices: ${e.message}');
    }
  }

  Future<InvoiceSelfModel?> invoiceInfoSingleGet(int invoiceId) async {
    try {
      final response = await dio.get(
        '$_baseUrl$_invoiceOperationPath/$invoiceId',
      );
      if (response.statusCode == 200) {
        debugPrint(response.data['data'].toString());
        final data = response.data['data']; // 假设返回的数据结构中包含 data 字段
        return InvoiceSelfModel.fromJson(data); // 使用模型解析数据
      }
    } on DioException catch (e) {
      debugPrint('Error fetching invoices: ${e.message}');
    }
    return null;
  }

  Future<void> invoiceInfoChange(
    int invoiceId,
    InvoiceSelfModel invoice,
  ) async {
    try {
      // 构造请求体
      final requestBody = {
        if (invoice.invoiceType.isNotEmpty) "invoice_type": invoice.invoiceType,
        if (invoice.invoiceNum.isNotEmpty) "invoice_num": invoice.invoiceNum,
        if (invoice.invoiceDate.isNotEmpty) "invoice_date": invoice.invoiceDate,
        if (invoice.purchaserName.isNotEmpty)
          "purchaser_name": invoice.purchaserName,
        if (invoice.purchaserRegisterNum.isNotEmpty)
          "purchaser_register_num": invoice.purchaserRegisterNum,
        if (invoice.sellerName.isNotEmpty) "seller_name": invoice.sellerName,
        if (invoice.sellerRegisterNum.isNotEmpty)
          "seller_register_num": invoice.sellerRegisterNum,
        if (invoice.commodityName.isNotEmpty)
          "commodity_name": jsonEncode(
            invoice.commodityName
                .map((item) => {"row": item.row.toString(), "word": item.word})
                .toList(),
          ),
        if (invoice.commodityType.isNotEmpty)
          "commodity_type": jsonEncode(
            invoice.commodityType
                .map((item) => {"row": item.row.toString(), "word": item.word})
                .toList(),
          ),
        if (invoice.commodityUnit.isNotEmpty)
          "commodity_unit": jsonEncode(
            invoice.commodityUnit
                .map((item) => {"row": item.row.toString(), "word": item.word})
                .toList(),
          ),
        if (invoice.commodityNum.isNotEmpty)
          "commodity_num": jsonEncode(
            invoice.commodityNum
                .map((item) => {"row": item.row.toString(), "word": item.word})
                .toList(),
          ),
        if (invoice.commodityPrice.isNotEmpty)
          "commodity_price": jsonEncode(
            invoice.commodityPrice
                .map((item) => {"row": item.row.toString(), "word": item.word})
                .toList(),
          ),
        if (invoice.commodityAmount.isNotEmpty)
          "commodity_amount": jsonEncode(
            invoice.commodityAmount
                .map((item) => {"row": item.row.toString(), "word": item.word})
                .toList(),
          ),
        if (invoice.commodityTaxRate.isNotEmpty)
          "commodity_tax_rate": jsonEncode(
            invoice.commodityTaxRate
                .map((item) => {"row": item.row.toString(), "word": item.word})
                .toList(),
          ),
        if (invoice.commodityTax.isNotEmpty)
          "commodity_tax": jsonEncode(
            invoice.commodityTax
                .map((item) => {"row": item.row.toString(), "word": item.word})
                .toList(),
          ),
        if (invoice.amountInFigures != Decimal.zero)
          "amount_in_figures": invoice.amountInFigures.toDouble(),
        if (invoice.amountInWords.isNotEmpty)
          "amount_in_words": invoice.amountInWords,
        if (invoice.serviceType.isNotEmpty) "service_type": invoice.serviceType,
      };

      // // 打印请求体以验证数据
      // debugPrint("请求体: $requestBody");

      // 发送 PUT 请求
      final response = await dio.put(
        '$_baseUrl$_invoiceOperationPath/$invoiceId',
        data: requestBody,
      );

      if (response.statusCode == 200) {
        debugPrint('发票更新成功: ${response.data}');
      } else {
        debugPrint('发票更新失败: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Error updating invoice: ${e.message}');
      debugPrint('响应数据: ${e.response?.data}');
    }
  }

  Future<List<InvoiceSelfModel>> invoiceInfoAlleGet() async {
    try {
      final response = await dio.get('$_baseUrl$_invoiceOperationPath');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List; // 假设返回的数据是一个列表
        return data.map((item) => InvoiceSelfModel.fromJson(item)).toList();
      }
    } on DioException catch (e) {
      debugPrint('Error fetching invoices: ${e.message}');
    }
    return []; // 如果出错，返回空列表
  }
}
