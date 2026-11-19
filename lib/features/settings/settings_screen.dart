import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/session_manager.dart';
import '../../ui/theme/app_theme.dart';
import '../auth/auth_screen.dart';
import '../landlord_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final session = SessionManager.instance;
    final isDark = session.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    child: Text(
                      session.displayName.isNotEmpty ? session.displayName[0] : 'A',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    session.displayName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${session.email} • ${session.phone}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () => _editProfile(context),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Landlord Profile'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text('Preferences & Security', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Midnight obsidian executive theme'),
                  value: isDark,
                  onChanged: (val) {
                    session.setDarkMode(val);
                    setState(() {});
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint_rounded),
                  title: const Text('Biometric Security Unlock'),
                  subtitle: const Text('Prompt fingerprint on launch'),
                  value: session.biometricEnabled,
                  onChanged: (val) {
                    session.setBiometricEnabled(val);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('Demo Maintenance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),

          Card(
            child: ListTile(
              leading: const Icon(Icons.restore_page_outlined, color: AppColors.amber),
              title: const Text('Reset Database to Demo State'),
              subtitle: const Text('Restores pristine Dhaka demo properties & invoices'),
              onTap: () => _confirmReset(context),
            ),
          ),

          const SizedBox(height: 24),

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.coral,
              side: const BorderSide(color: AppColors.coral),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Log Out'),
            onPressed: () async {
              await session.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context) {
    final session = SessionManager.instance;
    final nameCtrl = TextEditingController(text: session.displayName);
    final emailCtrl = TextEditingController(text: session.email);
    final phoneCtrl = TextEditingController(text: session.phone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Display Name')),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address')),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              session.updateProfile(nameCtrl.text.trim(), emailCtrl.text.trim(), phoneCtrl.text.trim());
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Demo Database?'),
        content: const Text('This will clear current database edits and restore the pristine Dhaka demo dataset.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.amber, foregroundColor: Colors.black),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<LandlordProvider>().resetToDemo();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Database reset to pristine demo state!')),
                );
              }
            },
            child: const Text('Reset Now'),
          ),
        ],
      ),
    );
  }
}
