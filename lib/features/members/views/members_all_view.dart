import 'package:intl/intl.dart';
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
              );

              return SfDataGrid(
                columnWidthMode: ColumnWidthMode.fill,
                gridLinesVisibility: GridLinesVisibility.both,
                headerGridLinesVisibility: GridLinesVisibility.both,
                rowHeight: 52,
                source: membersDataSource,
                columns: [
                  GridColumn(
                    columnName: 'username',
                    label: _buildHeader('用户名'),
                  ),
                  GridColumn(columnName: 'email', label: _buildHeader('邮箱')),

                  GridColumn(
                    columnName: 'created_at',
                    label: _buildHeader('注册日期'),
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
  final membersViewModel = context.watch<MembersViewModel>();

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
                    membersViewModel.currentPage > 1
                        ? () => membersViewModel.setCurrentPage(
                          membersViewModel.currentPage - 1,
                        )
                        : null,
              ),
            ),
            SizedBox(width: 10),
            Container(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                '第 ${membersViewModel.currentPage} 页 / 共 ${membersViewModel.totalPages} 页',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 10),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: IconButton(
                icon: const Icon(FluentIcons.chevron_right),
                onPressed:
                    membersViewModel.currentPage < membersViewModel.totalPages
                        ? () => membersViewModel.setCurrentPage(
                          membersViewModel.currentPage + 1,
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
                  value: membersViewModel.itemsPerPage,
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
                      membersViewModel.setItemsPerPage(value);
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
  MemberDataSource({required List<AuthInfoModel> memberinfos}) {
    _memberinfos =
        memberinfos.map<DataGridRow>((memberinfo) {
          final createAt = _formatDate(memberinfo.createdAt);
          return DataGridRow(
            cells: [
              DataGridCell<String>(
                columnName: 'username',
                value: memberinfo.username,
              ),
              DataGridCell<String>(
                columnName: 'email',
                value: memberinfo.email,
              ),
              DataGridCell<String>(columnName: 'created_at', value: createAt),
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
