import 'package:provider/provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:management_invoices/viewModels/shared/avatar_view_model.dart';

class AvatarView extends StatelessWidget {
  const AvatarView({super.key});

  @override
  Widget build(BuildContext context) {
    final avatarViewModel = context.watch<AvatarViewModel>();
    return Positioned(
      right: 20,
      top: 20,
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
                radius: 30,
                backgroundImage:
                    avatarViewModel.avatarUser != null &&
                            avatarViewModel.avatarUser!.isNotEmpty
                        ? NetworkImage(avatarViewModel.avatarUser.toString())
                        : const NetworkImage(
                              'https://admin-invoice-oss.oss-cn-beijing.aliyuncs.com/%E5%A4%B4%E5%83%8F.jpg',
                            )
                            as ImageProvider,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 下拉菜单按钮
          material.PopupMenuButton<String>(
            icon: const Icon(material.Icons.expand_more, size: 28),

            itemBuilder:
                (BuildContext context) => <material.PopupMenuEntry<String>>[
                  material.PopupMenuItem<String>(
                    value: 'Logout',
                    child: const _MenuListTile(
                      icon: material.Icons.logout,
                      color: material.Colors.red,
                      title: '退出登录',
                    ),
                    onTap: () => avatarViewModel.toggleLoginStatus(context),
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
