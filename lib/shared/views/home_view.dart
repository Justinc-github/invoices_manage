import 'package:flutter/material.dart' as material;
import 'package:management_invoices/features/invoice/views/invoice_consume_view.dart';

import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:management_invoices/features/invoice/views/invoice_gather_view.dart';
import 'package:management_invoices/features/invoice/views/invoice_other_view.dart';
import 'package:management_invoices/features/members/views/members_all_view.dart';
import 'package:management_invoices/features/members/views/members_self_team_view.dart';
import 'package:management_invoices/shared/views/title_bar_view.dart';

import 'package:management_invoices/features/invoice/view_models/invoice_self_view_model.dart';
import 'package:management_invoices/features/invoice/view_models/invoice_upload_view_model.dart';

import 'package:management_invoices/shared/views/dialog_view.dart';
import 'package:management_invoices/features/auth/views/login_view.dart';
import 'package:management_invoices/shared/view_models/home_view_model.dart';
import 'package:management_invoices/features/invoice/views/invoice_self_view.dart';
import 'package:management_invoices/features/auth/view_models/auth_view_model.dart';
import 'package:management_invoices/features/invoice/views/invoice_upload_view.dart';

class HomeView extends StatefulWidget {
  final VoidCallback onThemeToggle; // 添加主题切换回调参数

  const HomeView({super.key, required this.onThemeToggle});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final SidebarXController _controller;
  final _scaffoldKey = GlobalKey<material.ScaffoldState>();
  bool isDarkMode = false; // 添加主题状态

  @override
  void initState() {
    super.initState();
    final initialIndex = context.read<HomeViewModel>().selectedIndex;
    _controller = SidebarXController(
      selectedIndex: initialIndex,
      extended: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.select<HomeViewModel, int>(
      (homeVM) => homeVM.selectedIndex,
    );
    final isUploading = context.select<InvoiceUploadViewModel, bool>(
      (uploadVM) => uploadVM.isUploading,
    );
    final auth = context.watch<AuthViewModel>();
    final home = context.watch<HomeViewModel>();
    final invoiceSVM = context.read<InvoiceSelfViewModel>();
    _syncControllerIndex(selectedIndex);

    _handleAuthState(context, home, auth);

    return material.Scaffold(
      key: _scaffoldKey,
      backgroundColor:
          FluentTheme.of(context).scaffoldBackgroundColor, // 动态背景颜色
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 68,
                child: TitleBarView(
                  onThemeToggle: widget.onThemeToggle, // 传递回调
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      children: [
                        _buildSidebar(context, isUploading),
                        Expanded(
                          child: _buildBodyContent(
                            _controller.selectedIndex,
                            invoiceSVM.otherId.toString(),
                            invoiceSVM.userName.toString(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          // 如果正在上传，显示加载图标覆盖整个页面
          if (isUploading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.5), // 半透明背景
                child: Center(
                  child: material.CircularProgressIndicator(
                    color: FluentTheme.of(context).accentColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _syncControllerIndex(int selectedIndex) {
    if (_controller.selectedIndex != selectedIndex) {
      _controller.selectIndex(selectedIndex);
    }
  }

  void _handleAuthState(
    BuildContext context,
    HomeViewModel home,
    AuthViewModel auth,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (home.isClosing) {
        showCloseDialog(context, home);
      }
      if (auth.isDialogShow && !auth.isLoggedIn) {
        auth.dialogClose();
        showDialog(
          context: context,
          barrierColor: Color.fromARGB((0.8 * 255).round(), 0, 0, 0),
          barrierDismissible: false,
          builder: (context) => const LoginDialog(),
        );
      }
    });
  }

  Widget _buildSidebar(BuildContext context, bool isUploading) {
    return Selector<HomeViewModel, int>(
      selector: (_, vm) => vm.selectedIndex,
      builder: (_, selectedIndex, __) {
        return Container(
          decoration: BoxDecoration(
            color: FluentTheme.of(context).scaffoldBackgroundColor, // 背景颜色
            borderRadius: BorderRadius.circular(20), // 设置圆角
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25), // 阴影颜色
                blurRadius: 10, // 模糊半径
                offset: Offset(0, 5), // 阴影偏移
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20), // 确保内容也有圆角
            child: SidebarX(
              controller: _controller,
              theme: _sidebarTheme(),
              extendedTheme: const SidebarXTheme(width: 200),
              items: _sidebarItems(context, isUploading),
            ),
          ),
        );
      },
    );
  }

  SidebarXTheme _sidebarTheme() {
    final theme = FluentTheme.of(context); // 获取当前主题
    final isDarkMode = theme.brightness == Brightness.dark;

    return SidebarXTheme(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Color.alphaBlend(
                  Colors.white.withAlpha(25),
                  theme.scaffoldBackgroundColor,
                )
                : Color.alphaBlend(
                  Colors.black.withAlpha(10),
                  theme.scaffoldBackgroundColor,
                ),
        borderRadius: BorderRadius.circular(10),
      ),
      hoverColor: theme.accentColor.withAlpha(25),
      textStyle: TextStyle(color: theme.inactiveColor),
      hoverTextStyle: TextStyle(
        color: theme.accentColor, // 加深字体颜色
        fontWeight: FontWeight.bold, // 字体加粗
      ),
      selectedTextStyle: TextStyle(color: theme.accentColor),
      itemTextPadding: const EdgeInsets.only(left: 30),
      selectedItemTextPadding: const EdgeInsets.only(left: 30),
      itemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.transparent),
      ),
      selectedItemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [
            theme.accentColor.light.withAlpha(76),
            theme.accentColor.dark.withAlpha(76),
          ],
        ),
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withAlpha(25), blurRadius: 5),
        ],
      ),
      iconTheme: IconThemeData(
        color: theme.inactiveColor.withAlpha(255),
        size: 20,
      ),
    );
  }

  List<SidebarXItem> _sidebarItems(BuildContext context, bool isUploading) {
    return [
      SidebarXItem(
        icon: material.Icons.dashboard,
        label: '数据统计',
        onTap: () => _updateIndex(context, 0, false),
      ),
      SidebarXItem(
        icon: material.Icons.receipt,
        label: '我的发票',
        onTap: () => _updateIndex(context, 1, false),
      ),
      SidebarXItem(
        icon: material.Icons.upload,
        label: '发票上传',
        onTap: () => _updateIndex(context, 2, isUploading),
      ),
      SidebarXItem(
        icon: material.Icons.people,
        label: '所有成员',
        onTap: () => _updateIndex(context, 3, isUploading),
      ),

      SidebarXItem(
        icon: material.Icons.credit_card,
        label: '消费类型',
        onTap: () => _updateIndex(context, 4, false),
      ),
    ];
  }

  void _updateIndex(BuildContext context, int index, bool isUploading) {
    if (isUploading) {
      material.ScaffoldMessenger.of(context).showSnackBar(
        const material.SnackBar(
          content: Text('当前正在上传发票，请稍后操作'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    final homeVM = context.read<HomeViewModel>();
    if (index != homeVM.selectedIndex) {
      homeVM.updateSelectedIndex(index);
      _controller.selectIndex(index);
    }
  }

  Widget _buildBodyContent(int index, String otherId, String userName) {
    final invoiceSVM = context.read<InvoiceSelfViewModel>();
    if (index == 0 || index == 1 || index == 4) {
      invoiceSVM.invoiceSelf();
    }
    switch (index) {
      case 0:
        return const InvoiceGatherView();
      case 1:
        return const InvoiceSelfView();
      case 2:
        return InvoiceUploadView();
      case 3:
        return const MembersAllView();
      case 4:
        return const InvoiceConsumeView();
      case 6:
        return const MembersSelfTeamView();
      case 7:
        return InvoiceOtherView(userId: otherId, userName: userName);
      default:
        return const Center(child: Text('页面未找到'));
    }
  }
}
