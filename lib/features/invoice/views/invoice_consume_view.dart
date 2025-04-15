import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/core/models/invoice_self_model.dart';
import 'package:management_invoices/features/invoice/view_models/invoice_self_view_model.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class InvoiceConsumeView extends StatelessWidget {
  const InvoiceConsumeView({super.key});
  @override
  Widget build(BuildContext context) {
    final invoiceSVM = context.watch<InvoiceSelfViewModel>();
    final groupedData = groupBy(
      invoiceSVM.invoiceInfos,
      (InvoiceModel invoice) => invoice.serviceType,
    ).map((key, value) => MapEntry(key, value.length));
    return Stack(
      children: [
        SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          title: ChartTitle(text: '发票消费类型分布图'),
          legend: Legend(isVisible: false),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <ColumnSeries<MapEntry<String, int>, String>>[
            ColumnSeries<MapEntry<String, int>, String>(
              dataSource: groupedData.entries.toList(),
              xValueMapper: (MapEntry<String, int> data, _) => data.key,
              yValueMapper: (MapEntry<String, int> data, _) => data.value,
              name: '消费类型',
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
      ],
    );
  }
}
