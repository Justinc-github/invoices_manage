import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/features/invoice/view_models/invoice_self_view_model.dart';
import 'package:management_invoices/features/invoice/views/invoice_self_view.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class InvoiceOtherView extends StatelessWidget {
  final String userId;
  final String userName;
  const InvoiceOtherView({
    super.key,
    required this.userId,
    required this.userName,
  });
  @override
  Widget build(BuildContext context) {
    final invoiceSelfViewModel = context.watch<InvoiceSelfViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (invoiceSelfViewModel.otherId != '' &&
          invoiceSelfViewModel.otherId != userId) {
        invoiceSelfViewModel.getInvoiceOther(userId);
      }
    });
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Container(
        color: FluentTheme.of(context).scaffoldBackgroundColor, // 动态背景颜色
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final invoiceDataSource = InvoiceDataSource(
                  invoices:
                      invoiceSelfViewModel
                          .invoicesOtherInfos, // 修改为使用 invoicesOtherInfos
                  context: context,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        '当前登录用户名: $userName',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'MSYH',
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                          left: 20.0,
                          right: 20.0,
                          bottom: 80.0,
                        ),
                        child: SfDataGrid(
                          columnWidthMode: ColumnWidthMode.fill,
                          gridLinesVisibility: GridLinesVisibility.both,
                          headerGridLinesVisibility: GridLinesVisibility.both,
                          rowHeight: 60,
                          source: invoiceDataSource,
                          columns: [
                            GridColumn(
                              columnName: 'invoiceNum',
                              label: _buildHeader(context, '发票ID'),
                            ),
                            GridColumn(
                              columnName: 'invoiceType',
                              label: _buildHeader(context, '发票类型'),
                            ),
                            GridColumn(
                              columnName: 'invoiceDate',
                              label: _buildHeader(context, '开票日期'),
                            ),
                            GridColumn(
                              columnName: 'purchaserName',
                              label: _buildHeader(context, '购买物品'),
                            ),
                            GridColumn(
                              columnName: 'sellerName',
                              label: _buildHeader(context, '销售者'),
                            ),
                            GridColumn(
                              columnName: 'amountInFigures',
                              label: _buildHeader(context, '金额'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildPaginationControls(context),
            ),
            Positioned(
              right: 15,
              bottom: 10,
              child: Text(
                '总金额: ¥${invoiceSelfViewModel.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      FluentTheme.of(context).brightness == Brightness.dark
                          ? Colors
                              .white // 深色模式下文字为白色
                          : Colors.black, // 浅色模式下文字为黑色
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String text) {
    final theme = FluentTheme.of(context); // 使用传递的 BuildContext 获取主题

    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'MSYH',
          color:
              theme.brightness == Brightness.dark
                  ? Colors
                      .white // 深色模式下表头文字为白色
                  : Colors.black, // 浅色模式下表头文字为黑色
        ),
      ),
    );
  }

  Widget _buildPaginationControls(BuildContext context) {
    final theme = FluentTheme.of(context); // 获取当前主题
    final invoiceSelfViewModel = context.watch<InvoiceSelfViewModel>();

    return Container(
      color:
          theme.brightness == Brightness.dark
              ? Colors.grey[220] // 深色模式下背景为深灰色
              : Colors.grey[100], // 浅色模式下背景为浅灰色
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton(
                  icon: Icon(
                    FluentIcons.chevron_left,
                    color:
                        theme.brightness == Brightness.dark
                            ? Colors
                                .white // 深色模式下图标为白色
                            : Colors.black, // 浅色模式下图标为黑色
                  ),
                  onPressed:
                      invoiceSelfViewModel.currentPage > 1
                          ? () => invoiceSelfViewModel.setCurrentPage(
                            invoiceSelfViewModel.currentPage - 1,
                          )
                          : null,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                  '第 ${invoiceSelfViewModel.currentPage} 页 / 共 ${invoiceSelfViewModel.totalPages} 页',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton(
                  icon: const Icon(FluentIcons.chevron_right),
                  onPressed:
                      invoiceSelfViewModel.currentPage <
                              invoiceSelfViewModel.totalPages
                          ? () => invoiceSelfViewModel.setCurrentPage(
                            invoiceSelfViewModel.currentPage + 1,
                          )
                          : null,
                ),
              ),
              const SizedBox(width: 20),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: ComboBox<int>(
                    value: invoiceSelfViewModel.itemsPerPage,
                    items: [
                      ComboBoxItem(
                        value: 10,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Text('10 条/页'),
                        ),
                      ),
                      ComboBoxItem(
                        value: 20,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Text('20 条/页'),
                        ),
                      ),
                      ComboBoxItem(
                        value: 50,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Text('50 条/页'),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        invoiceSelfViewModel.setItemsPerPage(value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
