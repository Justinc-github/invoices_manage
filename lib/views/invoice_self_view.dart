import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/models/invoice_self_model.dart';
import 'package:management_invoices/viewModels/invoice_self_view_model.dart';
import 'package:management_invoices/views/components/avatar_view.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class InvoiceSelfView extends StatelessWidget {
  const InvoiceSelfView({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceSelfViewModel = context.watch<InvoiceSelfViewModel>();

    // 创建数据源
    final invoiceDataSource = InvoiceDataSource(
      invoices: invoiceSelfViewModel.invoiceInfos,
    );
    invoiceSelfViewModel.invoiceSelf();

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
              bottom: 20.0,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                return SfDataGrid(
                  columnWidthMode: ColumnWidthMode.none,
                  gridLinesVisibility: GridLinesVisibility.both,
                  headerGridLinesVisibility: GridLinesVisibility.both,
                  rowHeight: 52,
                  source: invoiceDataSource,
                  columns: [
                    GridColumn(
                      columnName: 'invoiceNum',
                      width: availableWidth * 0.2,
                      label: Center(
                        child: Text(
                          '发票ID',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'MSYH',
                          ),
                        ),
                      ),
                    ),
                    GridColumn(
                      columnName: 'invoiceType',
                      width: availableWidth * 0.15,
                      label: Center(
                        child: Text(
                          '发票类型',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'MSYH',
                          ),
                        ),
                      ),
                    ),
                    GridColumn(
                      columnName: 'invoiceDate',
                      width: availableWidth * 0.15,
                      label: Center(
                        child: Text(
                          '开票日期',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'MSYH',
                          ),
                        ),
                      ),
                    ),
                    GridColumn(
                      columnName: 'purchaserName',
                      width: availableWidth * 0.2,
                      label: Center(
                        child: Text(
                          '购买物品',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'MSYH',
                          ),
                        ),
                      ),
                    ),
                    GridColumn(
                      columnName: 'sellerName',
                      width: availableWidth * 0.2,
                      label: Center(
                        child: Text(
                          '销售者',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'MSYH',
                          ),
                        ),
                      ),
                    ),
                    GridColumn(
                      columnName: 'amountInFigures',
                      width: availableWidth * 0.1,
                      label: Center(
                        child: Text(
                          '金额',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'MSYH',
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const AvatarView(),
          Positioned(
            right: 20,
            bottom: 20,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '总金额: ¥${invoiceSelfViewModel.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InvoiceDataSource extends DataGridSource {
  InvoiceDataSource({required List<InvoiceModel> invoices}) {
    _invoices =
        invoices.map<DataGridRow>((invoice) {
          return DataGridRow(
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
              DataGridCell<double>(
                columnName: 'amountInFigures',
                value: invoice.amountInFigures,
              ),
            ],
          );
        }).toList();
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
              padding: EdgeInsets.all(8.0),
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
