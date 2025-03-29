import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

/// 主题配置
class AppThemes {
  static final FluentThemeData lightTheme = _buildTheme(
    brightness: Brightness.light,
    accentColor: AccentColor.swatch({
      'normal': Colors.blue, // 定义主色
    }),
    scaffoldBackgroundColor: Colors.white,
    textColor: Colors.black,
    buttonBackgroundColor: Colors.blue.lightest,
    buttonForegroundColor: Colors.black,
  );

  static final FluentThemeData darkTheme = _buildTheme(
    brightness: Brightness.dark,
    accentColor: AccentColor.swatch({
      'normal': Colors.teal, // 定义主色
    }),
    scaffoldBackgroundColor: Colors.grey[190],
    textColor: Colors.white,
    buttonBackgroundColor: Colors.teal.darkest,
    buttonForegroundColor: Colors.white,
  );

  /// 动态切换主题
  static FluentThemeData getTheme(bool isDarkMode) {
    return isDarkMode ? darkTheme : lightTheme;
  }

  /// 构建主题方法
  static FluentThemeData _buildTheme({
    required Brightness brightness,
    required AccentColor accentColor,
    required Color scaffoldBackgroundColor,
    required Color textColor,
    required Color buttonBackgroundColor,
    required Color buttonForegroundColor,
  }) {
    return FluentThemeData(
      brightness: brightness,
      fontFamily: 'MSYH', // 统一字体
      accentColor: accentColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      buttonTheme: ButtonThemeData(
        defaultButtonStyle: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(buttonBackgroundColor),
          foregroundColor: WidgetStateProperty.all(buttonForegroundColor),
        ),
      ),
      typography: Typography.raw(
        caption: TextStyle(fontSize: 12, color: textColor.withAlpha(180)),
        body: TextStyle(fontSize: 14, color: textColor),
        title: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// 样式配置
class AppStyles {
  /// 主按钮样式
  static ButtonStyle primaryButtonStyle(BuildContext context) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.all(
        FluentTheme.of(context).accentColor,
      ),
      foregroundColor: WidgetStateProperty.all(Colors.white),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// 卡片样式
  static BoxDecoration cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: FluentTheme.of(context).scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(50),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// 标题文本样式
  static TextStyle titleTextStyle(BuildContext context) {
    return FluentTheme.of(
      context,
    ).typography.title!.copyWith(fontWeight: FontWeight.bold, fontSize: 20);
  }

  /// 正文文本样式
  static TextStyle bodyTextStyle(BuildContext context) {
    return FluentTheme.of(context).typography.body!.copyWith(
      fontSize: 14,
      color: FluentTheme.of(context).typography.body?.color?.withAlpha(180),
    );
  }

  /// 间距配置
  static const EdgeInsets pagePadding = EdgeInsets.all(16);
  static const EdgeInsets cardPadding = EdgeInsets.all(12);
  static const SizedBox verticalSpacing = SizedBox(height: 16);
  static const SizedBox horizontalSpacing = SizedBox(width: 16);
}

/// 窗口初始化
Future<void> windowsinItialization() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    backgroundColor: Colors.transparent, // 确保背景透明
    skipTaskbar: false, // 不显示标题栏
    titleBarStyle: TitleBarStyle.hidden, // 隐藏标题栏
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setPreventClose(true);
    await windowManager.center();
    await windowManager.setAsFrameless(); // 设置无边框
    await windowManager.show();
    await windowManager.focus();
  });
}
