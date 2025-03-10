import 'package:management_invoices/views/components/dialog_view.dart';
import 'package:provider/provider.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:management_invoices/viewModels/home_view_model.dart';

import 'package:management_invoices/views/help_view.dart';
import 'package:management_invoices/views/invoice_self_view.dart';
import 'package:management_invoices/views/components/avatar_view.dart';

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
    }
    // 监听展示登录弹窗的状态
    if (homeViewModel.isCloseLoginDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showLoginDialog(context, homeViewModel);
      });
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
            body: const _HomeContent(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.invoice),
            title: const Text('我的发票'),
            mouseCursor: SystemMouseCursors.click,
            body: const InvoiceSelfView(),
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

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [const Center(child: Text('主页')), const AvatarView()],
      ),
    );
  }
}
