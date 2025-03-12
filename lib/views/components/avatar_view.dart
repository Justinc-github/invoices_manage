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
                radius: 25,
                backgroundImage:
                    avatarViewModel.avatarUser != null &&
                            avatarViewModel.avatarUser!.isNotEmpty
                        ? NetworkImage(avatarViewModel.avatarUser.toString())
                        : const NetworkImage(
                              'https://pcsdata.baidu.com/thumbnail/4e1e5be79v18b6e271a2209293c3fd21?fid=1102081744007-16051585-1015676301775988&rt=pr&sign=FDTAER-yUdy3dSFZ0SVxtzShv1zcMqd-DPcQgW%2B0dWeiWJDgkAz68Ldp4RI%3D&expires=48h&chkv=0&chkbd=0&chkpc=&dp-logid=484972545535073687&dp-callid=0&time=1741759200&bus_no=26&size=c1600_u1600&quality=100&vuk=-&ft=video',
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
