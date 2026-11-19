import 'package:flutter/material.dart';
import '../../ui/theme/app_theme.dart';
import 'dashboard/dashboard_screen.dart';
import 'properties/properties_screen.dart';
import 'tenants/tenants_screen.dart';
import 'payments/payments_screen.dart';
import 'settings/settings_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    PropertiesScreen(),
    TenantsScreen(),
    PaymentsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        indicatorColor: AppColors.primary.withOpacity(0.15),
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.apartment_outlined),
            selectedIcon: Icon(Icons.apartment_rounded, color: AppColors.primary),
            label: 'Properties',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people_rounded, color: AppColors.primary),
            label: 'Tenants',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded, color: AppColors.primary),
            label: 'Payments',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded, color: AppColors.primary),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
