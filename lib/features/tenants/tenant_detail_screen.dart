import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/status_pill.dart';
import '../landlord_provider.dart';

class TenantDetailScreen extends StatelessWidget {
  final Tenant tenant;

  const TenantDetailScreen({super.key, required this.tenant});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LandlordProvider>();
    final agreement = provider.agreements.where((a) => a.tenantId == tenant.id).firstOrNull;
    final unit = provider.units.where((u) => u.id == tenant.unitId).firstOrNull;
    final invoices = provider.invoices.where((i) => i.tenantId == tenant.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(tenant.name),
        actions: [
          if (tenant.status == 'active')
            IconButton(
              icon: const Icon(Icons.exit_to_app_rounded, color: AppColors.coral),
              tooltip: 'Terminate Tenancy / Move-Out',
              onPressed: () => _confirmMoveOut(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      child: Text(
                        tenant.name[0],
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tenant.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    StatusPill.fromStatus(tenant.status),
                    const SizedBox(height: 16),
                    const Divider(),
                    _buildInfoRow(Icons.phone_outlined, 'Phone', tenant.phone),
                    _buildInfoRow(Icons.email_outlined, 'Email', tenant.email),
                    _buildInfoRow(Icons.badge_outlined, 'NID', tenant.nationalId),
                    _buildInfoRow(Icons.apartment_rounded, 'Assigned Unit', unit != null ? 'Unit ${unit.unitNumber}' : 'None'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Rental Agreement Card
            if (agreement != null) ...[
              const Text('Rental Agreement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Security Deposit', style: TextStyle(color: Colors.grey)),
                          Text(
                            '৳${agreement.deposit.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.emerald),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Lease Start Date', style: TextStyle(color: Colors.grey)),
                          Text(agreement.startDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const Text('Lease Terms & Conditions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(agreement.terms, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
            const Text('Invoice History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: invoices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final inv = invoices[index];
                return Card(
                  child: ListTile(
                    title: Text('Period: ${inv.period}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Total: ৳${inv.amount.toStringAsFixed(0)} • Balance Due: ৳${inv.balance.toStringAsFixed(0)}'),
                    trailing: StatusPill.fromStatus(inv.status),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  void _confirmMoveOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Process Tenant Move-Out?'),
        content: Text('Are you sure you want to mark ${tenant.name} as inactive and make the unit vacant?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.coral, foregroundColor: Colors.white),
            onPressed: () {
              context.read<LandlordProvider>().terminateTenancy(tenant.id, tenant.unitId);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Confirm Move-Out'),
          ),
        ],
      ),
    );
  }
}
