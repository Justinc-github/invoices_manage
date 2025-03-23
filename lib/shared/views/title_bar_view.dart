import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/shared/views/avatar_view.dart';
import 'package:window_manager/window_manager.dart';

class TitleBarView extends StatelessWidget {
  final VoidCallback onThemeToggle; // 添加主题切换回调

  const TitleBarView({super.key, required this.onThemeToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (_) => windowManager.startDragging(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: FluentTheme.of(context).scaffoldBackgroundColor, // 使用整体背景颜色
          ),
          child: Stack(
            children: [
              const AvatarView(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 可拖动区域
                  Row(
                    children: [
                      SizedBox(width: 10),
                      CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            AssetImage('assets/images/icon.jpg')
                                as ImageProvider,
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 16),
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          '发票管理系统',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'MSYH',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 8),
                  // 窗口控制按钮
                  _buildWindowControls(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWindowControls() {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      child: Row(
        children: [
          // 主题切换按钮
          _WindowControlButton(
            icon: FluentIcons.brightness, // 使用亮度图标
            onPressed: onThemeToggle, // 调用主题切换回调
          ),
          _WindowControlButton(
            icon: FluentIcons.chrome_minimize,
            onPressed: windowManager.minimize,
          ),
          _WindowControlButton(
            icon: FluentIcons.chrome_full_screen,
            onPressed: () async {
              final isMaximized = await windowManager.isMaximized();
              if (isMaximized) {
                await windowManager.unmaximize();
              } else {
                await windowManager.maximize();
              }
            },
          ),
          _WindowControlButton(
            icon: FluentIcons.chrome_close,
            onPressed: windowManager.close,
            hoverColor: Colors.red,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _WindowControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? hoverColor;

  const _WindowControlButton({
    required this.icon,
    required this.onPressed,
    this.hoverColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 50,
      child: HoverButton(
        onPressed: onPressed,
        builder: (context, states) {
          return Container(
            color:
                states.isHovered
                    ? hoverColor ?? FluentTheme.of(context).accentColor
                    : Colors.transparent,
            child: Icon(
              icon,
              size: 14,
              color:
                  states.isHovered
                      ? Colors.white
                      : FluentTheme.of(context).inactiveColor,
            ),
          );
        },
      ),
    );
  }
}
