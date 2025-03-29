import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:management_invoices/features/invoice/view_models/invoice_self_view_model.dart';
import 'package:provider/provider.dart';

class InvoiceOtherView extends StatelessWidget {
  final String userId;
  final String userName;

  const InvoiceOtherView({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final invoiceSelfViewModel = context.watch<InvoiceSelfViewModel>();

    return ScaffoldPage(
      header: PageHeader(title: Text('用户$userName的发票')),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (invoiceSelfViewModel.isLoadingOther)
              const material.CircularProgressIndicator() // Show loading indicator while fetching
            else if (invoiceSelfViewModel.invoicesOtherInfos.isEmpty)
              const Text('No invoices available for this user.')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: invoiceSelfViewModel.invoicesOtherInfos.length,
                  itemBuilder: (context, index) {
                    final invoice =
                        invoiceSelfViewModel.invoicesOtherInfos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(invoice.invoiceType),
                        subtitle: Text(
                          'Amount: ¥${invoice.amountInFigures.toString()}',
                        ),
                        trailing: Text(invoice.invoiceDate),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Total Amount: ¥${invoiceSelfViewModel.totalOtherAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
