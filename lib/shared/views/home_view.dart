import 'package:management_invoices/features/auth/view_models/auth_view_model.dart';
import 'package:management_invoices/features/auth/views/login_view.dart';
import 'package:provider/provider.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:management_invoices/shared/views/dialog_view.dart';
import 'package:management_invoices/shared/view_models/home_view_model.dart';

import 'package:management_invoices/features/help/views/help_view.dart';
import 'package:management_invoices/features/invoice/views/invoice_self_view.dart';
import 'package:management_invoices/features/home/views/home_content_view.dart';
import 'package:management_invoices/features/invoice/views/invoice_upload_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeViewModel>();
    final auth = context.watch<AuthViewModel>();

    // 登录状态监听
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (home.isClosing) {
        showCloseDialog(context, home);
      }
      if (auth.isDialogShow && !auth.isLoggedIn) {
        debugPrint('1');
        auth.dialogClose();
        showDialog(
          context: context,
          barrierColor: Color.fromARGB(
            (0.8 * 255).round(), // Alpha 值 0-255（153 = 0.6×255）
            0, // Red
            0, // Green
            0, // Blue
          ),
          barrierDismissible: false,
          builder: (context) => const LoginDialog(),
        );
      }
    });

    return NavigationView(
      pane: NavigationPane(
        selected: home.selectedIndex,
        onChanged: home.updateSelectedIndex,
        displayMode: PaneDisplayMode.compact,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.home),
            title: const Text('首页'),
            mouseCursor: SystemMouseCursors.click,
            body: const HomeContentView(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.invoice),
            title: const Text('我的发票'),
            mouseCursor: SystemMouseCursors.click,
            body: const InvoiceSelfView(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.upload),
            title: const Text('发票上传'),
            mouseCursor: SystemMouseCursors.click,
            body: const InvoiceUploadView(),
          ),
        ],
        footerItems: [
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.help),
            title: const Text('帮助'),
            mouseCursor: SystemMouseCursors.click,
            body: const HelpView(),
          ),
        ],
        size: const NavigationPaneSize(
          openMinWidth: 150,
          openMaxWidth: 250,
          openWidth: 200,
        ),
      ),
    );
  }
}
