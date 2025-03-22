import 'package:flutter/material.dart';
import 'package:management_invoices/features/auth/views/register_view.dart';
import 'package:management_invoices/features/auth/views/retrieve_view.dart';
import 'package:provider/provider.dart';
import 'package:management_invoices/features/auth/view_models/auth_view_model.dart';

class LoginDialog extends StatelessWidget {
  const LoginDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthViewModel>();

    // 每次打开弹窗时重置状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      auth.resetLoginFields();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      auth.resetLoginFields();
      // 新增：自动填充找回的用户名
      if (auth.retrieveUsername != null) {
        auth.usernameController.text = auth.retrieveUsername!;
        auth.isLoginUsernameValid = true; // 触发验证状态更新
      }
    });

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 300),
        child: Consumer<AuthViewModel>(
          builder: (context, auth, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '用户登录',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // 用户名输入
                TextFormField(
                  controller: auth.usernameController,
                  decoration: InputDecoration(
                    labelText: '用户名',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator:
                      (value) => value?.isEmpty ?? true ? '请输入用户名' : null,
                  onChanged: (value) {
                    auth.isLoginUsernameValid = value.isNotEmpty;
                  },
                ),
                const SizedBox(height: 16),

                // 密码输入
                TextFormField(
                  controller: auth.passwordController,
                  decoration: InputDecoration(
                    labelText: '密码',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  obscureText: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => value?.isEmpty ?? true ? '请输入密码' : null,
                  onChanged: (value) {
                    auth.isLoginPasswordValid = value.isNotEmpty;
                  },
                ),
                const SizedBox(height: 16),

                // 错误信息
                if (auth.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      auth.errorMessage!,
                      style: TextStyle(color: Colors.red[700], fontSize: 14),
                    ),
                  ),

                // 加载指示器
                if (auth.isLoading)
                  const LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: Colors.grey,
                  ),

                const SizedBox(height: 16),

                // 登录按钮
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed:
                      auth.isLoginUsernameValid && auth.isLoginPasswordValid
                          ? () => auth.login(context)
                          : null,
                  child: const Text(
                    '登 录',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),

                // 注册链接
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const RegisterDialog(),
                        );
                      },
                      child: Text(
                        '立即注册',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Text('|'),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const RetrieveDialog(),
                        );
                      },
                      child: Text(
                        '忘记密码',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
