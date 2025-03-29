import 'package:intl/intl.dart';
import 'package:management_invoices/features/invoice/view_models/invoice_self_view_model.dart';
import 'package:management_invoices/shared/utils/mouse_cursor.dart';
import 'package:management_invoices/shared/view_models/home_view_model.dart';
import 'package:provider/provider.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:management_invoices/core/models/auth_info_model.dart';
import 'package:management_invoices/features/members/view_models/members_view_model.dart';

class MembersAllView extends StatelessWidget {
  const MembersAllView({super.key});
  @override
  Widget build(BuildContext context) {
    final membersViewModel = context.watch<MembersViewModel>();

    // 添加数据加载逻辑
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 当上传成功时，强制刷新数据
      if (membersViewModel.membersInfos.isEmpty &&
          !membersViewModel.isLoading) {
        membersViewModel.memberAllInfosGet();
      }
    });
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 10.0,
            left: 20.0,
            right: 20.0,
            bottom: 80.0,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final membersDataSource = MemberDataSource(
                memberinfos: membersViewModel.paginatedData,
                context,
              );

              return SfDataGrid(
                columnWidthMode: ColumnWidthMode.fill,
                gridLinesVisibility: GridLinesVisibility.both,
                headerGridLinesVisibility: GridLinesVisibility.both,
                rowHeight: 60,
                source: membersDataSource,
                columns: [
                  GridColumn(
                    columnName: 'userId',
                    label: _buildHeader('用户ID'),
                    width: constraints.maxWidth * 0.15,
                  ),
                  GridColumn(
                    columnName: 'username',
                    label: _buildHeader('用户名'),
                    width: constraints.maxWidth * 0.2,
                  ),
                  GridColumn(
                    columnName: 'email',
                    label: _buildHeader('邮箱'),
                    width: constraints.maxWidth * 0.25,
                  ),
                  GridColumn(
                    columnName: 'created_at',
                    label: _buildHeader('注册日期'),
                    width: constraints.maxWidth * 0.3,
                  ),
                  GridColumn(
                    columnName: 'buttons',
                    label: _buildHeader('查看发票'),
                    width: constraints.maxWidth * 0.1,
                  ),
                ],
              );
            },
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildPaginationControls(context),
        ),
      ],
    );
  }
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
  final theme = FluentTheme.of(context); // 获取当前主题
  final members = context.watch<MembersViewModel>();
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
                    members.currentPage > 1
                        ? () => members.setCurrentPage(members.currentPage - 1)
                        : null,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                '第 ${members.currentPage} 页 / 共 ${members.totalPages} 页',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: IconButton(
                icon: const Icon(FluentIcons.chevron_right),
                onPressed:
                    members.currentPage < members.totalPages
                        ? () => members.setCurrentPage(members.currentPage + 1)
                        : null,
              ),
            ),
            const SizedBox(width: 20),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: ComboBox<int>(
                  value: members.itemsPerPage,
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
                      members.setItemsPerPage(value);
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

class MemberDataSource extends DataGridSource {
  final BuildContext context; // 新增 BuildContext 属性
  MemberDataSource(this.context, {required List<AuthInfoModel> memberinfos}) {
    _memberinfos =
        memberinfos.map<DataGridRow>((memberinfo) {
          final createAt = _formatDate(memberinfo.createdAt);
          return DataGridRow(
            cells: [
              DataGridCell<String>(
                columnName: 'userId',
                value: memberinfo.id.toString(),
              ),
              DataGridCell<String>(
                columnName: 'username',
                value: memberinfo.username,
              ),
              DataGridCell<String>(
                columnName: 'email',
                value: memberinfo.email,
              ),
              DataGridCell<String>(columnName: 'created_at', value: createAt),
              DataGridCell<String>(columnName: 'buttons', value: '查看'),
            ],
          );
        }).toList();
  }

  List<DataGridRow> _memberinfos = [];

  // 新增日期格式化方法
  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '未知日期';

    try {
      final date = DateTime.parse(rawDate);
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
    } catch (e) {
      debugPrint('日期解析错误: $e');
      return '无效日期';
    }
  }

  @override
  List<DataGridRow> get rows => _memberinfos;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().asMap().entries.map<Widget>((entry) {
            final index = entry.key;
            final dataGridCell = entry.value;

            // 检查是否为最后一列
            if (index == row.getCells().length - 1) {
              return MouseCursorClick(
                child: GestureDetector(
                  onTap: () async {
                    // 获取用户ID
                    final userIdCell = row.getCells().firstWhere(
                      (cell) => cell.columnName == 'userId', // 假设用户名列存储用户ID
                    );
                    final userNameCell = row.getCells().firstWhere(
                      (cell) => cell.columnName == 'username', // 假设用户名列存储用户ID
                    );

                    final invoceSVM = Provider.of<InvoiceSelfViewModel>(
                      context,
                      listen: false,
                    );

                    final home = Provider.of<HomeViewModel>(
                      context,
                      listen: false,
                    );

                    await invoceSVM.userInvoiceSelfGet(
                      userIdCell.value,
                      userNameCell.value,
                    );
                    home.updateSelectedIndex(7);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      dataGridCell.value.toString(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ),
              );
            } else {
              return Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  dataGridCell.value.toString(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              );
            }
          }).toList(),
    );
  }
}
