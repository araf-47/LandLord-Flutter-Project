import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/status_pill.dart';
import '../landlord_provider.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LandlordProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace & Applicant Leads'),
      ),
      body: provider.marketplaceRequests.isEmpty
          ? const Center(child: Text('No marketplace inquiries.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.marketplaceRequests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final req = provider.marketplaceRequests[index];
                final unit = provider.units.where((u) => u.id == req.unitId).firstOrNull;
                final prop = unit != null
                    ? provider.properties.where((p) => p.id == unit.propertyId).firstOrNull
                    : null;

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
                              req.applicantName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            StatusPill.fromStatus(req.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Phone: ${req.applicantPhone} • Inquiring: ${prop?.name ?? "Building"} (Unit ${unit?.unitNumber ?? ""})',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '"${req.message}"',
                            style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                          ),
                        ),
                        if (req.status == 'pending') ...[
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  context.read<LandlordProvider>().updateMarketplaceStatus(req.id, 'rejected', req.unitId);
                                },
                                style: OutlinedButton.styleFrom(foregroundColor: AppColors.coral),
                                child: const Text('Decline'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<LandlordProvider>().updateMarketplaceStatus(req.id, 'approved', req.unitId);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.emerald,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Approve Lead'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
