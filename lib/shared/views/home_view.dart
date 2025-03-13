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
    final homeViewModel = context.watch<HomeViewModel>();

    // 监听关闭确认弹窗的状态
    if (homeViewModel.isClosing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCloseDialog(context, homeViewModel);
      });
    } else {
      // 监听展示登录弹窗的状态
      if (homeViewModel.isCloseLoginDialog) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showLoginDialog(context, homeViewModel);
        });
      }
    }

    return NavigationView(
      pane: NavigationPane(
        selected: homeViewModel.selectedIndex,
        onChanged: homeViewModel.updateSelectedIndex,
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
