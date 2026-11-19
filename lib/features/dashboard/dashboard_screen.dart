import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/auth/session_manager.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/aurora_hero_card.dart';
import '../../ui/widgets/glowing_bezier_chart.dart';
import '../../ui/widgets/occupancy_arc.dart';
import '../../ui/widgets/odometer_ticker.dart';
import '../../ui/widgets/status_pill.dart';
import '../landlord_provider.dart';
import '../properties/properties_screen.dart';
import '../tenants/tenants_screen.dart';
import '../payments/payments_screen.dart';
import '../expenses/expenses_screen.dart';
import '../ledger/ledger_screen.dart';
import '../maintenance/maintenance_screen.dart';
import '../marketplace/marketplace_screen.dart';
import '../messages/messages_screen.dart';
import '../reports/reports_screen.dart';
import '../insights/insights_screen.dart';
import '../notifications/notifications_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LandlordProvider>();
    final session = SessionManager.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentMonthYear = DateFormat('MMMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${session.displayName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '$currentMonthYear Portfolio Overview',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                },
              ),
              if (provider.unreadNotificationCount > 0)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.coral,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => provider.refreshAll(),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.refreshAll(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Aurora Hero Card
                    AuroraHeroCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              OccupancyArc(
                                occupied: provider.occupiedUnitsCount,
                                total: provider.totalUnitsCount,
                                size: 110,
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'COLLECTED REVENUE',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withOpacity(0.6),
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    OdometerTicker(
                                      value: provider.totalCollectedThisMonth,
                                      prefix: '৳',
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'NET OPERATING SURPLUS',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withOpacity(0.6),
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    OdometerTicker(
                                      value: provider.netOperatingSurplus,
                                      prefix: '৳',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.emerald,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // KPI Summary Cards Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            title: 'Collected',
                            amount: provider.totalCollectedThisMonth,
                            icon: Icons.arrow_downward_rounded,
                            iconColor: AppColors.emerald,
                            pillText: 'Active',
                            pillType: StatusType.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            title: 'Outstanding',
                            amount: provider.totalOutstandingBalance,
                            icon: Icons.error_outline_rounded,
                            iconColor: AppColors.coral,
                            pillText: 'Due',
                            pillType: StatusType.danger,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            title: 'Expenses',
                            amount: provider.totalExpensesThisMonth,
                            icon: Icons.arrow_upward_rounded,
                            iconColor: AppColors.amber,
                            pillText: 'Outflow',
                            pillType: StatusType.warning,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            title: 'Vacant Units',
                            amount: provider.vacantUnitsCount.toDouble(),
                            isCurrency: false,
                            icon: Icons.meeting_room_outlined,
                            iconColor: AppColors.cyan,
                            pillText: '${provider.totalUnitsCount} Total',
                            pillType: StatusType.info,
                          ),
                        ),
                      ],
                    ),

                    // Pending Maintenance Banner
                    if (provider.pendingMaintenanceCount > 0) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.amber.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.amber.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.handyman_rounded, color: AppColors.amber, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${provider.pendingMaintenanceCount} Maintenance Tickets Require Attention',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const MaintenanceScreen()),
                                );
                              },
                              child: const Text('View', style: TextStyle(color: AppColors.amber, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Cash Flow Spline Chart Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Cash Flow Trajectory',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const StatusPill(label: '6M TREND', type: StatusType.success),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Touch and drag along the line to inspect revenue',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            GlowingBezierChart(
                              points: provider.cashFlowTrend,
                              height: 160,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Module Quick Navigation Grid
                    const Text(
                      'Management Modules',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.95,
                      children: [
                        _buildTile(context, Icons.apartment_rounded, 'Properties', AppColors.primary, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const PropertiesScreen()));
                        }),
                        _buildTile(context, Icons.people_alt_rounded, 'Tenants', AppColors.secondary, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const TenantsScreen()));
                        }),
                        _buildTile(context, Icons.receipt_long_rounded, 'Payments', AppColors.emerald, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentsScreen()));
                        }),
                        _buildTile(context, Icons.shopping_bag_outlined, 'Expenses', AppColors.coral, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesScreen()));
                        }),
                        _buildTile(context, Icons.account_balance_wallet_outlined, 'Ledger', AppColors.cyan, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LedgerScreen()));
                        }),
                        _buildTile(context, Icons.build_rounded, 'Maintenance', AppColors.amber, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const MaintenanceScreen()));
                        }),
                        _buildTile(context, Icons.storefront_rounded, 'Marketplace', Colors.indigo, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketplaceScreen()));
                        }),
                        _buildTile(context, Icons.forum_rounded, 'Messages', Colors.teal, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesScreen()));
                        }),
                        _buildTile(context, Icons.analytics_outlined, 'Reports', Colors.deepOrange, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
                        }),
                        _buildTile(context, Icons.smart_toy_rounded, 'AI Insights', Colors.pink, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const InsightsScreen()));
                        }),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required double amount,
    bool isCurrency = true,
    required IconData icon,
    required Color iconColor,
    required String pillText,
    required StatusType pillType,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                StatusPill(label: pillText, type: pillType),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            OdometerTicker(
              value: amount,
              prefix: isCurrency ? '৳' : '',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
