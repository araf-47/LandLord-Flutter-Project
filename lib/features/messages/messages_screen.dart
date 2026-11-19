import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../ui/theme/app_theme.dart';
import '../landlord_provider.dart';
import 'chat_thread_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LandlordProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Messages'),
      ),
      body: provider.conversations.isEmpty
          ? const Center(child: Text('No active conversations.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.conversations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final conv = provider.conversations[index];

                return Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatThreadScreen(conversation: conv),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      child: Text(
                        conv.tenantName.isNotEmpty ? conv.tenantName[0] : 'T',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    title: Text(conv.tenantName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      conv.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                    trailing: conv.unreadCount > 0
                        ? Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${conv.unreadCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          )
                        : const Icon(Icons.chevron_right, color: Colors.grey),
                  ),
                );
              },
            ),
    );
  }
}
