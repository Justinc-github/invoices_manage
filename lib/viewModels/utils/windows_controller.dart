import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

Future<void> windowsinItialization() async {
  // 1. 配置窗口行为 (阻止关闭)
  await windowManager.setPreventClose(true);

  // 2. 设置视觉样式 (背景透明需搭配隐藏标题栏)
  await windowManager.setBackgroundColor(Colors.transparent);
  await windowManager.setTitleBarStyle(TitleBarStyle.normal);

  // 3. 定义窗口尺寸与约束 (先尺寸后最小尺寸)
  await windowManager.setSize(const Size(1280, 720));
  await windowManager.setMinimumSize(const Size(1280, 720)); // 固定窗口不可缩放

  // 4. 计算窗口居中位置 (依赖已设置的尺寸)
  await windowManager.center();

  // 5. 控制任务栏显示 (需在窗口显示前设置)
  await windowManager.setSkipTaskbar(false);

  // 6. 最后显示窗口 (完成所有配置后再展示)
  await windowManager.show();
}
