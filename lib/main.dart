import 'package:fluent_ui/fluent_ui.dart';

import 'package:management_invoices/shared/views/home_view.dart';
import 'package:management_invoices/core/config/apps_themes.dart';
import 'package:management_invoices/core/config/apps_providers.dart';

void main() async {
  await windowsinItialization();
  runApp(AppProviders(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: '发票管理系统',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeView(),
    );
  }
}
