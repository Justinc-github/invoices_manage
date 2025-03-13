import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/shared/views/avatar_view.dart';

class HomeContentView extends StatelessWidget {
  const HomeContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [const Center(child: Text('主页')), const AvatarView()],
      ),
    );
  }
}
