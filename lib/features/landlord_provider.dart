import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/db/app_database.dart';
import '../core/db/database_seeder.dart';
import '../core/models/models.dart';
import '../ui/widgets/glowing_bezier_chart.dart';

class LandlordProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Property> properties = [];
  List<PropertyUnit> units = [];
  List<Tenant> tenants = [];
  List<RentalAgreement> agreements = [];
  List<Invoice> invoices = [];
  List<Payment> payments = [];
  List<Expense> expenses = [];
  List<MaintenanceTicket> tickets = [];
  List<MarketplaceRequest> marketplaceRequests = [];
  List<Conversation> conversations = [];
  List<NotificationItem> notifications = [];

  // Computed KPIs
  int get occupiedUnitsCount => units.where((u) => u.status == 'occupied').length;
  int get totalUnitsCount => units.length;
  int get vacantUnitsCount => units.where((u) => u.status == 'vacant').length;

  double get totalCollectedThisMonth {
    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    return payments
        .where((p) => p.date.startsWith(currentMonth))
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  double get totalOutstandingBalance {
    return invoices
        .where((inv) => inv.status != 'paid')
        .fold(0.0, (sum, inv) => sum + inv.balance);
  }

  double get totalExpensesThisMonth {
    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    return expenses
        .where((e) => e.date.startsWith(currentMonth) && e.bearer == 'landlord')
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get netOperatingSurplus => totalCollectedThisMonth - totalExpensesThisMonth;

  int get pendingMaintenanceCount =>
      tickets.where((t) => t.status == 'pending' || t.status == 'in_progress').length;

  int get unreadNotificationCount =>
      notifications.where((n) => !n.read).length;

  List<CashFlowPoint> get cashFlowTrend {
    final Map<String, double> monthlyMap = {
      'May': 98000,
      'Jun': 105000,
      'Jul': 112000,
      'Aug': 118000,
      'Sep': 122000,
      'Oct': totalCollectedThisMonth > 0 ? totalCollectedThisMonth : 124000,
    };
    return monthlyMap.entries.map((e) => CashFlowPoint(e.key, e.value)).toList();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      await DatabaseSeeder.seedIfEmpty();
      await refreshAll();
    } catch (e, stack) {
      debugPrint('Error during LandlordProvider.init: $e\n$stack');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    final db = await AppDatabase.instance.database;

    final pMaps = await db.query('properties', orderBy: 'created_at DESC');
    properties = pMaps.map((m) => Property.fromMap(m)).toList();

    final uMaps = await db.query('units', orderBy: 'unit_number ASC');
    units = uMaps.map((m) => PropertyUnit.fromMap(m)).toList();

    final tMaps = await db.query('tenants', orderBy: 'created_at DESC');
    tenants = tMaps.map((m) => Tenant.fromMap(m)).toList();

    final aMaps = await db.query('rental_agreements', orderBy: 'created_at DESC');
    agreements = aMaps.map((m) => RentalAgreement.fromMap(m)).toList();

    final invMaps = await db.query('invoices', orderBy: 'period DESC');
    invoices = invMaps.map((m) => Invoice.fromMap(m)).toList();

    final payMaps = await db.query('payments', orderBy: 'date DESC');
    payments = payMaps.map((m) => Payment.fromMap(m)).toList();

    final expMaps = await db.query('expenses', orderBy: 'date DESC');
    expenses = expMaps.map((m) => Expense.fromMap(m)).toList();

    final tickMaps = await db.query('maintenance_tickets', orderBy: 'created_at DESC');
    tickets = tickMaps.map((m) => MaintenanceTicket.fromMap(m)).toList();

    final reqMaps = await db.query('marketplace_requests', orderBy: 'created_at DESC');
    marketplaceRequests = reqMaps.map((m) => MarketplaceRequest.fromMap(m)).toList();

    final cMaps = await db.query('conversations', orderBy: 'last_message_time DESC');
    conversations = cMaps.map((m) => Conversation.fromMap(m)).toList();

    final nMaps = await db.query('notifications', orderBy: 'created_at DESC');
    notifications = nMaps.map((m) => NotificationItem.fromMap(m)).toList();

    notifyListeners();
  }

  // --- Actions ---

  Future<void> addProperty({
    required String name,
    required String address,
    required String district,
    required String area,
  }) async {
    final db = await AppDatabase.instance.database;
    final prop = Property(
      id: 'prop-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      address: address,
      district: district,
      area: area,
      propertyType: 'apartment',
      landlordId: 101,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await db.insert('properties', prop.toMap());
    await refreshAll();
  }

  Future<void> addUnit({
    required String propertyId,
    required String unitNumber,
    required double rent,
    required String utilitiesJson,
  }) async {
    final db = await AppDatabase.instance.database;
    final unit = PropertyUnit(
      id: 'unit-${DateTime.now().millisecondsSinceEpoch}',
      propertyId: propertyId,
      unitNumber: unitNumber,
      rent: rent,
      status: 'vacant',
      propertyType: 'apartment',
      adPaused: false,
      utilityItemsJson: utilitiesJson,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await db.insert('units', unit.toMap());
    await refreshAll();
  }

  Future<void> addTenant({
    required String name,
    required String phone,
    required String email,
    required String nid,
    required String unitId,
    required double deposit,
    required String terms,
  }) async {
    final db = await AppDatabase.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final tId = 't-$now';

    await db.transaction((txn) async {
      final tenant = Tenant(
        id: tId,
        name: name,
        phone: phone,
        email: email,
        nationalId: nid,
        unitId: unitId,
        status: 'active',
        createdAt: now,
      );
      await txn.insert('tenants', tenant.toMap());

      final agreement = RentalAgreement(
        id: 'agr-$now',
        tenantId: tId,
        unitId: unitId,
        startDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        terms: terms,
        deposit: deposit,
        createdAt: now,
      );
      await txn.insert('rental_agreements', agreement.toMap());

      // Mark unit occupied
      await txn.update(
        'units',
        {'status': 'occupied'},
        where: 'local_id = ?',
        whereArgs: [unitId],
      );
    });

    await refreshAll();
  }

  Future<void> terminateTenancy(String tenantId, String unitId) async {
    final db = await AppDatabase.instance.database;
    await db.transaction((txn) async {
      await txn.update(
        'tenants',
        {'status': 'inactive'},
        where: 'local_id = ?',
        whereArgs: [tenantId],
      );
      await txn.update(
        'units',
        {'status': 'vacant'},
        where: 'local_id = ?',
        whereArgs: [unitId],
      );
    });
    await refreshAll();
  }

  Future<void> recordPayment({
    required String tenantId,
    required String invoiceId,
    required double amount,
    required String method,
    required String ref,
  }) async {
    final db = await AppDatabase.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await db.transaction((txn) async {
      // Find invoice
      final invMaps = await txn.query(
        'invoices',
        where: 'local_id = ?',
        whereArgs: [invoiceId],
      );
      if (invMaps.isNotEmpty) {
        final inv = Invoice.fromMap(invMaps.first);
        final newBal = (inv.balance - amount).clamp(0.0, double.infinity);
        final newStatus = newBal <= 0 ? 'paid' : 'partial';

        await txn.update(
          'invoices',
          {
            'balance': newBal,
            'status': newStatus,
          },
          where: 'local_id = ?',
          whereArgs: [invoiceId],
        );
      }

      final pay = Payment(
        id: 'pay-$now',
        tenantId: tenantId,
        invoiceId: invoiceId,
        amount: amount,
        method: method,
        status: 'confirmed',
        date: dateStr,
        transactionRef: ref,
        createdAt: now,
      );
      await txn.insert('payments', pay.toMap());
    });

    await refreshAll();
  }

  Future<void> addExpense({
    required String propertyId,
    required String category,
    required String description,
    required double amount,
    required String bearer,
  }) async {
    final db = await AppDatabase.instance.database;
    final exp = Expense(
      id: 'exp-${DateTime.now().millisecondsSinceEpoch}',
      propertyId: propertyId,
      category: category,
      description: description,
      amount: amount,
      bearer: bearer,
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await db.insert('expenses', exp.toMap());
    await refreshAll();
  }

  Future<void> addMaintenanceTicket({
    required String unitId,
    required String tenantId,
    required String title,
    required String description,
    required String priority,
  }) async {
    final db = await AppDatabase.instance.database;
    final tick = MaintenanceTicket(
      id: 'ticket-${DateTime.now().millisecondsSinceEpoch}',
      unitId: unitId,
      tenantId: tenantId,
      title: title,
      description: description,
      status: 'pending',
      priority: priority,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await db.insert('maintenance_tickets', tick.toMap());
    await refreshAll();
  }

  Future<void> updateTicketStatus(String ticketId, String status) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'maintenance_tickets',
      {'status': status},
      where: 'local_id = ?',
      whereArgs: [ticketId],
    );
    await refreshAll();
  }

  Future<void> updateMarketplaceStatus(String requestId, String status, String unitId) async {
    final db = await AppDatabase.instance.database;
    await db.transaction((txn) async {
      await txn.update(
        'marketplace_requests',
        {'status': status},
        where: 'local_id = ?',
        whereArgs: [requestId],
      );
      if (status == 'approved') {
        // Option to reserve unit
      }
    });
    await refreshAll();
  }

  Future<List<MessageItem>> getMessages(String conversationId) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'sent_at ASC',
    );
    return maps.map((m) => MessageItem.fromMap(m)).toList();
  }

  Future<void> sendMessage(String conversationId, String text) async {
    final db = await AppDatabase.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final msg = MessageItem(
      id: 'msg-$now',
      conversationId: conversationId,
      senderType: 'landlord',
      content: text,
      sentAt: now,
    );
    await db.insert('messages', msg.toMap());
    await db.update(
      'conversations',
      {
        'last_message': text,
        'last_message_time': now,
      },
      where: 'local_id = ?',
      whereArgs: [conversationId],
    );
    await refreshAll();
  }

  Future<void> markNotificationsRead() async {
    final db = await AppDatabase.instance.database;
    await db.update('notifications', {'read': 1});
    await refreshAll();
  }

  Future<void> resetToDemo() async {
    _isLoading = true;
    notifyListeners();
    try {
      await DatabaseSeeder.seed();
      await refreshAll();
    } catch (e, stack) {
      debugPrint('Error during LandlordProvider.resetToDemo: $e\n$stack');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
