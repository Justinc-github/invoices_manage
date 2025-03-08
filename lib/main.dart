import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitle("发票管理系统");
    await windowManager.setPreventClose(true); // 设置为true以防止直接关闭
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    await windowManager.setBackgroundColor(Colors.transparent);
    // await windowManager.setSize(const Size(1500, 680));
    // await windowManager.setMinimumSize(const Size(1500, 680));
    await windowManager.center();
    await windowManager.show();
    await windowManager.setSkipTaskbar(false); // 显示在任务栏
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: '发票管理系统',
      theme: FluentThemeData(
        brightness: Brightness.light,
        accentColor: Colors.orange,
      ),
      darkTheme: FluentThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.orange,
      ),
      home: const MyHomePage(title: '主页'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  final viewKey = GlobalKey();
  int _selectedIndex = 0;
  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      pane: NavigationPane(
        selected: _selectedIndex,
        onChanged: (index) => setState(() => _selectedIndex = index),
        displayMode: PaneDisplayMode.compact,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.home),
            title: const Text('首页'),
            mouseCursor: SystemMouseCursors.click,
            body: const Center(child: Text('首页内容')),
          ),
        ],
        footerItems: [
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.help),
            title: const Text('帮助'),
            mouseCursor: SystemMouseCursors.click,
            body: const Center(child: Text('帮助内容')),
          ),
        ],
        size: const NavigationPaneSize(openWidth: 150),
      ),
    );
  }

  // 关闭窗口确认弹窗
  @override
  void onWindowClose() async {
    bool isClose = await windowManager.isPreventClose();
    if (isClose) {
      showDialog(
        context: context,
        builder: (_) {
          return ContentDialog(
            title: const Center(child: Text('确认关闭?')),
            content: const Text('你是否想关闭发票管理系统应用?请确认您的信息已全部保存'),
            actions: [
              FilledButton(
                child: const Text('是的'),
                onPressed: () {
                  Navigator.pop(context);
                  windowManager.destroy();
                },
              ),
              FilledButton(
                child: const Text('取消'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
    super.onWindowClose();
  }
}
