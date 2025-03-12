import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/views/components/avatar_view.dart';

class InvoiceUploadView extends StatelessWidget {
  const InvoiceUploadView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [Center(child: Text('发票上传界面')), const AvatarView()]);
  }
}
