import 'package:decimal/decimal.dart';
import 'package:provider/provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:management_invoices/core/models/invoice_self_model.dart';
import 'package:management_invoices/features/invoice/view_models/invoice_self_view_model.dart';
import 'package:management_invoices/features/invoice/view_models/invoice_upload_view_model.dart';

import 'package:management_invoices/shared/views/avatar_view.dart';

class InvoiceSelfView extends StatelessWidget {
  const InvoiceSelfView({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceSelfViewModel = context.watch<InvoiceSelfViewModel>();
    final invoiceUploadViewModel = context.watch<InvoiceUploadViewModel>();

    // 添加数据加载逻辑
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 当上传成功时，强制刷新数据
      if (invoiceUploadViewModel.isUploaded) {
        invoiceSelfViewModel.invoiceSelf();
        invoiceUploadViewModel.resetUploadStatus(); // 新增方法重置状态
      } else if (invoiceSelfViewModel.invoiceInfos.isEmpty &&
          !invoiceSelfViewModel.isLoading) {
        invoiceSelfViewModel.invoiceSelf();
      }
    });
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 100.0,
              left: 20.0,
              right: 20.0,
              bottom: 80.0,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final invoiceDataSource = InvoiceDataSource(
                  invoices: invoiceSelfViewModel.paginatedData,
                );

                return SfDataGrid(
                  columnWidthMode: ColumnWidthMode.fill,
                  gridLinesVisibility: GridLinesVisibility.both,
                  headerGridLinesVisibility: GridLinesVisibility.both,
                  rowHeight: 52,
                  source: invoiceDataSource,
                  columns: [
                    GridColumn(
                      columnName: 'invoiceNum',
                      label: _buildHeader('发票ID'),
                    ),
                    GridColumn(
                      columnName: 'invoiceType',
                      label: _buildHeader('发票类型'),
                    ),
                    GridColumn(
                      columnName: 'invoiceDate',
                      label: _buildHeader('开票日期'),
                    ),
                    GridColumn(
                      columnName: 'purchaserName',
                      label: _buildHeader('购买物品'),
                    ),
                    GridColumn(
                      columnName: 'sellerName',
                      label: _buildHeader('销售者'),
                    ),
                    GridColumn(
                      columnName: 'amountInFigures',
                      label: _buildHeader('金额'),
                    ),
                  ],
                );
              },
            ),
          ),
          const AvatarView(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildPaginationControls(context),
          ),
          Positioned(
            right: 15,
            bottom: 15,
            child: Text(
              '总金额: ¥${invoiceSelfViewModel.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'MSYH'),
      ),
    );
  }

  Widget _buildPaginationControls(BuildContext context) {
    final invoiceSelfViewModel = context.watch<InvoiceSelfViewModel>();

    return Container(
      color: Colors.grey[60],
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
                  icon: const Icon(FluentIcons.chevron_left),
                  onPressed:
                      invoiceSelfViewModel.currentPage > 1
                          ? () => invoiceSelfViewModel.setCurrentPage(
                            invoiceSelfViewModel.currentPage - 1,
                          )
                          : null,
                ),
              ),
              SizedBox(width: 10),
              Container(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                  '第 ${invoiceSelfViewModel.currentPage} 页 / 共 ${invoiceSelfViewModel.totalPages} 页',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 10),
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

class InvoiceDataSource extends DataGridSource {
  InvoiceDataSource({required List<InvoiceModel> invoices}) {
    _invoices =
        invoices
            .map<DataGridRow>(
              (invoice) => DataGridRow(
                cells: [
                  DataGridCell<String>(
                    columnName: 'invoiceNum',
                    value: invoice.invoiceNum,
                  ),
                  DataGridCell<String>(
                    columnName: 'invoiceType',
                    value: invoice.invoiceType,
                  ),
                  DataGridCell<String>(
                    columnName: 'invoiceDate',
                    value: invoice.invoiceDate,
                  ),
                  DataGridCell<String>(
                    columnName: 'purchaserName',
                    value: invoice.purchaserName,
                  ),
                  DataGridCell<String>(
                    columnName: 'sellerName',
                    value: invoice.sellerName,
                  ),
                  DataGridCell<Decimal>(
                    columnName: 'amountInFigures',
                    value: invoice.amountInFigures,
                  ),
                ],
              ),
            )
            .toList();
  }

  List<DataGridRow> _invoices = [];

  @override
  List<DataGridRow> get rows => _invoices;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map<Widget>((dataGridCell) {
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                dataGridCell.value.toString(),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            );
          }).toList(),
    );
  }
}
