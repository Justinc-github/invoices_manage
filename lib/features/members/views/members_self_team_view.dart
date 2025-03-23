import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/features/members/view_models/members_view_model.dart';
import 'package:provider/provider.dart';

class MembersSelfTeamView extends StatelessWidget {
  const MembersSelfTeamView({super.key});

  @override
  Widget build(BuildContext context) {
    final membersViewModel = context.read<MembersViewModel>();

    return FutureBuilder(
      future: membersViewModel.teamSelfMumbersGet(), // 自动获取队伍信息
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: ProgressRing(), // 显示加载指示器
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('加载失败，请重试'));
        }

        final teamInfo = membersViewModel.teamInfo;

        if (teamInfo == null) {
          return const Center(child: Text('未找到队伍信息'));
        }

        return ScaffoldPage(
          padding: const EdgeInsets.all(20),
          header: PageHeader(title: const Center(child: Text('我的队伍'))),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTeamInfo(context, teamInfo),
              const SizedBox(height: 20),
              _buildTeamMembers(context, teamInfo),
            ],
          ),
        );
      },
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
                    Text('队伍名称'),
                    Text('：'),
                    Text(teamInfo.name ?? '未知队伍名称'),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('队长'),
                    Text('：'),
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

  Widget _buildTeamMembers(BuildContext context, dynamic teamInfo) {
    return Expanded(
      child: Card(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('队伍成员', style: FluentTheme.of(context).typography.subtitle),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: teamInfo.members.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final member = teamInfo.members[index];

                  // 检查 member 是否为 null
                  if (member == null) {
                    return const ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey,
                        child: Text(
                          '未知',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text('未知成员'),
                      subtitle: Text('未知角色'),
                    );
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor:
                          FluentTheme.of(context).accentColor, // 背景色
                      // 加载头像
                      child: ClipOval(
                        child:
                            (member.avatar != null && member.avatar.isNotEmpty)
                                ? Image.network(
                                  member.avatar.toString(),
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                  errorBuilder: (context, error, stackTrace) {
                                    // 网络加载失败时显示默认头像
                                    return Image.asset(
                                      'assets/images/touxiang.jpg',
                                      fit: BoxFit.cover,
                                      width: 40,
                                      height: 40,
                                    );
                                  },
                                )
                                : Image.asset(
                                  'assets/images/touxiang.jpg', // 默认头像
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
}
