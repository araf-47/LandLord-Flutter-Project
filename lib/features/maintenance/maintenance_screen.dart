import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/status_pill.dart';
import '../landlord_provider.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LandlordProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Tickets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showLogTicketDialog(context),
          ),
        ],
      ),
      body: provider.tickets.isEmpty
          ? const Center(child: Text('No maintenance tickets recorded.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.tickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final ticket = provider.tickets[index];
                final tenant = provider.tenants.where((t) => t.id == ticket.tenantId).firstOrNull;
                final unit = provider.units.where((u) => u.id == ticket.unitId).firstOrNull;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                ticket.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            StatusPill.fromStatus(ticket.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Unit: ${unit?.unitNumber ?? ""} • Reported by: ${tenant?.name ?? "Tenant"} • Priority: ${ticket.priority.toUpperCase()}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(ticket.description, style: const TextStyle(fontSize: 13)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (ticket.status == 'pending')
                              OutlinedButton(
                                onPressed: () {
                                  context.read<LandlordProvider>().updateTicketStatus(ticket.id, 'in_progress');
                                },
                                child: const Text('Start Work'),
                              ),
                            if (ticket.status != 'resolved') ...[
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.emerald,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  context.read<LandlordProvider>().updateTicketStatus(ticket.id, 'resolved');
                                },
                                child: const Text('Mark Resolved'),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogTicketDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Log Ticket'),
      ),
    );
  }

  void _showLogTicketDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String priority = 'medium';
    String? unitId;
    String? tenantId;

    final units = context.read<LandlordProvider>().units;
    final tenants = context.read<LandlordProvider>().tenants;
    if (units.isNotEmpty) unitId = units.first.id;
    if (tenants.isNotEmpty) tenantId = tenants.first.id;

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
                    const Text('Log Maintenance Ticket', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Issue Title (e.g. Pipe Leakage)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(labelText: 'Description & Notes'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: priority,
                      decoration: const InputDecoration(labelText: 'Priority Level'),
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('Low Priority')),
                        DropdownMenuItem(value: 'medium', child: Text('Medium Priority')),
                        DropdownMenuItem(value: 'high', child: Text('High Urgency')),
                      ],
                      onChanged: (val) {
                        if (val != null) setSheetState(() => priority = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    if (units.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: unitId,
                        decoration: const InputDecoration(labelText: 'Affected Unit'),
                        items: units.map((u) => DropdownMenuItem(value: u.id, child: Text('Unit ${u.unitNumber}'))).toList(),
                        onChanged: (val) {
                          if (val != null) setSheetState(() => unitId = val);
                        },
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (titleCtrl.text.trim().isNotEmpty && unitId != null && tenantId != null) {
                          context.read<LandlordProvider>().addMaintenanceTicket(
                                unitId: unitId!,
                                tenantId: tenantId!,
                                title: titleCtrl.text.trim(),
                                description: descCtrl.text.trim(),
                                priority: priority,
                              );
                          Navigator.pop(ctx);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Create Ticket'),
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
