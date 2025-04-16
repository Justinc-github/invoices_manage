import 'package:fluent_ui/fluent_ui.dart';
import 'package:collection/collection.dart';
import 'package:management_invoices/features/invoice/view_models/invoice_self_view_model.dart';
import 'package:management_invoices/shared/utils/mouse_cursor.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:management_invoices/core/models/invoice_self_model.dart';
import 'package:intl/intl.dart';

class InvoiceGatherView extends StatelessWidget {
  const InvoiceGatherView({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceSVM = context.watch<InvoiceSelfViewModel>();
    // 对数据进行分组并计算每个日期的总金额
    final groupedData = groupBy(
      invoiceSVM.invoiceInfos,
      (InvoiceModel invoice) => invoice.invoiceDate,
    ).map(
      (key, value) => MapEntry(
        DateTime.parse(key),
        value.fold(0.0, (sum, item) => sum + item.amountInFigures.toDouble()),
      ),
    );

    final parsedData =
        groupedData.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    // 检查 parsedData 是否为空
    if (parsedData.isEmpty) {
      return Center(
        child: Text('没有可用的数据', style: FluentTheme.of(context).typography.body),
      );
    }
    final minDate = parsedData.first.key;
    final maxDate = parsedData.last.key;

    return Stack(
      children: [
        invoiceSVM.charType == 0
            ? SfCartesianChart(
              primaryXAxis: DateTimeAxis(
                minimum: minDate.subtract(Duration(days: 5)), // 设置最小日期
                maximum: maxDate.add(Duration(days: 10)), // 将最大日期加一天
                intervalType: DateTimeIntervalType.months,
                interval: 3, // 每三个月为一个间隔
                dateFormat: DateFormat.yMMMd(), // 格式化日期显示
              ),
              title: ChartTitle(text: '发票金额折线图'),
              legend: Legend(isVisible: true),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <LineSeries<MapEntry<DateTime, double>, DateTime>>[
                LineSeries<MapEntry<DateTime, double>, DateTime>(
                  dataSource: parsedData,
                  xValueMapper:
                      (MapEntry<DateTime, double> data, _) => data.key,
                  yValueMapper:
                      (MapEntry<DateTime, double> data, _) => data.value,
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
                  dataSource:
                      groupedData.entries
                          .map((entry) {
                            // 将日期转换为季度
                            final date = entry.key;
                            final quarter = ((date.month - 1) ~/ 3) + 1; // 计算季度
                            final quarterLabel =
                                '${date.year} Q$quarter'; // 格式化季度标签
                            return MapEntry(quarterLabel, entry.value);
                          })
                          .fold<Map<String, double>>({}, (acc, entry) {
                            // 按季度分组并累加金额
                            acc[entry.key] =
                                (acc[entry.key] ?? 0) + entry.value;
                            return acc;
                          })
                          .entries
                          .toList()
                        ..sort((a, b) => a.key.compareTo(b.key)), // 按季度标签排序
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
          top: 10.0,
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
