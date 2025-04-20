import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

class InvoiceModel extends Equatable {
  final int id;
  final String invoiceType;
  final String invoiceNum;
  final String invoiceDate;
  final String purchaserName;
  final String sellerName;
  final Decimal amountInFigures;
  final String serviceType;

  const InvoiceModel({
    required this.id,
    required this.invoiceType,
    required this.invoiceNum,
    required this.invoiceDate,
    required this.purchaserName,
    required this.sellerName,
    required this.amountInFigures,
    required this.serviceType,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as int,
      invoiceType: json['invoice_type'] as String,
      invoiceNum: json['invoice_num'] as String,
      invoiceDate: json['invoice_date'] as String,
      purchaserName: json['commodity_name'] as String,
      sellerName: json['seller_name'] as String,
      amountInFigures: Decimal.parse(json['amount_in_figures'].toString()),
      serviceType: json['ServiceType'] as String,
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
    serviceType,
  ];
}

class InvoiceSelfModel extends Equatable {
  final int id;
  final String invoiceType;
  final String invoiceNum;
  final String invoiceDate;
  final String purchaserName;
  final String purchaserRegisterNum;
  final String sellerName;
  final String sellerRegisterNum;
  final List<CommodityDetail> commodityName;
  final List<CommodityDetail> commodityType;
  final List<CommodityDetail> commodityUnit;
  final List<CommodityDetail> commodityNum;
  final List<CommodityDetail> commodityPrice;
  final List<CommodityDetail> commodityAmount;
  final List<CommodityDetail> commodityTaxRate;
  final List<CommodityDetail> commodityTax;
  final Decimal amountInFigures;
  final String amountInWords;
  final int userId;
  final String createdAt;
  final String updatedAt;
  final String serviceType;

  const InvoiceSelfModel({
    required this.id,
    required this.invoiceType,
    required this.invoiceNum,
    required this.invoiceDate,
    required this.purchaserName,
    required this.purchaserRegisterNum,
    required this.sellerName,
    required this.sellerRegisterNum,
    required this.commodityName,
    required this.commodityType,
    required this.commodityUnit,
    required this.commodityNum,
    required this.commodityPrice,
    required this.commodityAmount,
    required this.commodityTaxRate,
    required this.commodityTax,
    required this.amountInFigures,
    required this.amountInWords,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.serviceType,
  });

  factory InvoiceSelfModel.fromJson(Map<String, dynamic> json) {
    return InvoiceSelfModel(
      id: json['id'] as int,
      invoiceType: json['invoice_type'] as String,
      invoiceNum: json['invoice_num'] as String,
      invoiceDate: json['invoice_date'] as String,
      purchaserName: json['purchaser_name'] as String,
      purchaserRegisterNum: json['purchaser_register_num'] as String,
      sellerName: json['seller_name'] as String,
      sellerRegisterNum: json['seller_register_num'] as String,
      commodityName:
          (json['commodity_name'] as List)
              .map((item) => CommodityDetail.fromJson(item))
              .toList(),
      commodityType:
          (json['commodity_type'] as List)
              .map((item) => CommodityDetail.fromJson(item))
              .toList(),
      commodityUnit:
          (json['commodity_unit'] as List)
              .map((item) => CommodityDetail.fromJson(item))
              .toList(),
      commodityNum:
          (json['commodity_num'] as List)
              .map((item) => CommodityDetail.fromJson(item))
              .toList(),
      commodityPrice:
          (json['commodity_price'] as List)
              .map((item) => CommodityDetail.fromJson(item))
              .toList(),
      commodityAmount:
          (json['commodity_amount'] as List)
              .map((item) => CommodityDetail.fromJson(item))
              .toList(),
      commodityTaxRate:
          (json['commodity_tax_rate'] as List)
              .map((item) => CommodityDetail.fromJson(item))
              .toList(),
      commodityTax:
          (json['commodity_tax'] as List)
              .map((item) => CommodityDetail.fromJson(item))
              .toList(),
      amountInFigures: Decimal.parse(json['amount_in_figures'].toString()),
      amountInWords: json['amount_in_words'] as String,
      userId: json['user_id'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      serviceType: json['ServiceType'] as String,
    );
  }

  @override
  List<Object?> get props => [
    id,
    invoiceType,
    invoiceNum,
    invoiceDate,
    purchaserName,
    purchaserRegisterNum,
    sellerName,
    sellerRegisterNum,
    commodityName,
    commodityType,
    commodityUnit,
    commodityNum,
    commodityPrice,
    commodityAmount,
    commodityTaxRate,
    commodityTax,
    amountInFigures,
    amountInWords,
    userId,
    createdAt,
    updatedAt,
    serviceType,
  ];
}

class CommodityDetail extends Equatable {
  final int row;
  final String word;

  const CommodityDetail({required this.row, required this.word});

  factory CommodityDetail.fromJson(Map<String, dynamic> json) {
    return CommodityDetail(
      row: int.parse(json['row'].toString()),
      word: json['word'] as String,
    );
  }

  @override
  List<Object?> get props => [row, word];
}
