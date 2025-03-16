import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/features/invoice/view_models/invoice_upload_view_model.dart';
import 'package:management_invoices/shared/views/avatar_view.dart';
import 'package:provider/provider.dart';

class InvoiceUploadView extends StatelessWidget {
  const InvoiceUploadView({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceUploadViewModel = context.watch<InvoiceUploadViewModel>();
    final messages = invoiceUploadViewModel.messages;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (messages.isNotEmpty) {
        final messagesCopy = List<String>.from(messages);
        _showResultDialog(context, messagesCopy);
        invoiceUploadViewModel.clearMessages();
      }
    });

    return Stack(
      children: [
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildUploadButton(
                context: context,
                label: '图片上传',
                onPressed: invoiceUploadViewModel.uploadInvoice,
                isActive: !invoiceUploadViewModel.isUploading,
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              _buildUploadButton(
                context: context,
                label: '文件上传',
                onPressed: () {},
                isActive: false,
              ),
            ],
          ),
        ),
        const AvatarView(),
      ],
    );
  }

  Widget _buildUploadButton({
    required BuildContext context,
    required String label,
    required VoidCallback? onPressed,
    required bool isActive,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.09,
      height: MediaQuery.of(context).size.width * 0.035,
      child: MouseRegion(
        cursor:
            isActive ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        child: FilledButton(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(const EdgeInsets.all(8)),
            iconSize: WidgetStateProperty.all(20),
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (states) => isActive ? null : Colors.grey[40],
            ),
          ),
          onPressed: isActive ? onPressed : null,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isActive ? null : Colors.grey[40],
            ),
          ),
        ),
      ),
    );
  }

  void _showResultDialog(BuildContext context, List<String> messages) {
    showDialog(
      context: context,
      builder:
          (context) => ContentDialog(
            title: const Text('上传结果'),
            content: SizedBox(
              width: 400,
              child: SizedBox(
                width: 400,
                height: 300, // 固定高度防止内容溢出
                child: Scrollbar(
                  child: ListView(
                    shrinkWrap: true,
                    children:
                        messages
                            .map(
                              (msg) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Text(msg),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
            ),
            actions: [
              Button(
                child: const Text("确定"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }
}
