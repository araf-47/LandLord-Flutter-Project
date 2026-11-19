import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../core/reports/pdf_generator.dart';
import '../../ui/theme/app_theme.dart';
import '../landlord_provider.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LandlordProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Transaction History'),
      ),
      body: provider.payments.isEmpty
          ? const Center(child: Text('No payment transactions recorded.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.payments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final payment = provider.payments[index];
                final tenant = provider.tenants.where((t) => t.id == payment.tenantId).firstOrNull;
                final invoice = provider.invoices.where((i) => i.id == payment.invoiceId).firstOrNull;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.emerald, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tenant?.name ?? 'Tenant Payment',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${payment.date} • ${payment.transactionRef}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '৳${payment.amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.emerald,
                              ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () {
                                if (tenant != null && invoice != null) {
                                  PdfReportGenerator.printReceipt(
                                    payment: payment,
                                    tenant: tenant,
                                    invoice: invoice,
                                  );
                                }
                              },
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.print_outlined, size: 14, color: AppColors.primary),
                                  SizedBox(width: 4),
                                  Text(
                                    'Receipt',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
