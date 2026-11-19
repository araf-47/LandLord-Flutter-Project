import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/odometer_ticker.dart';
import '../../ui/widgets/status_pill.dart';
import '../landlord_provider.dart';

class LedgerEntry {
  final String date;
  final String title;
  final String subtitle;
  final double amount;
  final bool isCredit; // true = income (+), false = expense (-)

  LedgerEntry({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
  });
}

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LandlordProvider>();

    final List<LedgerEntry> entries = [];
    for (var p in provider.payments) {
      final t = provider.tenants.where((ten) => ten.id == p.tenantId).firstOrNull;
      entries.add(LedgerEntry(
        date: p.date,
        title: 'Rent Collected • ${t?.name ?? "Tenant"}',
        subtitle: '${p.method.toUpperCase()} • ${p.transactionRef}',
        amount: p.amount,
        isCredit: true,
      ));
    }
    for (var e in provider.expenses) {
      entries.add(LedgerEntry(
        date: e.date,
        title: e.description,
        subtitle: '${e.category} • Landlord Borne',
        amount: e.amount,
        isCredit: false,
      ));
    }

    entries.sort((a, b) => b.date.compareTo(a.date));

    final totalIncome = entries.where((e) => e.isCredit).fold(0.0, (sum, e) => sum + e.amount);
    final totalExpense = entries.where((e) => !e.isCredit).fold(0.0, (sum, e) => sum + e.amount);
    final netBalance = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Cashbook & Ledger'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cashbook Hero Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Net Cashbook Balance', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        StatusPill(
                          label: netBalance >= 0 ? 'NET SURPLUS' : 'DEFICIT',
                          type: netBalance >= 0 ? StatusType.success : StatusType.danger,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    OdometerTicker(
                      value: netBalance,
                      prefix: '৳',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: netBalance >= 0 ? AppColors.emerald : AppColors.coral,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Total Inflow (+)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text(
                              '৳${totalIncome.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.emerald, fontSize: 15),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Total Outflow (-)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text(
                              '৳${totalExpense.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.coral, fontSize: 15),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Chronological Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: entry.isCredit ? AppColors.emerald.withOpacity(0.12) : AppColors.coral.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        entry.isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                        color: entry.isCredit ? AppColors.emerald : AppColors.coral,
                        size: 20,
                      ),
                    ),
                    title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('${entry.date} • ${entry.subtitle}', style: const TextStyle(fontSize: 11)),
                    trailing: Text(
                      '${entry.isCredit ? "+" : "-"}৳${entry.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: entry.isCredit ? AppColors.emerald : AppColors.coral,
                      ),
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
}
