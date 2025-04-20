import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart'
    show
        InputDecoration,
        Material,
        MaterialType,
        OutlineInputBorder,
        TextFormField;
import 'package:management_invoices/shared/utils/mouse_cursor.dart';
import 'package:provider/provider.dart';
import 'package:management_invoices/features/members/view_models/members_view_model.dart';

class TeamAdminView extends StatelessWidget {
  const TeamAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    final membersViewModel = context.watch<MembersViewModel>();
    final formKey = GlobalKey<FormState>();

    return ScaffoldPage(
      header: PageHeader(
        title: const Text('所有队伍信息', style: TextStyle(fontSize: 25)),
        commandBar: MouseCursorClick(
          child: Button(
            child: const Text('新增队伍'),
            onPressed: () {
              // 添加队伍的逻辑
              showDialog(
                context: context,
                builder:
                    (context) => ContentDialog(
                      title: const Text('新增队伍'),
                      content: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Material(
                              type: MaterialType.transparency, // 透明背景
                              child: TextFormField(
                                controller: membersViewModel.teamNameController,
                                decoration: InputDecoration(
                                  labelText: '队伍名称',
                                  prefixIcon: const Icon(FluentIcons.group),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator:
                                    (value) =>
                                        value?.isEmpty ?? true
                                            ? '请输入队伍名称'
                                            : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Material(
                              type: MaterialType.transparency, // 透明背景
                              child: TextFormField(
                                controller:
                                    membersViewModel
                                        .userIdController, // 新增用户 ID 控制器
                                decoration: InputDecoration(
                                  labelText: '用户 ID',
                                  prefixIcon: const Icon(FluentIcons.contact),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator:
                                    (value) =>
                                        value?.isEmpty ?? true
                                            ? '请输入用户 ID'
                                            : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      constraints: const BoxConstraints(
                        maxWidth: 400,
                        maxHeight: 400,
                      ),
                      actions: [
                        MouseCursorClick(
                          child: Button(
                            child: const Text('取消'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        MouseCursorClick(
                          child: FilledButton(
                            child: const Text('确认'),
                            onPressed: () async {
                              if (formKey.currentState?.validate() ?? false) {
                                final teamName =
                                    membersViewModel.teamNameController.text;
                                final userId =
                                    membersViewModel
                                        .userIdController
                                        .text; // 获取用户 ID
                                await membersViewModel.teamCreate(
                                  userId,
                                  teamName,
                                ); // 调用 ViewModel
                                Navigator.pop(context);
                                await membersViewModel
                                    .teamAllInfosGet(); // 自动重新获取队伍列表
                              }
                            },
                          ),
                        ),
                      ],
                    ),
              );
            },
          ),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (membersViewModel.isLoading)
              const Center(child: ProgressRing())
            else if (membersViewModel.errorMessage.isNotEmpty)
              InfoBar(
                title: const Text('发生错误'),
                content: Text(membersViewModel.errorMessage),
                severity: InfoBarSeverity.error,
              )
            else if (membersViewModel.teams.isEmpty)
              const Center(child: Text('暂无队伍数据'))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: membersViewModel.teams.length,
                  itemBuilder: (context, index) {
                    final team = membersViewModel.teams[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      team.name,
                                      style:
                                          FluentTheme.of(
                                            context,
                                          ).typography.subtitle,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '队长: ${team.headmanName ?? "未设置"}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text('成员 (${team.members.length}人)'),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                MouseCursorClick(
                                  child: SizedBox(
                                    height: 40.0,
                                    width: 40.0,
                                    child: Tooltip(
                                      message: '编辑队伍',
                                      child: IconButton(
                                        icon: const Icon(FluentIcons.edit),
                                        onPressed: () {
                                          // 编辑队伍逻辑
                                          showDialog(
                                            context: context,
                                            builder:
                                                (context) => ContentDialog(
                                                  title: const Text('编辑队伍'),
                                                  content: Form(
                                                    key: formKey,
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Material(
                                                          type:
                                                              MaterialType
                                                                  .transparency, // 透明背景
                                                          child: TextFormField(
                                                            controller:
                                                                membersViewModel
                                                                    .teamNameController,
                                                            decoration: InputDecoration(
                                                              labelText: '队伍名称',
                                                              prefixIcon:
                                                                  const Icon(
                                                                    FluentIcons
                                                                        .group,
                                                                  ),
                                                              border: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10,
                                                                    ),
                                                              ),
                                                            ),
                                                            autovalidateMode:
                                                                AutovalidateMode
                                                                    .onUserInteraction,
                                                            validator:
                                                                (value) =>
                                                                    value?.isEmpty ??
                                                                            true
                                                                        ? '请输入队伍名称'
                                                                        : null,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  constraints:
                                                      const BoxConstraints(
                                                        maxWidth: 400,
                                                        maxHeight: 400,
                                                      ),
                                                  actions: [
                                                    MouseCursorClick(
                                                      child: Button(
                                                        child: const Text('取消'),
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                            ),
                                                      ),
                                                    ),
                                                    MouseCursorClick(
                                                      child: FilledButton(
                                                        child: const Text('确认'),
                                                        onPressed: () async {
                                                          if (formKey
                                                                  .currentState
                                                                  ?.validate() ??
                                                              false) {
                                                            final teamName =
                                                                membersViewModel
                                                                    .teamNameController
                                                                    .text;
                                                            await membersViewModel
                                                                .teamUpload(
                                                                  team.id
                                                                      .toString(),
                                                                  teamName,
                                                                ); // 调用 ViewModel
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                            await membersViewModel
                                                                .teamAllInfosGet(); // 自动重新获取队伍列表
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                MouseCursorClick(
                                  child: SizedBox(
                                    height: 40.0,
                                    width: 40.0,
                                    child: Tooltip(
                                      message: '删除队伍',
                                      child: IconButton(
                                        icon: const Icon(FluentIcons.delete),
                                        onPressed: () {
                                          // 删除队伍逻辑
                                          showDialog(
                                            context: context,
                                            builder:
                                                (context) => ContentDialog(
                                                  title: const Text('删除队伍'),
                                                  content: const Text(
                                                    '确认删除该队伍吗？',
                                                  ),
                                                  actions: [
                                                    MouseCursorClick(
                                                      child: Button(
                                                        child: const Text('取消'),
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                            ),
                                                      ),
                                                    ),
                                                    MouseCursorClick(
                                                      child: FilledButton(
                                                        child: const Text('确认'),
                                                        onPressed: () async {
                                                          await membersViewModel
                                                              .teamDelete(
                                                                team.id
                                                                    .toString(),
                                                              );
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          // 重新获取队伍列表
                                                          await membersViewModel
                                                              .teamAllInfosGet();
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (team.members.isEmpty)
                              const Text(
                                '暂无成员',
                                style: TextStyle(color: Colors.grey),
                              )
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    team.members.map<Widget>((member) {
                                      return Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircleAvatar(
                                              radius: 15,
                                              backgroundImage: NetworkImage(
                                                member.avatar,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(member.userName),
                                                Text(
                                                  member.role,
                                                  style: TextStyle(
                                                    color:
                                                        member.role == '队长'
                                                            ? Colors.blue
                                                            : Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                              ),
                          ],
                        ),
                      ),
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
