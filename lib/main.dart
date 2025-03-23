import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/core/config/apps_themes.dart';
import 'package:management_invoices/core/config/apps_providers.dart';
import 'package:management_invoices/shared/views/home_view.dart';

void main() async {
  await windowsinItialization();
  runApp(AppProviders(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: '发票管理系统',
      theme: AppThemes.getTheme(isDarkMode), // 动态绑定主题
      debugShowCheckedModeBanner: false,
      home: HomeView(
        onThemeToggle: () {
          setState(() {
            isDarkMode = !isDarkMode; // 切换主题状态
          });
        },
      ),
    );
  }
}
