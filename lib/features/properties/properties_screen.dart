import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/status_pill.dart';
import '../landlord_provider.dart';
import 'property_detail_screen.dart';

class PropertiesScreen extends StatelessWidget {
  const PropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LandlordProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties & Buildings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddPropertyDialog(context),
          ),
        ],
      ),
      body: provider.properties.isEmpty
          ? const Center(child: Text('No properties registered.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.properties.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final prop = provider.properties[index];
                final propUnits = provider.units.where((u) => u.propertyId == prop.id).toList();
                final occupied = propUnits.where((u) => u.status == 'occupied').length;

                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PropertyDetailScreen(property: prop),
                        ),
                      );
                    },
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
                                  prop.name,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              StatusPill(
                                label: '$occupied/${propUnits.length} OCCUPIED',
                                type: occupied == propUnits.length
                                    ? StatusType.success
                                    : (occupied > 0 ? StatusType.info : StatusType.danger),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${prop.address}, ${prop.area}',
                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${propUnits.length} Total Units',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'View Roster',
                                    style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                  Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPropertyDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Property'),
      ),
    );
  }

  void _showAddPropertyDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    final areaCtrl = TextEditingController();
    final distCtrl = TextEditingController(text: 'Dhaka');

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
              const Text('Add New Property', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Property Name (e.g. Green View)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addrCtrl,
                decoration: const InputDecoration(labelText: 'Road / Street Address'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: areaCtrl,
                decoration: const InputDecoration(labelText: 'Area / Neighborhood (e.g. Dhanmondi)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: distCtrl,
                decoration: const InputDecoration(labelText: 'District / City'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    context.read<LandlordProvider>().addProperty(
                          name: nameCtrl.text.trim(),
                          address: addrCtrl.text.trim(),
                          district: distCtrl.text.trim(),
                          area: areaCtrl.text.trim(),
                        );
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Save Property'),
              ),
            ],
          ),
        );
      },
    );
  }
}
