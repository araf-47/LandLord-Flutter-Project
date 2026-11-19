import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/reports/pdf_generator.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/odometer_ticker.dart';
import '../landlord_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LandlordProvider>();

    final startStr = DateFormat('yyyy-MM-dd').format(_startDate);
    final endStr = DateFormat('yyyy-MM-dd').format(_endDate);

    final filteredPayments = provider.payments.where((p) => p.date.compareTo(startStr) >= 0 && p.date.compareTo(endStr) <= 0).toList();
    final filteredExpenses = provider.expenses.where((e) => e.date.compareTo(startStr) >= 0 && e.date.compareTo(endStr) <= 0).toList();

    final totalIncome = filteredPayments.fold(0.0, (sum, p) => sum + p.amount);
    final totalExpense = filteredExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final netOperating = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'Export PDF Statement',
            onPressed: () {
              PdfReportGenerator.printFinancialReport(
                startDate: startStr,
                endDate: endStr,
                totalIncome: totalIncome,
                totalExpense: totalExpense,
                payments: filteredPayments,
                expenses: filteredExpenses,
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
            // Date Filter Card with Native Date Picker
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Statement Period', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_month_outlined, size: 16),
                            label: Text(DateFormat('dd MMM yyyy').format(_startDate)),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _startDate,
                                firstDate: DateTime(2024),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) setState(() => _startDate = picked);
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('to', style: TextStyle(color: Colors.grey)),
                        ),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_month_outlined, size: 16),
                            label: Text(DateFormat('dd MMM yyyy').format(_endDate)),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _endDate,
                                firstDate: DateTime(2024),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) setState(() => _endDate = picked);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Financial Performance Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Net Operating Income', style: TextStyle(color: Colors.grey)),
                        Text(
                          '৳${netOperating.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: netOperating >= 0 ? AppColors.emerald : AppColors.coral,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Rent Collected', style: TextStyle(color: Colors.grey)),
                        Text(
                          '৳${totalIncome.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.emerald),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Landlord Expenses', style: TextStyle(color: Colors.grey)),
                        Text(
                          '৳${totalExpense.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.coral),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Collection Transactions', style: TextStyle(color: Colors.grey)),
                        Text('${filteredPayments.length} txns', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () {
                PdfReportGenerator.printFinancialReport(
                  startDate: startStr,
                  endDate: endStr,
                  totalIncome: totalIncome,
                  totalExpense: totalExpense,
                  payments: filteredPayments,
                  expenses: filteredExpenses,
                );
              },
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('Export Official PDF Statement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
