import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/features/members/view_models/members_view_model.dart';
import 'package:management_invoices/shared/utils/mouse_cursor.dart';
import 'package:provider/provider.dart';

class MembersSelfTeamView extends StatelessWidget {
  const MembersSelfTeamView({super.key});

  @override
  Widget build(BuildContext context) {
    final membersViewModel = context.watch<MembersViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (membersViewModel.teamInfo == null && !membersViewModel.isLoading) {
        membersViewModel.teamSelfMumbersGet();
      }
    });

    // 检查加载状态
    if (membersViewModel.isLoading) {
      return const Center(
        child: ProgressRing(), // 显示加载指示器
      );
    }

    // 检查是否有队伍信息
    final teamInfo = membersViewModel.teamInfo;
    if (teamInfo == null) {
      return const Center(
        child: Text('未找到队伍信息'), // 如果加载完成但没有队伍信息，显示提示
      );
    }

    return ScaffoldPage(
      padding: const EdgeInsets.all(20),
      header: PageHeader(
        title: Stack(
          children: [
            Align(
              alignment: Alignment.center, // 强制标题居中
              child: Text('我的队伍'),
            ),
            Align(
              alignment: Alignment.centerRight, // 将按钮放在右侧
              child: MouseCursorClick(
                child: IconButton(
                  icon: const Icon(FluentIcons.refresh),
                  onPressed: () {
                    membersViewModel.teamSelfMumbersGet(); // 调用刷新方法
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTeamInfo(context, teamInfo),
          const SizedBox(height: 20),
          _buildTeamMembers(context, teamInfo, membersViewModel),
        ],
      ),
    );
  }

  Widget _buildTeamInfo(BuildContext context, dynamic teamInfo) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Card(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('队伍信息', style: FluentTheme.of(context).typography.title),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('队伍名称'),
                    const Text('：'),
                    Text(teamInfo.name ?? '未知队伍名称'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('队长'),
                    const Text('：'),
                    Text(teamInfo.headmanName ?? '未知队长'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMembers(
    BuildContext context,
    dynamic teamInfo,
    MembersViewModel membersViewModel,
  ) {
    return Expanded(
      child: Card(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    '队伍成员',
                    style: FluentTheme.of(context).typography.subtitle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: MouseCursorClick(
                    child: Button(
                      child: const Text('增加'),
                      onPressed: () {
                        _showAddMemberDialog(context, membersViewModel);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: teamInfo.members.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final member = teamInfo.members[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: FluentTheme.of(context).accentColor,
                      child: ClipOval(
                        child:
                            (member.avatar != null && member.avatar.isNotEmpty)
                                ? Image.network(
                                  member.avatar.toString(),
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/touxiang.jpg',
                                      fit: BoxFit.cover,
                                      width: 40,
                                      height: 40,
                                    );
                                  },
                                )
                                : Image.asset(
                                  'assets/images/touxiang.jpg',
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                ),
                      ),
                    ),
                    title: Text('用户名: ${member.userName ?? '未知用户名'}'),
                    subtitle: Text('角色: ${member.role ?? '未知角色'}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberDialog(
    BuildContext context,
    MembersViewModel membersViewModel,
  ) {
    // 调用获取成员信息的方法
    membersViewModel.memberInfosGet().then((_) {
      showDialog(
        context: context,
        builder: (context) {
          final allMembers = membersViewModel.membersInfos; // 获取所有成员
          return ContentDialog(
            title: const Text('添加成员'),
            content: SizedBox(
              height: 200,
              width: 400,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: allMembers.length,
                itemBuilder: (context, index) {
                  final member = allMembers[index];
                  return ListTile(
                    title: Text('用户名: ${member.username}'), // 显示用户名
                    trailing: MouseCursorClick(
                      child: Button(
                        child: const Text('添加'),
                        onPressed: () {
                          membersViewModel.teamSelfMumberAdd(
                            member.id.toString(),
                          );
                          Navigator.pop(context); // 关闭弹窗
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              MouseCursorClick(
                child: Button(
                  child: const Text('关闭'),
                  onPressed: () {
                    Navigator.pop(context); // 关闭弹窗
                  },
                ),
              ),
            ],
          );
        },
      );
    });
  }
}
