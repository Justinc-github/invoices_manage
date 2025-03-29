// retrieve_view.dart
import 'package:flutter/material.dart';
import 'package:management_invoices/features/auth/view_models/auth_view_model.dart';
import 'package:management_invoices/features/auth/views/login_view.dart';
import 'package:management_invoices/features/auth/views/register_view.dart';
import 'package:management_invoices/shared/utils/login_text_style.dart';
import 'package:provider/provider.dart';

class RetrieveDialog extends StatelessWidget {
  const RetrieveDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Consumer<AuthViewModel>(
          builder: (context, auth, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RetrieveStepIndicator(step: auth.retrieveStep),
                const SizedBox(height: 24),
                if (auth.retrieveStep == 1) _RetrieveStep1(auth: auth),
                if (auth.retrieveStep == 2) _RetrieveStep2(auth: auth),
              ],
            );
          },
        ),
      ),
    );
  }
}

// 步骤指示器组件（复用注册流程的样式）
class _RetrieveStepIndicator extends StatelessWidget {
  final int step;

  const _RetrieveStepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepCircle(number: 1, isActive: step >= 1),
        const _StepConnector(),
        _StepCircle(number: 2, isActive: step >= 2),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int number;
  final bool isActive;

  const _StepCircle({required this.number, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          "$number",
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  const _StepConnector();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 2,
      color: Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

// 第一步：邮箱验证
class _RetrieveStep1 extends StatelessWidget {
  final AuthViewModel auth;

  const _RetrieveStep1({required this.auth});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: auth.emailController,
          decoration: _inputDecoration('注册邮箱', Icons.email),
          keyboardType: TextInputType.emailAddress,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateEmail,
          onChanged:
              (value) => auth.isEmailValid = _validateEmail(value) == null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: auth.codeController,
                decoration: _inputDecoration('验证码', Icons.sms),
                keyboardType: TextInputType.number,
                validator: _validateVerificationCode,
                onChanged:
                    (value) =>
                        auth.isCodeValid =
                            _validateVerificationCode(value) == null,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor:
                      auth.isCodeSent
                          ? Colors.grey[300]
                          : Theme.of(context).primaryColor,
                ),
                onPressed:
                    auth.isEmailValid && !auth.isCodeSent
                        ? () => auth.sendPasswordResetCode()
                        : null,
                child: Text(
                  auth.isCodeSent ? '${auth.countdown}秒后重发' : '获取验证码',
                  style: TextStyle(
                    color: auth.isCodeSent ? Colors.grey : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _ErrorDisplay(auth: auth),
        ElevatedButton(
          onPressed:
              auth.isEmailValid && auth.isCodeValid
                  ? () => auth.verifyCodeRetrieveCode(context)
                  : null,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text('下一步'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoginTextStyle(
              key: Key('登录'),
              text: '立即登录',
              child: const LoginDialog(),
            ),
            const Text('|'),
            LoginTextStyle(
              key: Key('注册'),
              text: '立即注册',
              child: const RegisterDialog(),
            ),
          ],
        ),
      ],
    );
  }
}

// 第二步：设置新密码
class _RetrieveStep2 extends StatelessWidget {
  final AuthViewModel auth;

  const _RetrieveStep2({required this.auth});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: auth.newPasswordController,
          decoration: _inputDecoration('新密码(至少6位，包含字母和数字)', Icons.lock),
          obscureText: true,
          validator: _validatePassword,
          onChanged: (value) {
            auth.isNewPasswordValid = _validatePassword(value) == null;
            auth.isConfirmNewPasswordValid =
                _validateConfirmPassword(
                  auth.confirmNewPasswordController.text,
                  auth.newPasswordController.text,
                ) ==
                null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: auth.confirmNewPasswordController,
          decoration: _inputDecoration('确认新密码', Icons.lock_outline),
          obscureText: true,
          validator:
              (value) => _validateConfirmPassword(
                value,
                auth.newPasswordController.text,
              ),
          onChanged:
              (value) =>
                  auth.isConfirmNewPasswordValid =
                      _validateConfirmPassword(
                        value,
                        auth.newPasswordController.text,
                      ) ==
                      null,
        ),
        const SizedBox(height: 24),
        _ErrorDisplay(auth: auth),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => auth.resetRetrieveProcess(),
                child: const Text('上一步'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed:
                    auth.isNewPasswordValid && auth.isConfirmNewPasswordValid
                        ? () => auth.resetPassword(context)
                        : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('提交'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// 错误提示组件（复用注册流程的样式）
class _ErrorDisplay extends StatelessWidget {
  final AuthViewModel auth;

  const _ErrorDisplay({required this.auth});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: auth.errorMessage != null,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          auth.errorMessage ?? '',
          style: const TextStyle(color: Colors.red, fontSize: 14),
        ),
      ),
    );
  }
}

// 输入框样式（复用注册流程的样式）
InputDecoration _inputDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.grey),
    ),
  );
}

// 验证方法（复用注册流程的验证逻辑）
String? _validateEmail(String? value) {
  if (value == null || value.isEmpty) return '请输入邮箱地址';
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return '邮箱格式不正确';
  }
  return null;
}

String? _validateVerificationCode(String? value) =>
    value == null || value.isEmpty ? '请输入验证码' : null;

String? _validatePassword(String? value) {
  if (value == null || value.isEmpty) return '请输入密码';
  if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$').hasMatch(value)) {
    return '至少6位，包含字母和数字';
  }
  return null;
}

String? _validateConfirmPassword(String? value, String password) {
  return value == password ? null : '两次输入的密码不一致';
}
