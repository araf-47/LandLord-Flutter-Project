import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/status_pill.dart';
import '../landlord_provider.dart';

class PropertyDetailScreen extends StatelessWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LandlordProvider>();
    final units = provider.units.where((u) => u.propertyId == property.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(property.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${property.address}, ${property.area}, ${property.district}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(context, 'Total Units', '${units.length}'),
                        _buildStat(
                          context,
                          'Occupied',
                          '${units.where((u) => u.status == 'occupied').length}',
                          color: AppColors.emerald,
                        ),
                        _buildStat(
                          context,
                          'Vacant',
                          '${units.where((u) => u.status == 'vacant').length}',
                          color: AppColors.coral,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Units Roster',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => _showAddUnitDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Unit'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: units.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final u = units[index];
                final tenant = provider.tenants.where((t) => t.unitId == u.id && t.status == 'active').firstOrNull;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              u.unitNumber,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Unit ${u.unitNumber}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tenant != null ? 'Tenant: ${tenant.name}' : 'Currently Vacant',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: tenant != null ? Colors.grey[700] : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '৳${u.rent.toStringAsFixed(0)}/mo',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            StatusPill.fromStatus(u.status),
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

  static Widget _buildStat(BuildContext context, String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  void _showAddUnitDialog(BuildContext context) {
    final unitNoCtrl = TextEditingController();
    final rentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add Unit to ${property.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: unitNoCtrl,
                decoration: const InputDecoration(labelText: 'Unit Number (e.g. B-301)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: rentCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monthly Rent (৳)', prefixText: '৳ '),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final rent = double.tryParse(rentCtrl.text.trim()) ?? 0.0;
                  if (unitNoCtrl.text.trim().isNotEmpty && rent > 0) {
                    context.read<LandlordProvider>().addUnit(
                          propertyId: property.id,
                          unitNumber: unitNoCtrl.text.trim(),
                          rent: rent,
                          utilitiesJson: '[]',
                        );
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Save Unit'),
              ),
            ],
          ),
        );
      },
    );
  }
}
