import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../ui/theme/app_theme.dart';
import '../landlord_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LandlordProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Mark All Read',
            onPressed: () => provider.markNotificationsRead(),
          ),
        ],
      ),
      body: provider.notifications.isEmpty
          ? const Center(child: Text('No notifications.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notif = provider.notifications[index];

                IconData icon;
                Color color;
                switch (notif.category) {
                  case 'payment':
                    icon = Icons.payments_rounded;
                    color = AppColors.emerald;
                    break;
                  case 'maintenance':
                    icon = Icons.build_rounded;
                    color = AppColors.amber;
                    break;
                  case 'lead':
                    icon = Icons.person_search_rounded;
                    color = AppColors.cyan;
                    break;
                  default:
                    icon = Icons.notifications_rounded;
                    color = AppColors.primary;
                }

                return Card(
                  color: notif.read
                      ? null
                      : (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFEFF6FF)),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    title: Text(
                      notif.title,
                      style: TextStyle(
                        fontWeight: notif.read ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(notif.body),
                  ),
                );
              },
            ),
    );
  }
}
