import 'package:provider/provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

import 'package:management_invoices/models/repositories/auth_respositiory.dart';
import 'package:management_invoices/models/repositories/avatar_respositiory.dart';
import 'package:management_invoices/models/repositories/invoice_self_respositiory.dart';

import 'package:management_invoices/viewModels/home_view_model.dart';
import 'package:management_invoices/viewModels/invoice_self_view_model.dart';
import 'package:management_invoices/viewModels/shared/avatar_view_model.dart';

import 'package:management_invoices/viewModels/utils/windows_controller.dart';

import 'package:management_invoices/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // 等待窗口配置完成
  await windowManager.waitUntilReadyToShow();
  await windowsinItialization();

  runApp(
    MultiProvider(
      // 主页显示
      providers: [
        // 用户头像
        Provider(create: (_) => AvatarRepository()),
        ChangeNotifierProvider(
          create:
              (context) => AvatarViewModel(context.read<AvatarRepository>()),
        ),

        // 个人发票显示
        Provider(create: (_) => InvoiceSelfRespositiory()),
        ChangeNotifierProvider(
          create:
              (context) =>
                  InvoiceSelfViewModel(context.read<InvoiceSelfRespositiory>()),
        ),

        // 用户登录
        Provider(create: (_) => AuthRespositiory()),
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(context.read<AuthRespositiory>()),
        ),
      ],
      child: MyApp(),
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
