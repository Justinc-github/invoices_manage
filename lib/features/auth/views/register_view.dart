import 'package:flutter/material.dart';
import 'package:management_invoices/features/auth/views/login_view.dart';
import 'package:management_invoices/shared/utils/login_text_style.dart';
import 'package:provider/provider.dart';
import 'package:management_invoices/features/auth/view_models/auth_view_model.dart';

class RegisterDialog extends StatelessWidget {
  const RegisterDialog({super.key});

  @override
  Widget build(BuildContext context) {
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
                const _StepIndicator(),
                const SizedBox(height: 24),
                _RegistrationContent(auth: auth),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 步骤指示器组件
class _StepIndicator extends StatelessWidget {
  const _StepIndicator();

  @override
  Widget build(BuildContext context) {
    final currentStep = context.select<AuthViewModel, int>(
      (auth) => auth.registerStep,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepCircle(number: 1, isActive: currentStep >= 1),
        const _StepConnector(),
        _StepCircle(number: 2, isActive: currentStep >= 2),
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

/// 动态内容区域
class _RegistrationContent extends StatelessWidget {
  final AuthViewModel auth;

  const _RegistrationContent({required this.auth});

  @override
  Widget build(BuildContext context) {
    return auth.registerStep == 1
        ? _EmailVerificationStep(auth: auth)
        : _AccountSetupStep(auth: auth);
  }
}

/// 邮箱验证步骤
class _EmailVerificationStep extends StatelessWidget {
  final AuthViewModel auth;

  const _EmailVerificationStep({required this.auth});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EmailInput(auth: auth),
        const SizedBox(height: 16),
        _VerificationCodeRow(auth: auth),
        const SizedBox(height: 24),
        _ErrorDisplay(auth: auth),
        _NextStepButton(auth: auth),
      ],
    );
  }
}

/// 账户设置步骤
class _AccountSetupStep extends StatelessWidget {
  final AuthViewModel auth;

  const _AccountSetupStep({required this.auth});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SetupTitle(),
        const SizedBox(height: 24),
        _UsernameInput(auth: auth),
        const SizedBox(height: 16),
        _PasswordInput(auth: auth),
        const SizedBox(height: 16),
        _ConfirmPasswordInput(auth: auth),
        const SizedBox(height: 24),
        _ErrorDisplay(auth: auth),
        _RegisterButton(auth: auth),
        const SizedBox(width: 24),
        _BackToEmailButton(auth: auth),
      ],
    );
  }
}

// 邮箱验证步骤的子组件
class _EmailInput extends StatelessWidget {
  final AuthViewModel auth;

  const _EmailInput({required this.auth});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: auth.emailController,
      decoration: _inputDecoration('邮箱', Icons.email),
      keyboardType: TextInputType.emailAddress,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: _validateEmail,
      onChanged: (value) => auth.isEmailValid = _validateEmail(value) == null,
    );
  }
}

class _VerificationCodeRow extends StatelessWidget {
  final AuthViewModel auth;

  const _VerificationCodeRow({required this.auth});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: auth.codeController,
            decoration: _inputDecoration('验证码', Icons.sms),
            keyboardType: TextInputType.number,
            validator: _validateVerificationCode,
            onChanged:
                (value) =>
                    auth.isCodeValid = _validateVerificationCode(value) == null,
          ),
        ),
        const SizedBox(width: 12),
        _VerificationCodeButton(auth: auth),
      ],
    );
  }
}

class _VerificationCodeButton extends StatelessWidget {
  final AuthViewModel auth;

  const _VerificationCodeButton({required this.auth});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor:
              auth.isCodeSent
                  ? Colors.grey[300]
                  : Theme.of(context).primaryColor,
        ),
        onPressed: auth.isCodeSent ? null : () => auth.sendVerificationCode(),
        child: Text(
          auth.isCodeSent ? '${auth.countdown}秒后重发' : '获取验证码',
          style: TextStyle(color: auth.isCodeSent ? Colors.grey : Colors.white),
        ),
      ),
    );
  }
}

class _NextStepButton extends StatelessWidget {
  final AuthViewModel auth;

  const _NextStepButton({required this.auth});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48), // 关键修改
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed:
              auth.isEmailValid && auth.isCodeValid
                  ? () => auth.verifyCode(context)
                  : null,
          child: const Text(
            '下一步',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('已有账号？'),
            LoginTextStyle(text: '立即登录', child: const LoginDialog()),
          ],
        ),
      ],
    );
  }
}

// 账户设置步骤的子组件
class _SetupTitle extends StatelessWidget {
  const _SetupTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '设置账户信息',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class _UsernameInput extends StatelessWidget {
  final AuthViewModel auth;

  const _UsernameInput({required this.auth});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: auth.usernameController,
      decoration: _inputDecoration('用户名（2-10个字符）', Icons.person),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: _validateUsername,
      onChanged:
          (value) => auth.isUsernameValid = _validateUsername(value) == null,
    );
  }
}

class _PasswordInput extends StatelessWidget {
  final AuthViewModel auth;

  const _PasswordInput({required this.auth});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: auth.passwordController,
      decoration: _inputDecoration('设置密码', Icons.lock),
      obscureText: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: _validatePassword,
      onChanged: (value) {
        auth.isPasswordValid = _validatePassword(value) == null;
        final confirmValid =
            _validateConfirmPassword(
              auth.confirmPasswordController.text,
              auth,
            ) ==
            null;
        auth.isConfirmPasswordValid = confirmValid;
      },
    );
  }
}

class _ConfirmPasswordInput extends StatelessWidget {
  final AuthViewModel auth;

  const _ConfirmPasswordInput({required this.auth});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: auth.confirmPasswordController,
      decoration: _inputDecoration('确认密码', Icons.lock_outline),
      obscureText: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged:
          (value) =>
              auth.isConfirmPasswordValid =
                  _validateConfirmPassword(value, auth) == null,
      validator: (value) => _validateConfirmPassword(value, auth),
    );
  }
}

class _RegisterButton extends StatelessWidget {
  final AuthViewModel auth;

  const _RegisterButton({required this.auth});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed:
          auth.isUsernameValid &&
                  auth.isPasswordValid &&
                  auth.isConfirmPasswordValid
              ? () => auth.register(context)
              : null,
      child: const Text(
        '注 册',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _BackToEmailButton extends StatelessWidget {
  final AuthViewModel auth;

  const _BackToEmailButton({required this.auth});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => auth.resetRegistration(),
          child: Text(
            '返回上一步',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
        Row(
          children: [
            const Text('已有账号？'),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 关闭登录对话框
                showDialog(
                  context: context,
                  barrierDismissible: false, // 阻止点击外部关闭
                  builder: (context) => const LoginDialog(),
                );
              },
              child: Text(
                '立即登录',
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
  }
}

// 通用组件
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

// 样式工具方法
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

// 验证方法
String? _validateEmail(String? value) {
  if (value == null || value.isEmpty) return '请输入邮箱地址';
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return '邮箱格式不正确';
  }
  return null;
}

String? _validateVerificationCode(String? value) =>
    value == null || value.isEmpty ? '请输入验证码' : null;

String? _validateUsername(String? value) {
  if (value == null || value.isEmpty) return '请输入用户名';
  if (value.length < 2 || value.length > 10) return '用户名需2-10个字符';
  return null;
}

String? _validatePassword(String? value) {
  if (value == null || value.isEmpty) return '请输入密码';
  if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$').hasMatch(value)) {
    return '至少6位，包含字母和数字';
  }
  return null;
}

String? _validateConfirmPassword(String? value, AuthViewModel auth) {
  return value != auth.passwordController.text ? '两次输入的密码不一致' : null;
}
