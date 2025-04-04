import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/features/members/view_models/members_view_model.dart';
import 'package:management_invoices/shared/utils/mouse_cursor.dart';
import 'package:provider/provider.dart';

/// 显示用户自己队伍信息的视图
class MembersSelfTeamView extends StatelessWidget {
  const MembersSelfTeamView({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取成员视图模型
    final membersViewModel = context.watch<MembersViewModel>();

    // 在帧绘制完成后执行回调
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 如果队伍信息为空且不在加载中，则获取队伍信息
      if (membersViewModel.teamInfos.isEmpty &&
          !membersViewModel.isLoading &&
          !membersViewModel.isLoaded) {
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
    final teamInfos = membersViewModel.teamInfos;
    if (teamInfos.isEmpty) {
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
                    // 调用刷新方法
                    membersViewModel.teamSelfMumbersGet();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      content: ListView.builder(
        itemCount: teamInfos.length,
        itemBuilder: (context, index) {
          final teamInfo = teamInfos[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 构建队伍信息
                  _buildTeamInfo(context, teamInfo),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 300, // 设置固定高度
                    child: _buildTeamMembers(
                      context,
                      teamInfo,
                      membersViewModel,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建队伍信息的 UI
  Widget _buildTeamInfo(BuildContext context, dynamic teamInfo) {
    return Center(
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
    );
  }

  /// 构建队伍成员的 UI
  Widget _buildTeamMembers(
    BuildContext context,
    dynamic teamInfo,
    MembersViewModel membersViewModel,
  ) {
    // 获取当前用户 ID
    final currentUserId = membersViewModel.currentUserId;
    var isCaptain = false;

    try {
      // 查找当前用户是否在队伍中
      final currentMember = teamInfo.members.firstWhere(
        (member) => member.userId.toString() == currentUserId,
      );
      // 判断当前用户是否为队长
      isCaptain = currentMember.role == '队长';
    } catch (e) {
      debugPrint('当前用户不在该队伍中');
    }

    return Card(
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
              if (isCaptain) // 只有队长可以添加成员
                Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: MouseCursorClick(
                    child: Button(
                      child: const Text('增加'),
                      onPressed: () {
                        // 显示添加成员对话框
                        _showAddMemberDialog(
                          context,
                          membersViewModel,
                          teamInfo.id.toString(),
                        );
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
                          // 如果成员有头像，则显示网络图片，否则显示默认图片
                          (member.avatar != null && member.avatar.isNotEmpty)
                              ? Image.network(
                                member.avatar.toString(),
                                fit: BoxFit.cover,
                                width: 40,
                                height: 40,
                                // 图片加载失败时显示默认图片
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
                  // 显示成员用户名
                  title: Text('用户名: ${member.userName ?? '未知用户名'}'),
                  // 显示成员角色
                  subtitle: Text('角色: ${member.role ?? '未知角色'}'),
                  trailing:
                      // 只有队长且成员不是队长时，显示删除按钮
                      isCaptain && member.role != '队长'
                          ? MouseCursorClick(
                            child: Button(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.red.lighter,
                                ),
                              ),
                              child: const Text('删除'),
                              onPressed: () {
                                // 删除队伍成员
                                membersViewModel.teamSelfMumberDelete(
                                  member.userId.toString(),
                                  teamInfo.id.toString(),
                                );
                              },
                            ),
                          )
                          : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 显示添加成员对话框
  void _showAddMemberDialog(
    BuildContext context,
    MembersViewModel membersViewModel,
    String teamId,
  ) async {
    // 获取不在队伍中的成员信息
    await membersViewModel.fetchMembersNotInTeam(teamId);

    showDialog(
      context: context,
      builder: (context) {
        // 获取不在队伍中的所有成员
        final allMembers = membersViewModel.membersInfos;

        return ContentDialog(
          title: const Text('添加成员'),
          content: SizedBox(
            height: 250,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: allMembers.length,
              itemBuilder: (context, index) {
                final member = allMembers[index];
                return ListTile(
                  title: Text('用户名: ${member.username}'),
                  trailing: MouseCursorClick(
                    child: Button(
                      child: const Text('添加'),
                      onPressed: () {
                        // 添加成员到队伍
                        membersViewModel.teamSelfMumberAdd(
                          member.id.toString(),
                          teamId,
                        );
                        // 关闭对话框
                        Navigator.pop(context);
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
                  // 关闭对话框
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
