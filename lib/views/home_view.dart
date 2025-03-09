import 'package:management_invoices/views/help_view.dart';
import 'package:provider/provider.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:management_invoices/viewModels/home_view_model.dart';

import 'package:management_invoices/views/invoice_self.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.watch<HomeViewModel>();

    // 监听关闭确认弹窗的状态
    if (homeViewModel.isClosing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCloseDialog(context, homeViewModel);
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
            body: const InvoiceSelf(),
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
    return const Center(child: Text('欢迎使用发票管理系统'));
  }
}

void _showCloseDialog(BuildContext context, HomeViewModel homeViewModel) {
  showDialog(
    context: context,
    builder:
        (_) => ContentDialog(
          title: const Center(child: Text('是否关闭?')),
          content: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('请确认你的信息全部保存，避免数据丢失！')],
          ),
          actions: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: FilledButton(
                child: const Text('确认'),
                onPressed: () => homeViewModel.confirmClose(true),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: FilledButton(
                child: const Text('取消'),
                onPressed: () => homeViewModel.confirmClose(false),
              ),
            ),
          ],
        ),
  );
}
