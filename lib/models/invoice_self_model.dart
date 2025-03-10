import 'package:equatable/equatable.dart';

class InvoiceModel extends Equatable {
  final int id;
  final String invoiceType;
  final String invoiceNum;
  final String invoiceDate;
  final String purchaserName;
  final String sellerName;
  final double amountInFigures;

  const InvoiceModel({
    required this.id,
    required this.invoiceType,
    required this.invoiceNum,
    required this.invoiceDate,
    required this.purchaserName,
    required this.sellerName,
    required this.amountInFigures,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as int,
      invoiceType: json['invoice_type'] as String,
      invoiceNum: json['invoice_num'] as String,
      invoiceDate: json['invoice_date'] as String,
      purchaserName: json['commodity_name'] as String,
      sellerName: json['seller_name'] as String,
      amountInFigures: (json['amount_in_figures'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    invoiceType,
    invoiceNum,
    invoiceDate,
    purchaserName,
    sellerName,
    amountInFigures,
  ];
}
