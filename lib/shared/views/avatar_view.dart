import 'package:flutter/material.dart' as material;
import 'package:management_invoices/shared/view_models/home_view_model.dart';

import 'package:provider/provider.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:management_invoices/shared/view_models/avatar_view_model.dart';
import 'package:management_invoices/features/auth/view_models/auth_view_model.dart';

class AvatarView extends StatelessWidget {
  const AvatarView({super.key});

  @override
  Widget build(BuildContext context) {
    final avatarViewModel = context.watch<AvatarViewModel>();
    final auth = context.watch<AuthViewModel>();
    final home = context.watch<HomeViewModel>();
    final theme = FluentTheme.of(context);
    return Positioned(
      right: 190,
      top: 6,
      child: Row(
        children: [
          if (avatarViewModel.error != null)
            InfoBar(
              title: const Text('上传失败'),
              content: Text(avatarViewModel.error!),
              severity: InfoBarSeverity.error,
              onClose: () => avatarViewModel.errorClose(),
            ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => avatarViewModel.uploadAvatar(),
              child: CircleAvatar(
                radius: 20,
                backgroundImage:
                    avatarViewModel.avatarUser != null &&
                            avatarViewModel.avatarUser!.isNotEmpty
                        ? NetworkImage(avatarViewModel.avatarUser.toString())
                        : AssetImage('assets/images/touxiang.jpg')
                            as ImageProvider,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 下拉菜单按钮
          material.PopupMenuButton<String>(
            icon: const Icon(material.Icons.expand_more, size: 28),
            color:
                theme.brightness == Brightness.dark
                    ? Colors.green['dark']
                    : Colors.white.withAlpha(150),

            offset: const Offset(0, 50), // 向下偏移 50 像素
            itemBuilder:
                (BuildContext context) => <material.PopupMenuEntry<String>>[
                  // 修改 AvatarView 中的 PopupMenuItem
                  material.PopupMenuItem<String>(
                    height: 20.0,
                    value: 'team_self',
                    child: const _MenuListTile(
                      icon: material.Icons.telegram,
                      color: material.Colors.yellowAccent,
                      title: '我的队伍',
                    ),
                    onTap: () {
                      home.updateSelectedIndex(6);
                    },
                  ),
                  material.PopupMenuItem<String>(
                    height: 20.0,
                    value: 'Logout',
                    child: const _MenuListTile(
                      icon: material.Icons.logout,
                      color: material.Colors.red,
                      title: '退出登录',
                    ),
                    onTap: () => auth.logout(context),
                  ),
                ],
          ),
        ],
      ),
    );
  }
}

class _MenuListTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;

  const _MenuListTile({
    required this.icon,
    required this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return material.ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color, size: 20),
      title: Text(title),
      mouseCursor: SystemMouseCursors.click,
    );
  }
}
