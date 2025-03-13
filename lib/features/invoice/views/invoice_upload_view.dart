import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/features/invoice/view_models/invoice_upload_view_model.dart';
import 'package:management_invoices/shared/views/avatar_view.dart';
import 'package:provider/provider.dart';

class InvoiceUploadView extends StatelessWidget {
  const InvoiceUploadView({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceUploadViewModel = context.watch<InvoiceUploadViewModel>();
    return Stack(
      children: [
        Center(
          child: IconButton(
            icon: Icon(FluentIcons.activity_feed),
            onPressed: invoiceUploadViewModel.uploadInvoice,
          ),
        ),
        const AvatarView(),
      ],
    );
  }
}
