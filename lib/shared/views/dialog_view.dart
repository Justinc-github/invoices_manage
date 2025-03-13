import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/shared/view_models/home_view_model.dart';

// 关闭确认弹窗
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
    barrierDismissible: false,
    builder: (dialogContext) {
      return ContentDialog(
        constraints: BoxConstraints(maxWidth: 300),
        title: Center(
          child: Column(
            children: [
              const Text(
                '欢迎使用系统',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '请登录以继续操作',
                style: TextStyle(fontSize: 12, color: Colors.grey[120]),
              ),
            ],
          ),
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 250),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextBox(
                controller: homeViewModel.usernameController,
                placeholder: '用户名 / 邮箱',
                enabled: !homeViewModel.isLoggingIn,
                prefix: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(FluentIcons.people, size: 18),
                ),
                style: TextStyle(
                  fontSize: 15, // 适当增大字号
                  height: 1.8, // 调整行高
                  color: Colors.grey[160],
                ),
                cursorColor: Colors.blue,
                decoration: WidgetStateProperty.resolveWith<BoxDecoration>((
                  states,
                ) {
                  return BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(width: 1.5),
                  );
                }),
              ),

              const SizedBox(height: 16),

              TextBox(
                controller: homeViewModel.passwordController,
                placeholder: '密码',
                obscureText: true,
                enabled: !homeViewModel.isLoggingIn,
                prefix: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(FluentIcons.lock, size: 20),
                ),
                style: TextStyle(
                  fontSize: 15,
                  height: 1.8,
                  letterSpacing: 1.2, // 密码字符间距
                ),
                decoration: WidgetStateProperty.resolveWith<BoxDecoration>((
                  states,
                ) {
                  return BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(width: 1.5),
                  );
                }),
              ),
              if (homeViewModel.loginError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    homeViewModel.loginError!,
                    style: TextStyle(color: Colors.red['light']),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
                  homeViewModel.isLoggingIn
                      ? null
                      : () => homeViewModel.handleLogin(context, dialogContext),
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child:
                    homeViewModel.isLoggingIn
                        ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: ProgressRing(
                                strokeWidth: 2, // 控制进度条粗细 (默认4.0)
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('登录中...'),
                          ],
                        )
                        : const Text('立即登录'),
              ),
            ),
          ),
        ],
      );
    },
  );
}
