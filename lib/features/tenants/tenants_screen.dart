import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/status_pill.dart';
import '../landlord_provider.dart';
import 'tenant_detail_screen.dart';

class TenantsScreen extends StatelessWidget {
  const TenantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LandlordProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenants & Roster'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: () => _showRegisterTenantDialog(context),
          ),
        ],
      ),
      body: provider.tenants.isEmpty
          ? const Center(child: Text('No tenants registered.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.tenants.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final tenant = provider.tenants[index];
                final unit = provider.units.where((u) => u.id == tenant.unitId).firstOrNull;

                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TenantDetailScreen(tenant: tenant),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.secondary.withOpacity(0.15),
                            child: Text(
                              tenant.name.isNotEmpty ? tenant.name[0] : 'T',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 18),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tenant.name,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  unit != null ? 'Unit: ${unit.unitNumber} • ${tenant.phone}' : tenant.phone,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          StatusPill.fromStatus(tenant.status),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRegisterTenantDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Register Tenant'),
      ),
    );
  }

  void _showRegisterTenantDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final nidCtrl = TextEditingController();
    final depositCtrl = TextEditingController();
    final termsCtrl = TextEditingController(text: '1-year renewable residential lease. Rent due by 5th.');
    String? selectedUnitId;

    final vacantUnits = context.read<LandlordProvider>().units.where((u) => u.status == 'vacant').toList();
    if (vacantUnits.isNotEmpty) {
      selectedUnitId = vacantUnits.first.id;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    const Text('Register New Tenant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Full Legal Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(labelText: 'Phone Number (+880...)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email Address'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nidCtrl,
                      decoration: const InputDecoration(labelText: 'National ID (NID)'),
                    ),
                    const SizedBox(height: 12),
                    if (vacantUnits.isEmpty)
                      const Text('No vacant units currently available!', style: TextStyle(color: AppColors.coral))
                    else
                      DropdownButtonFormField<String>(
                        value: selectedUnitId,
                        decoration: const InputDecoration(labelText: 'Assign to Vacant Unit'),
                        items: vacantUnits.map((u) {
                          return DropdownMenuItem(
                            value: u.id,
                            child: Text('Unit ${u.unitNumber} (৳${u.rent.toStringAsFixed(0)}/mo)'),
                          );
                        }).toList(),
                        onChanged: (val) => setModalState(() => selectedUnitId = val),
                      ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: depositCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Security Deposit (৳)', prefixText: '৳ '),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: termsCtrl,
                      decoration: const InputDecoration(labelText: 'Lease Terms & Agreement Note'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: vacantUnits.isEmpty
                          ? null
                          : () {
                              if (nameCtrl.text.trim().isNotEmpty && selectedUnitId != null) {
                                final dep = double.tryParse(depositCtrl.text.trim()) ?? 0.0;
                                context.read<LandlordProvider>().addTenant(
                                      name: nameCtrl.text.trim(),
                                      phone: phoneCtrl.text.trim(),
                                      email: emailCtrl.text.trim(),
                                      nid: nidCtrl.text.trim(),
                                      unitId: selectedUnitId!,
                                      deposit: dep,
                                      terms: termsCtrl.text.trim(),
                                    );
                                Navigator.pop(ctx);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Confirm & Create Lease'),
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
