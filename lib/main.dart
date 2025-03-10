import 'package:provider/provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

import 'package:management_invoices/models/repositories/avatar_repositiory.dart';
import 'package:management_invoices/models/repositories/invoice_self_respositiory.dart';

import 'package:management_invoices/viewModels/home_view_model.dart';
import 'package:management_invoices/viewModels/shared/avatar_view_model.dart';
import 'package:management_invoices/viewModels/utils/windows_controller.dart';
import 'package:management_invoices/viewModels/invoice_self_view_model.dart';

import 'package:management_invoices/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // 等待窗口配置完成
  await windowManager.waitUntilReadyToShow();
  await windowsinItialization();

  runApp(
    MultiProvider(
      // 监听HomeViewModel状态变化
      providers: [
        // 用户头像
        Provider(create: (_) => AvatarRepository()),
        ChangeNotifierProvider(
          create:
              (context) => AvatarViewModel(
                context.read<AvatarRepository>(), // 从已注册的 Repository 获取实例
              ),
        ),

        // 个人发票显示
        Provider(create: (_) => InvoiceSelfRespositiory()),
        ChangeNotifierProvider(
          create:
              (context) =>
                  InvoiceSelfViewModel(context.read<InvoiceSelfRespositiory>()),
        ),

        // 主页监视
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: '发票管理系统',
      theme: FluentThemeData(
        brightness: Brightness.light,
        fontFamily: 'MSYH',
        accentColor: Colors.blue,
      ),
      darkTheme: FluentThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.orange,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeView(),
    );
  }
}
