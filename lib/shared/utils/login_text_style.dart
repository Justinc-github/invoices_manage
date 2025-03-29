import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show TextButton;

class LoginTextStyle extends StatelessWidget {
  final String text;
  final Widget child;

  const LoginTextStyle({super.key, required this.text, required this.child});
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => child,
        );
      },
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'MSYH',
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
