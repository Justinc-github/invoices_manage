import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/viewModels/home_view_model.dart';

void showCloseDialog(BuildContext context, HomeViewModel homeViewModel) {
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
                onPressed: () => homeViewModel.confirmClose(context, true),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: FilledButton(
                child: const Text('取消'),
                onPressed: () => homeViewModel.confirmClose(context, false),
              ),
            ),
          ],
        ),
  );
}

void showLoginDialog(BuildContext context, HomeViewModel homeViewModel) {
  showDialog(
    context: context,
    barrierDismissible: false, // 禁止点击外部关闭
    builder:
        (context) => ContentDialog(
          title: Center(child: const Text('请登录后使用该系统')),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextBox(
                  controller: homeViewModel.usernameController,
                  placeholder: '用户名',
                  enabled: !homeViewModel.isLoggingIn,
                ),
                const SizedBox(height: 12),
                TextBox(
                  controller: homeViewModel.passwordController,
                  placeholder: '密码',
                  obscureText: true,
                  enabled: !homeViewModel.isLoggingIn,
                ),
                if (homeViewModel.loginError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      homeViewModel.loginError!,
                      style: TextStyle(color: Colors.red.dark),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed:
                  homeViewModel.isLoggingIn
                      ? null
                      : () => homeViewModel.handleLogin(),
              style: ButtonStyle(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (homeViewModel.isLoggingIn)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: ProgressRing(strokeWidth: 2),
                    ),
                  Text(homeViewModel.isLoggingIn ? '登录中...' : '登录'),
                ],
              ),
            ),
          ],
        ),
  );
}
