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
          top: MediaQuery.of(context).size.width * 0.05,
          bottom: MediaQuery.of(context).size.width * 0.01,
          right: 100,
          child: Row(
            children: [
              // 第一列
              Column(
                crossAxisAlignment: CrossAxisAlignment.end, // 设置列内对齐方式为尾部对齐
                children: [
                  //invoice_type
                  _inputBox(color: color, label: '发票类型', tip: '请输入属于哪种发票'),
                  //invoice_num
                  _inputBox(color: color, label: '发票号码', tip: '请输入发票号码'),
                  // invoice_date
                  _inputBox(color: color, label: '开票日期', tip: '请输入开票日期'),
                  //purchaser_name
                  _inputBox(color: color, label: '买方名称', tip: '请输入购买方名称'),
                  //purchaser_register_num
                  _inputBox(color: color, label: '买方税号', tip: '请输入购买方税号'),
                  // seller_name
                  _inputBox(color: color, label: '卖方名称', tip: '请输入销售方名称'),
                ],
              ),
              SizedBox(width: 20),
              // 第二列
              Column(
                children: [
                  //seller_register_num
                  _inputBox(color: color, label: '卖方税号', tip: '请输入发票抬头'),
                  //commodity_name
                  _inputBox(color: color, label: '物品名称', tip: '请输入购置物品名称'),
                  //commodity_type
                  _inputBox(color: color, label: '发票类型', tip: '请输入购置物品类型'),
                  // commodity_unit
                  _inputBox(color: color, label: '物品数量', tip: '请输入购置数量'),
                  // commodity_unit
                  _inputBox(color: color, label: '数量单位', tip: '请输入购置物品数量单位'),
                  //commodity_price
                  _inputBox(color: color, label: '物品单价', tip: '请输入购置物品单价'),
                ],
              ),
              SizedBox(width: 20),
              // 第三列
              Column(
                children: [
                  // commodity_tax_rate
                  _inputBox(color: color, label: '物品税率', tip: '请输入购置物品税率'),
                  // commodity_tax
                  _inputBox(color: color, label: '物品税额', tip: '请输入购置物品税额'),
                  //commodity_amount
                  _inputBox(color: color, label: '物品金额', tip: '请输入购置物品金额'),
                  //ServiceType
                  _inputBox(color: color, label: '消费类型', tip: '请输入消费类型'),
                  // amount_in_figures
                  _inputBox(color: color, label: '合计金额', tip: '请输入物品合计金额'),
                  // amount_in_words
                  _inputBox(color: color, label: '金额大写', tip: '物品金额大写（可忽略）'),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 20,

          right: 470,
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
            ],
          ),
        ),
      ],
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
                placeholder: tip,
                style: const TextStyle(fontSize: 15),
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
                child: FilledButton(
                  child: const Text('关闭'),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
    );
  }
}
