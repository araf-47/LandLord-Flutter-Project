import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../core/reports/pdf_generator.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/aurora_hero_card.dart';
import '../../ui/widgets/odometer_ticker.dart';
import '../../ui/widgets/status_pill.dart';
import '../landlord_provider.dart';
import 'payment_history_screen.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LandlordProvider>();
    final unpaidInvoices = provider.invoices.where((i) => i.status != 'paid').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments & Rent Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Payment History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payments Aurora Hero Card
            AuroraHeroCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL OUTSTANDING DUE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.6),
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          OdometerTicker(
                            value: provider.totalOutstandingBalance,
                            prefix: '৳',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.coral,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'COLLECTED THIS MONTH',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.6),
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          OdometerTicker(
                            value: provider.totalCollectedThisMonth,
                            prefix: '৳',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.emerald,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pending Tenant Invoices',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PaymentHistoryScreen()),
                    );
                  },
                  icon: const Icon(Icons.receipt_long, size: 16),
                  label: const Text('All History'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (unpaidInvoices.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('🎉 All tenant dues are completely cleared!'),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: unpaidInvoices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final inv = unpaidInvoices[index];
                  final tenant = provider.tenants.where((t) => t.id == inv.tenantId).firstOrNull;
                  final unit = provider.units.where((u) => u.id == inv.unitId).firstOrNull;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                tenant?.name ?? 'Tenant',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              StatusPill.fromStatus(inv.status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Period: ${inv.period} • Unit: ${unit?.unitNumber ?? ''} • Due: ${inv.dueDate}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Balance Due', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  Text(
                                    '৳${inv.balance.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.coral),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _showRecordPaymentSheet(context, inv, tenant),
                                icon: const Icon(Icons.payments_rounded, size: 18),
                                label: const Text('Record Payment'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.emerald,
                                  foregroundColor: Colors.white,
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
          ],
        ),
      ),
    );
  }

  void _showRecordPaymentSheet(BuildContext context, Invoice invoice, Tenant? tenant) {
    final amountCtrl = TextEditingController(text: invoice.balance.toStringAsFixed(0));
    final refCtrl = TextEditingController(text: 'bKash: BK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');
    String selectedMethod = 'mobile';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Record Payment — ${tenant?.name ?? ""}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Invoice for ${invoice.period} • Balance Due: ৳${invoice.balance.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Received Amount (৳)', prefixText: '৳ '),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedMethod,
                      decoration: const InputDecoration(labelText: 'Payment Method'),
                      items: const [
                        DropdownMenuItem(value: 'mobile', child: Text('Mobile Banking (bKash / Nagad)')),
                        DropdownMenuItem(value: 'bank', child: Text('Bank Transfer (CityBank, etc.)')),
                        DropdownMenuItem(value: 'cash', child: Text('Cash in Hand')),
                      ],
                      onChanged: (val) {
                        if (val != null) setSheetState(() => selectedMethod = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: refCtrl,
                      decoration: const InputDecoration(labelText: 'Transaction Reference / Receipt No.'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                        if (amt > 0 && tenant != null) {
                          context.read<LandlordProvider>().recordPayment(
                                tenantId: tenant.id,
                                invoiceId: invoice.id,
                                amount: amt,
                                method: selectedMethod,
                                ref: refCtrl.text.trim(),
                              );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Payment successfully recorded!')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Confirm & Save Payment'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
