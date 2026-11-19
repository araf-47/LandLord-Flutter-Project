import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/odometer_ticker.dart';
import '../../ui/widgets/status_pill.dart';
import '../landlord_provider.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LandlordProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddExpenseDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expense Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Monthly Landlord Expenses', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 4),
                        OdometerTicker(
                          value: provider.totalExpensesThisMonth,
                          prefix: '৳',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.coral),
                        ),
                      ],
                    ),
                    const StatusPill(label: 'OUTFLOW', type: StatusType.danger),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Logged Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            if (provider.expenses.isEmpty)
              const Center(child: Text('No expenses recorded.'))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.expenses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final exp = provider.expenses[index];
                  final prop = provider.properties.where((p) => p.id == exp.propertyId).firstOrNull;

                  return Card(
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.coral.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.build_circle_outlined, color: AppColors.coral, size: 22),
                      ),
                      title: Text(exp.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('${exp.category} • ${prop?.name ?? "Building"} • ${exp.date}'),
                      trailing: Text(
                        '৳${exp.amount.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.coral),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final descCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    String category = 'Maintenance';
    String? propertyId;

    final props = context.read<LandlordProvider>().properties;
    if (props.isNotEmpty) propertyId = props.first.id;

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
                    const Text('Log New Expense', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(labelText: 'Description (e.g. Water Pump Repair)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amtCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Expense Amount (৳)', prefixText: '৳ '),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: const [
                        DropdownMenuItem(value: 'Maintenance', child: Text('Maintenance & Repair')),
                        DropdownMenuItem(value: 'Utility', child: Text('Generator / Utility')),
                        DropdownMenuItem(value: 'Cleaning', child: Text('Corridor & Cleaning')),
                        DropdownMenuItem(value: 'Other', child: Text('Other Property Expense')),
                      ],
                      onChanged: (val) {
                        if (val != null) setSheetState(() => category = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    if (props.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: propertyId,
                        decoration: const InputDecoration(labelText: 'Property'),
                        items: props.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                        onChanged: (val) {
                          if (val != null) setSheetState(() => propertyId = val);
                        },
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final amt = double.tryParse(amtCtrl.text.trim()) ?? 0.0;
                        if (descCtrl.text.trim().isNotEmpty && amt > 0 && propertyId != null) {
                          context.read<LandlordProvider>().addExpense(
                                propertyId: propertyId!,
                                category: category,
                                description: descCtrl.text.trim(),
                                amount: amt,
                                bearer: 'landlord',
                              );
                          Navigator.pop(ctx);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Save Expense'),
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
