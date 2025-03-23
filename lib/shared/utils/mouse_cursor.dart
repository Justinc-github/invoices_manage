import 'package:fluent_ui/fluent_ui.dart';

class MouseCursorClick extends StatelessWidget {
  final Widget child;

  const MouseCursorClick({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(cursor: SystemMouseCursors.click, child: child);
  }
}
