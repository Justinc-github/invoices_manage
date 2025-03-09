import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/views/components/avatar_view.dart';

class InvoiceSelfView extends StatelessWidget {
  const InvoiceSelfView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [const Center(child: Text('个人发票页面')), const AvatarView()],
      ),
    );
  }
}
