import 'package:flutter/material.dart';
import 'package:management_invoices/features/auth/view_models/auth_view_model.dart';
import 'package:provider/provider.dart';

class LoginDialog extends StatelessWidget {
  const LoginDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 标题
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入用户名';
                }
                String usernameFormat = r'^.{2,10}$';
                RegExp regExp = RegExp(usernameFormat);
                if (!regExp.hasMatch(value)) {
                  return '用户名必须在2到10个字符之间';
                } else {
                  return null;
                }
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入密码';
                }
                String passwordFormat =
                    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$';
                RegExp regExp = RegExp(passwordFormat);
                if (!regExp.hasMatch(value)) {
                  return '密码至少为6个字符,且包含字母和数字';
                } else {
                  return null;
                }
              },
            ),
            const SizedBox(height: 24),

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
              onPressed: () => auth.login(context),
              child: const Text(
                '登 录',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
