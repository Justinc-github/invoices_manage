import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/shared/utils/mouse_cursor.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:management_invoices/core/repositories/invoice_repository/invoice_self_respositiory.dart';

import 'package:management_invoices/core/models/invoice_self_model.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

class InvoiceSelfViewModel with ChangeNotifier {
  final InvoiceSelfRespositiory _invoiceSelfRespositiory;
  InvoiceSelfViewModel(this._invoiceSelfRespositiory);

  bool _isLoading = false; // 新增加载状态
  bool _isLoadingOther = false; // 新增加载状态
  Decimal _totalAmount = Decimal.zero; // 存储发票的总金额

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

  Future<void> invoiceInfoSingleGet(int invoiceId) async {
    await _invoiceSelfRespositiory.invoiceInfoSingleGet(invoiceId);
    notifyListeners();
  }

  void calculateOtherTotalAmount() {
    _totalAmount = _invoicesOtherInfos.fold<Decimal>(
      Decimal.zero,
      (sum, item) => sum + item.amountInFigures,
    );
    notifyListeners();
  }

  Future<void> editInvoice(InvoiceModel invoice, BuildContext context) async {
    // 获取单个发票信息
    final InvoiceSelfModel? data = await _invoiceSelfRespositiory
        .invoiceInfoSingleGet(invoice.id);

    if (data == null) {
      debugPrint('未能获取发票信息');
      return;
    }

    // 创建 ScrollController
    final ScrollController scrollController = ScrollController();

    // 定义 TextEditingController
    final invoiceTypeController = TextEditingController(text: data.invoiceType);
    final invoiceNumController = TextEditingController(text: data.invoiceNum);
    final invoiceDateController = TextEditingController(text: data.invoiceDate);
    final purchaserNameController = TextEditingController(
      text: data.purchaserName,
    );
    final purchaserRegisterNumController = TextEditingController(
      text: data.purchaserRegisterNum,
    );
    final sellerNameController = TextEditingController(text: data.sellerName);
    final sellerRegisterNumController = TextEditingController(
      text: data.sellerRegisterNum,
    );
    final amountInFiguresController = TextEditingController(
      text: data.amountInFigures.toString(),
    );
    final amountInWordsController = TextEditingController(
      text: data.amountInWords,
    );
    final serviceTypeController = TextEditingController(text: data.serviceType);

    // 商品明细的 TextEditingController 列表
    final commodityNameControllers =
        data.commodityName
            .map((item) => TextEditingController(text: item.word))
            .toList();
    final commodityTypeControllers =
        data.commodityType
            .map((item) => TextEditingController(text: item.word))
            .toList();

    showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: 400,
          ), // 强制弹窗最大宽度
          title: Center(child: const Text('编辑发票')),
          content: SizedBox(
            width: 1000, // 设置宽度
            height: 600, // 设置高度
            child: Scrollbar(
              controller: scrollController, // 绑定 ScrollController
              child: SingleChildScrollView(
                controller: scrollController, // 绑定 ScrollController
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('发票类型：'),
                              TextBox(
                                placeholder: '请输入发票类型',
                                controller: invoiceTypeController,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('发票编号：'),
                              TextBox(
                                placeholder: '请输入发票编号',
                                controller: invoiceNumController,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('开票日期：'),
                              TextBox(
                                placeholder: '请输入开票日期',
                                controller: invoiceDateController,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('购买方名称：'),
                              TextBox(
                                placeholder: '请输入购买方名称',
                                controller: purchaserNameController,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('购买方税号：'),
                              TextBox(
                                placeholder: '请输入购买方税号',
                                controller: purchaserRegisterNumController,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('销售方名称：'),
                              TextBox(
                                placeholder: '请输入销售方名称',
                                controller: sellerNameController,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('销售方税号：'),
                              TextBox(
                                placeholder: '请输入销售方税号',
                                controller: sellerRegisterNumController,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('金额（数字）：'),
                              TextBox(
                                placeholder: '请输入金额（数字）',
                                controller: amountInFiguresController,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('金额（大写）：'),
                              TextBox(
                                placeholder: '请输入金额（大写）',
                                controller: amountInWordsController,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('服务类型：'),
                              TextBox(
                                placeholder: '请输入服务类型',
                                controller: serviceTypeController,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('商品明细：'),
                    const SizedBox(height: 10),
                    ...List.generate(data.commodityName.length, (index) {
                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('商品名称 (第${index + 1}行)：'),
                                TextBox(
                                  placeholder: '请输入商品名称',
                                  controller: commodityNameControllers[index],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('商品类型 (第${index + 1}行)：'),
                                TextBox(
                                  placeholder: '请输入商品类型',
                                  controller: commodityTypeControllers[index],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            MouseCursorClick(
              child: FilledButton(
                child: const Text('保存'),
                onPressed: () async {
                  final invoiceSelfViewModel =
                      context.read<InvoiceSelfViewModel>();
                  // 构造更新后的数据
                  final updatedInvoice = InvoiceSelfModel(
                    id: data.id,
                    invoiceType: invoiceTypeController.text,
                    invoiceNum: invoiceNumController.text,
                    invoiceDate: invoiceDateController.text,
                    purchaserName: purchaserNameController.text,
                    purchaserRegisterNum: purchaserRegisterNumController.text,
                    sellerName: sellerNameController.text,
                    sellerRegisterNum: sellerRegisterNumController.text,
                    commodityName:
                        commodityNameControllers
                            .map(
                              (controller) => CommodityDetail(
                                row: 1,
                                word: controller.text,
                              ),
                            )
                            .toList(),
                    commodityType:
                        commodityTypeControllers
                            .map(
                              (controller) => CommodityDetail(
                                row: 1,
                                word: controller.text,
                              ),
                            )
                            .toList(),
                    commodityUnit: data.commodityUnit,
                    commodityNum: data.commodityNum,
                    commodityPrice: data.commodityPrice,
                    commodityAmount: data.commodityAmount,
                    commodityTaxRate: data.commodityTaxRate,
                    commodityTax: data.commodityTax,
                    amountInFigures: Decimal.parse(
                      amountInFiguresController.text,
                    ),
                    amountInWords: amountInWordsController.text,
                    userId: data.userId,
                    createdAt: data.createdAt,
                    updatedAt: DateTime.now().toString(),
                    serviceType: serviceTypeController.text,
                  );

                  // 发起更新请求
                  await _invoiceSelfRespositiory.invoiceInfoChange(
                    data.id,
                    updatedInvoice,
                  );
                  invoiceSelfViewModel.setHasFetchedInvoices(false);
                  invoiceSelfViewModel.invoiceSelf();
                  Navigator.pop(context);
                },
              ),
            ),
            MouseCursorClick(
              child: Button(
                child: const Text('取消'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteInvoice(InvoiceModel invoice, BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        final invoiceSelfViewModel = context.read<InvoiceSelfViewModel>();
        return ContentDialog(
          title: const Text('删除发票'),
          content: Text('确定要删除发票 ID: ${invoice.invoiceNum} 吗？'),
          actions: [
            MouseCursorClick(
              child: FilledButton(
                child: const Text('删除'),
                onPressed: () async {
                  await _invoiceSelfRespositiory.invoiceInfoDelete(
                    invoice.id.toString(),
                  );
                  invoiceSelfViewModel.setHasFetchedInvoices(false);
                  invoiceSelfViewModel.invoiceSelf();
                  notifyListeners();
                  Navigator.pop(context);
                },
              ),
            ),
            MouseCursorClick(
              child: Button(
                child: const Text('取消'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
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
      // debugPrint(_invoicesInfos.toString()); // 打印结果
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

  Future<void> generateReport(BuildContext context) async {
    final invoices = await _invoiceSelfRespositiory.invoiceInfoAlleGet();
    final workbook = xlsio.Workbook();
    final sheet = workbook.worksheets[0];

    // 定义所有需要导出的字段
    final placeholders = [
      '发票ID',
      '发票类型',
      '发票编号',
      '开票日期',
      '购买方名称',
      '购买方税号',
      '销售方名称',
      '销售方税号',
      '金额（数字）',
      '金额（大写）',
      '服务类型',
      '商品名称',
      '商品类型',
      '商品单位',
      '商品数量',
      '商品单价',
      '商品金额',
      '商品税率',
      '商品税额',
      '创建时间',
      '更新时间',
    ];

    // 设置表头
    for (int i = 0; i < placeholders.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(placeholders[i]);
    }

    // 填充数据
    for (int i = 0; i < invoices.length; i++) {
      final invoice = invoices[i];
      sheet.getRangeByIndex(i + 2, 1).setNumber(invoice.id.toDouble()); // 发票ID
      sheet.getRangeByIndex(i + 2, 2).setText(invoice.invoiceType); // 发票类型
      sheet.getRangeByIndex(i + 2, 3).setText(invoice.invoiceNum); // 发票编号
      sheet.getRangeByIndex(i + 2, 4).setText(invoice.invoiceDate); // 开票日期
      sheet.getRangeByIndex(i + 2, 5).setText(invoice.purchaserName); // 购买方名称
      sheet
          .getRangeByIndex(i + 2, 6)
          .setText(invoice.purchaserRegisterNum); // 购买方税号
      sheet.getRangeByIndex(i + 2, 7).setText(invoice.sellerName); // 销售方名称
      sheet
          .getRangeByIndex(i + 2, 8)
          .setText(invoice.sellerRegisterNum); // 销售方税号
      sheet
          .getRangeByIndex(i + 2, 9)
          .setNumber(invoice.amountInFigures.toDouble()); // 金额（数字）
      sheet.getRangeByIndex(i + 2, 10).setText(invoice.amountInWords); // 金额（大写）
      sheet.getRangeByIndex(i + 2, 11).setText(invoice.serviceType); // 服务类型

      // 商品明细拼接为字符串
      final commodityDetails = <String>[];
      for (int j = 0; j < invoice.commodityName.length; j++) {
        final name = invoice.commodityName[j].word;
        final type = invoice.commodityType[j].word;
        final unit = invoice.commodityUnit[j].word;
        final num = invoice.commodityNum[j].word;
        final price = invoice.commodityPrice[j].word;
        final amount = invoice.commodityAmount[j].word;
        final taxRate = invoice.commodityTaxRate[j].word;
        final tax = invoice.commodityTax[j].word;

        commodityDetails.add(
          '名称: $name, 类型: $type, 单位: $unit, 数量: $num, 单价: $price, 金额: $amount, 税率: $taxRate, 税额: $tax',
        );
      }

      sheet
          .getRangeByIndex(i + 2, 12)
          .setText(commodityDetails.join('; ')); // 商品明细

      // 创建时间和更新时间
      sheet.getRangeByIndex(i + 2, 20).setText(invoice.createdAt); // 创建时间
      sheet.getRangeByIndex(i + 2, 21).setText(invoice.updatedAt); // 更新时间
    }

    // 保存为文件
    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final path = await FilePicker.platform.saveFile(
      dialogTitle: '保存报表',
      fileName: '发票报表.xlsx',
    );

    if (path != null) {
      final file = File(path);
      await file.writeAsBytes(bytes, flush: true);
      showDialog(
        context: context,
        builder:
            (_) => ContentDialog(
              title: const Text('报表生成成功'),
              content: const Text('报表已成功保存到指定位置。'),
              actions: [
                FilledButton(
                  child: const Text('确定'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
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
