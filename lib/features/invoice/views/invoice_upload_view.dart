import 'package:fluent_ui/fluent_ui.dart';
// import 'package:flutter/material.dart';
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
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.09,
                height: MediaQuery.of(context).size.width * 0.035,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: FilledButton(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(EdgeInsets.all(8)),
                      iconSize: WidgetStateProperty.all(20),
                    ),
                    onPressed: invoiceUploadViewModel.uploadInvoice,
                    child: Text('图片上传', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.09,
                height: MediaQuery.of(context).size.width * 0.035,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: FilledButton(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(EdgeInsets.all(8)),
                      iconSize: WidgetStateProperty.all(20),
                    ),
                    onPressed: () {},
                    child: Text('文件上传', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const AvatarView(),
      ],
    );
  }
}
