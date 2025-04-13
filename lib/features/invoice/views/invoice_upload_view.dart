import 'package:flutter/material.dart' show showDatePicker;
import 'package:flutter/services.dart';
import 'package:management_invoices/features/invoice/view_models/invoice_self_view_model.dart';
import 'package:management_invoices/shared/utils/mouse_cursor.dart';
import 'package:provider/provider.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:management_invoices/features/invoice/view_models/invoice_upload_view_model.dart';

class InvoiceUploadView extends StatelessWidget {
  const InvoiceUploadView({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceUploadViewModel = context.watch<InvoiceUploadViewModel>();
    final messages = invoiceUploadViewModel.messages;
    final invoiceSelfViewModel = context.read<InvoiceSelfViewModel>();
    final theme = FluentTheme.of(context); // 获取当前主题
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (messages.isNotEmpty) {
        final messagesCopy = List<String>.from(messages);
        _showResultDialog(context, messagesCopy);
        invoiceUploadViewModel.clearMessages();
      }
    });

    final color =
        theme.brightness == Brightness.dark
            ? Colors
                .white // 深色模式下图标为白色
            : Colors.black; // 浅色模式下图标为黑色

    return Stack(
      children: [
        Positioned(
          top: MediaQuery.of(context).size.height * 0.115,
          bottom: MediaQuery.of(context).size.width * 0.01,
          right: 100,
          child: Row(
            children: [
              // 第一列
              Column(
                crossAxisAlignment: CrossAxisAlignment.end, // 设置列内对齐方式为尾部对齐
                children: [
                  //invoice_type
                  _inputBox(
                    color: color,
                    label: '发票类型',
                    tip: '请输入属于哪种发票',
                    controller: invoiceUploadViewModel.invoiceTypeController,
                  ),
                  //invoice_num
                  _inputBox(
                    color: color,
                    label: '发票号码',
                    tip: '请输入发票号码',
                    controller: invoiceUploadViewModel.invoiceNumController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                  // invoice_date
                  _inputBox(
                    color: color,
                    label: '开票日期',
                    tip: '点击选择日期',
                    controller: invoiceUploadViewModel.invoiceDateController,
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        invoiceUploadViewModel.invoiceDateController.text =
                            "${selectedDate.year}年${selectedDate.month}月${selectedDate.day}日";
                      }
                    },
                  ),
                  //purchaser_name
                  _inputBox(
                    color: color,
                    label: '买方名称',
                    tip: '请输入购买方名称',
                    controller: invoiceUploadViewModel.purchaserNameController,
                  ),
                  //purchaser_register_num
                  _inputBox(
                    color: color,
                    label: '买方税号',
                    tip: '请输入购买方税号',
                    controller:
                        invoiceUploadViewModel.purchaserRegisterNumController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                  // seller_name
                  _inputBox(
                    color: color,
                    label: '卖方名称',
                    tip: '请输入销售方名称',
                    controller: invoiceUploadViewModel.sellerNameController,
                  ),
                ],
              ),
              SizedBox(width: 20),
              // 第二列
              Column(
                children: [
                  //seller_register_num
                  _inputBox(
                    color: color,
                    label: '卖方税号',
                    tip: '请输入发票抬头',
                    controller:
                        invoiceUploadViewModel.sellerRegisterNumController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                  //commodity_name
                  _inputBox(
                    color: color,
                    label: '物品名称',
                    tip: '请输入购置物品名称',
                    controller: invoiceUploadViewModel.commodityNameController,
                  ),
                  //commodity_type
                  _inputBox(
                    color: color,
                    label: '发票类型',
                    tip: '请输入购置物品类型',
                    controller: invoiceUploadViewModel.commodityTypeController,
                  ),
                  // commodity_unit
                  _inputBox(
                    color: color,
                    label: '物品数量',
                    tip: '请输入购置数量',
                    controller: invoiceUploadViewModel.commodityUnitController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                  // commodity_num
                  _inputBox(
                    color: color,
                    label: '数量单位',
                    tip: '请输入购置物品数量单位',
                    controller: invoiceUploadViewModel.commodityNumController,
                  ),
                  //commodity_price
                  _inputBox(
                    color: color,
                    label: '物品单价',
                    tip: '请输入购置物品单价',
                    controller: invoiceUploadViewModel.commodityPriceController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ],
              ),
              SizedBox(width: 20),
              // 第三列
              Column(
                children: [
                  // commodity_tax_rate
                  _inputBox(
                    color: color,
                    label: '物品税率',
                    tip: '请输入购置物品税率',
                    controller:
                        invoiceUploadViewModel.commodityTaxRateController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        try {
                          final text = newValue.text;
                          if (text.isNotEmpty) {
                            final value = double.parse(text);
                            if (value < 0) {
                              return oldValue; // 保持旧值
                            }
                          }
                          return newValue;
                        } catch (e) {
                          return oldValue; // 保持旧值
                        }
                      }),
                    ],
                  ),
                  // commodity_tax
                  _inputBox(
                    color: color,
                    label: '物品税额',
                    tip: '请输入购置物品税额',
                    controller: invoiceUploadViewModel.commodityTaxController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                  //commodity_amount
                  _inputBox(
                    color: color,
                    label: '物品金额',
                    tip: '请输入购置物品金额',
                    controller:
                        invoiceUploadViewModel.commodityAmountController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                  //ServiceType
                  _inputBox(
                    color: color,
                    label: '消费类型',
                    tip: '请输入消费类型',
                    controller: invoiceUploadViewModel.serviceTypeController,
                  ),
                  // amount_in_figures
                  _inputBox(
                    color: color,
                    label: '合计金额',
                    tip: '请输入物品合计金额',
                    controller:
                        invoiceUploadViewModel.amountInFiguresController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                  // amount_in_words
                  _inputBox(
                    color: color,
                    label: '金额大写',
                    tip: '物品金额大写（可忽略）',
                    controller: invoiceUploadViewModel.amountInWordsController,
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          right: 350,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildUploadButton(
                context: context,
                label: '图片上传',
                onPressed: () {
                  invoiceSelfViewModel.setHasFetchedInvoices(false);
                  invoiceUploadViewModel.uploadInvoice();
                },
                isActive: !invoiceUploadViewModel.isUploading,
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              _buildUploadButton(
                context: context,
                label: '文件上传',
                onPressed: () {
                  invoiceSelfViewModel.setHasFetchedInvoices(false);
                  invoiceUploadViewModel.uploadPDFInvoice();
                },
                isActive: !invoiceUploadViewModel.isUploading,
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              _buildUploadButton(
                context: context,
                label: '手动上传发票',
                onPressed: () async {
                  invoiceSelfViewModel.setHasFetchedInvoices(false);
                  if (_validateInputs(invoiceUploadViewModel)) {
                    invoiceUploadViewModel.submitHandInvoiceInfo();
                  } else {
                    _showValidationError(context);
                  }
                },
                isActive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _validateInputs(InvoiceUploadViewModel viewModel) {
    return viewModel.invoiceTypeController.text.isNotEmpty &&
        viewModel.invoiceNumController.text.isNotEmpty &&
        viewModel.invoiceDateController.text.isNotEmpty &&
        viewModel.purchaserNameController.text.isNotEmpty &&
        viewModel.purchaserRegisterNumController.text.isNotEmpty &&
        viewModel.sellerNameController.text.isNotEmpty &&
        viewModel.sellerRegisterNumController.text.isNotEmpty &&
        viewModel.commodityNameController.text.isNotEmpty &&
        viewModel.commodityTypeController.text.isNotEmpty &&
        viewModel.commodityUnitController.text.isNotEmpty &&
        viewModel.commodityNumController.text.isNotEmpty &&
        viewModel.commodityPriceController.text.isNotEmpty &&
        viewModel.commodityTaxRateController.text.isNotEmpty &&
        viewModel.commodityTaxController.text.isNotEmpty &&
        viewModel.commodityAmountController.text.isNotEmpty &&
        viewModel.amountInFiguresController.text.isNotEmpty &&
        viewModel.amountInWordsController.text.isNotEmpty &&
        viewModel.serviceTypeController.text.isNotEmpty;
  }

  void _showValidationError(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => ContentDialog(
            title: const Text('输入错误'),
            content: const Text('请填写所有必填字段。'),
            actions: [
              FilledButton(
                child: const Text('关闭'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  Widget _buildUploadButton({
    required BuildContext context,
    required String label,
    required VoidCallback? onPressed,
    required bool isActive,
  }) {
    return SizedBox(
      width: 130,
      height: 45,
      child: MouseRegion(
        cursor:
            isActive ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        child: FilledButton(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(const EdgeInsets.all(8)),
            iconSize: WidgetStateProperty.all(20),
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (states) => isActive ? null : Colors.grey[40],
            ),
          ),
          onPressed: isActive ? onPressed : null,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isActive ? null : Colors.grey[40],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputBox({
    required Color color,
    required String label,
    required String tip,
    required TextEditingController controller,
    List<TextInputFormatter>? inputFormatters, // 添加 inputFormatters 参数
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              '$label：',
              style: TextStyle(fontSize: 20, color: color, fontFamily: "MSYH"),
            ),
            SizedBox(
              height: 40,
              width: 200,
              child: TextBox(
                controller: controller,
                placeholder: tip,
                style: const TextStyle(fontSize: 15),
                inputFormatters: inputFormatters, // 应用 inputFormatters
                onTap: onTap,
              ),
            ),
          ],
        ),
        SizedBox(height: 50),
      ],
    );
  }

  void _showResultDialog(BuildContext context, List<String> messages) {
    showDialog(
      context: context,
      builder:
          (context) => ContentDialog(
            title: const Text('上传结果'),
            content: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 250),
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder:
                    (_, index) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        messages[index],
                        style: TextStyle(
                          color:
                              messages[index].contains('✅')
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                    ),
              ),
            ),
            actions: [
              MouseCursorClick(
                child: MouseCursorClick(
                  child: FilledButton(
                    child: const Text('关闭'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
