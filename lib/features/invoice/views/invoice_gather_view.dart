import 'package:fluent_ui/fluent_ui.dart';
import 'package:collection/collection.dart';
import 'package:management_invoices/features/invoice/view_models/invoice_self_view_model.dart';
import 'package:management_invoices/shared/utils/mouse_cursor.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:management_invoices/core/models/invoice_self_model.dart';

class InvoiceGatherView extends StatelessWidget {
  const InvoiceGatherView({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceSVM = context.watch<InvoiceSelfViewModel>();
    if (!invoiceSVM.isLoadingCharType) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        invoiceSVM.invoiceSelf();
      });
    }
    // 对数据进行分组并计算每个日期的总金额
    final groupedData = groupBy(
      invoiceSVM.invoiceInfos,
      (InvoiceModel invoice) => invoice.invoiceDate,
    ).map(
      (key, value) => MapEntry(
        key,
        value.fold(0.0, (sum, item) => sum + item.amountInFigures.toDouble()),
      ),
    );

    return Stack(
      children: [
        invoiceSVM.charType == 0
            ? SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              title: ChartTitle(text: '发票金额折线图'),
              legend: Legend(isVisible: true),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <LineSeries<MapEntry<String, double>, String>>[
                LineSeries<MapEntry<String, double>, String>(
                  dataSource: groupedData.entries.toList(),
                  xValueMapper: (MapEntry<String, double> data, _) => data.key,
                  yValueMapper:
                      (MapEntry<String, double> data, _) => data.value,
                  name: '金额',
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(
                      color:
                          FluentTheme.of(
                            context,
                          ).typography.body?.color, // 动态获取文字颜色
                    ),
                  ),
                ),
              ],
            )
            : SfCircularChart(
              title: ChartTitle(text: '发票金额饼状图'),
              legend: Legend(isVisible: true),
              series: <PieSeries<MapEntry<String, double>, String>>[
                PieSeries<MapEntry<String, double>, String>(
                  dataSource: groupedData.entries.toList(),
                  xValueMapper: (MapEntry<String, double> data, _) => data.key,
                  yValueMapper:
                      (MapEntry<String, double> data, _) => data.value,
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(
                      color:
                          FluentTheme.of(
                            context,
                          ).typography.body?.color, // 动态获取文字颜色
                    ),
                  ),
                ),
              ],
            ),
        Positioned(
          bottom: 20.0,
          right: 10.0,
          child: MouseCursorClick(
            child: ComboBox<int>(
              value: invoiceSVM.charType,
              items: [
                ComboBoxItem(
                  value: 0,
                  child: MouseCursorClick(child: Text('折线图')),
                ),
                ComboBoxItem(
                  value: 1,
                  child: MouseCursorClick(child: Text('饼状图')),
                ),
              ],
              onChanged: (int? newValue) {
                if (newValue != null) {
                  invoiceSVM.charTypeChange(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
