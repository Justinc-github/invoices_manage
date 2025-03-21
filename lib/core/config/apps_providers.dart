import 'package:provider/provider.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:management_invoices/core/repositories/auth_repository.dart';
import 'package:management_invoices/core/repositories/members_repository.dart';
import 'package:management_invoices/core/repositories/avatar_respositiory.dart';
import 'package:management_invoices/core/repositories/invoice_repository/invoice_self_respositiory.dart';
import 'package:management_invoices/core/repositories/invoice_repository/invoice_upload_respositiory.dart';

import 'package:management_invoices/features/auth/view_models/auth_view_model.dart';
import 'package:management_invoices/features/help/view_models/help_view_model.dart';
import 'package:management_invoices/features/members/view_models/members_view_model.dart';
import 'package:management_invoices/features/home/view_models/home_content_view_model.dart';
import 'package:management_invoices/features/invoice/view_models/invoice_self_view_model.dart';
import 'package:management_invoices/features/invoice/view_models/invoice_upload_view_model.dart';

import 'package:management_invoices/shared/view_models/home_view_model.dart';
import 'package:management_invoices/shared/view_models/avatar_view_model.dart';

// 全局Provider配置
class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
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

        // 发票上传
        Provider(create: (_) => InvoiceUploadRepository()),
        ChangeNotifierProvider(
          create:
              (context) => InvoiceUploadViewModel(
                context.read<InvoiceUploadRepository>(),
              ),
        ),

        // 用户登录
        Provider(create: (_) => AuthRepository()),
        ChangeNotifierProvider(
          create:
              (context) => AuthViewModel(
                context.read<AuthRepository>(),
                context.read<AvatarViewModel>(),
              ),
        ),

        // 所有用户的信息
        Provider(create: (_) => MembersRepository()),
        ChangeNotifierProvider(
          create:
              (context) => MembersViewModel(context.read<MembersRepository>()),
        ),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => HomeContentViewModel()),
        ChangeNotifierProvider(create: (_) => HelpViewModel()),
      ],
      child: child,
    );
  }
}
