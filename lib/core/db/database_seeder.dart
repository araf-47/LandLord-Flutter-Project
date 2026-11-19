import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import '../models/models.dart';

class DatabaseSeeder {
  static Future<void> seedIfEmpty() async {
    final db = await AppDatabase.instance.database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM properties')) ?? 0;
    if (count == 0) {
      await seed();
    }
  }

  static Future<void> seed() async {
    final db = await AppDatabase.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.transaction((txn) async {
      await AppDatabase.instance.clearAll(txn);

      // Properties
      final properties = [
        Property(
          id: 'prop-1',
          name: 'Green View Apartments',
          address: 'Road 12, Dhanmondi',
          district: 'Dhaka',
          area: 'Dhanmondi',
          propertyType: 'apartment',
          landlordId: 101,
          createdAt: now - (90 * 86400000),
        ),
        Property(
          id: 'prop-2',
          name: 'Sunset Heights',
          address: 'Road 45, Gulshan-2',
          district: 'Dhaka',
          area: 'Gulshan',
          propertyType: 'apartment',
          landlordId: 101,
          createdAt: now - (60 * 86400000),
        ),
        Property(
          id: 'prop-3',
          name: 'Lake Breeze Residency',
          address: 'Sector 3, Uttara',
          district: 'Dhaka',
          area: 'Uttara',
          propertyType: 'apartment',
          landlordId: 101,
          createdAt: now - (45 * 86400000),
        ),
      ];

      for (var p in properties) {
        await txn.insert('properties', p.toMap());
      }

      // Units
      final units = [
        PropertyUnit(
          id: 'unit-1',
          propertyId: 'prop-1',
          unitNumber: 'A-101',
          rent: 16000,
          status: 'occupied',
          propertyType: 'apartment',
          adPaused: false,
          utilityItemsJson: '[{"label":"Water","amount":400},{"label":"Service Charge","amount":800}]',
          createdAt: now,
        ),
        PropertyUnit(
          id: 'unit-2',
          propertyId: 'prop-1',
          unitNumber: 'A-102',
          rent: 18500,
          status: 'occupied',
          propertyType: 'apartment',
          adPaused: false,
          utilityItemsJson: '[{"label":"Water","amount":400},{"label":"Service Charge","amount":800}]',
          createdAt: now,
        ),
        PropertyUnit(
          id: 'unit-3',
          propertyId: 'prop-1',
          unitNumber: 'B-201',
          rent: 20000,
          status: 'vacant',
          propertyType: 'apartment',
          adPaused: false,
          utilityItemsJson: '[{"label":"Water","amount":500},{"label":"Service Charge","amount":1000}]',
          createdAt: now,
        ),
        PropertyUnit(
          id: 'unit-4',
          propertyId: 'prop-2',
          unitNumber: 'G-401',
          rent: 32000,
          status: 'occupied',
          propertyType: 'apartment',
          adPaused: false,
          utilityItemsJson: '[{"label":"Water","amount":600},{"label":"Service Charge","amount":1500},{"label":"Generator","amount":1000}]',
          createdAt: now,
        ),
        PropertyUnit(
          id: 'unit-5',
          propertyId: 'prop-2',
          unitNumber: 'G-402',
          rent: 35000,
          status: 'occupied',
          propertyType: 'apartment',
          adPaused: false,
          utilityItemsJson: '[{"label":"Water","amount":600},{"label":"Service Charge","amount":1500},{"label":"Generator","amount":1000}]',
          createdAt: now,
        ),
        PropertyUnit(
          id: 'unit-6',
          propertyId: 'prop-2',
          unitNumber: 'Penthouse',
          rent: 48000,
          status: 'vacant',
          propertyType: 'apartment',
          adPaused: false,
          utilityItemsJson: '[{"label":"Water","amount":1000},{"label":"Service Charge","amount":2500}]',
          createdAt: now,
        ),
        PropertyUnit(
          id: 'unit-7',
          propertyId: 'prop-3',
          unitNumber: 'L-101',
          rent: 14000,
          status: 'occupied',
          propertyType: 'apartment',
          adPaused: false,
          utilityItemsJson: '[{"label":"Water","amount":300},{"label":"Service Charge","amount":500}]',
          createdAt: now,
        ),
        PropertyUnit(
          id: 'unit-8',
          propertyId: 'prop-3',
          unitNumber: 'L-102',
          rent: 15000,
          status: 'vacant',
          propertyType: 'apartment',
          adPaused: false,
          utilityItemsJson: '[{"label":"Water","amount":300},{"label":"Service Charge","amount":500}]',
          createdAt: now,
        ),
      ];

      for (var u in units) {
        await txn.insert('units', u.toMap());
      }

      // Tenants
      final tenants = [
        Tenant(
          id: 't-1',
          name: 'Tanvir Ahmed',
          phone: '+880 1712-345678',
          email: 'tanvir.ahmed@gmail.com',
          nationalId: '8293817263',
          unitId: 'unit-1',
          status: 'active',
          createdAt: now,
        ),
        Tenant(
          id: 't-2',
          name: 'Nusrat Jahan',
          phone: '+880 1819-234567',
          email: 'nusrat.jahan@yahoo.com',
          nationalId: '5938201948',
          unitId: 'unit-2',
          status: 'active',
          createdAt: now,
        ),
        Tenant(
          id: 't-3',
          name: 'Farhan Chowdhury',
          phone: '+880 1911-876543',
          email: 'farhan.c@outlook.com',
          nationalId: '3049281745',
          unitId: 'unit-4',
          status: 'active',
          createdAt: now,
        ),
        Tenant(
          id: 't-4',
          name: 'Sadia Rahman',
          phone: '+880 1622-445566',
          email: 'sadia.rahman@gmail.com',
          nationalId: '4820193856',
          unitId: 'unit-5',
          status: 'active',
          createdAt: now,
        ),
        Tenant(
          id: 't-5',
          name: 'Kazi Mahfuz',
          phone: '+880 1555-778899',
          email: 'kazi.mahfuz@gmail.com',
          nationalId: '1928374650',
          unitId: 'unit-7',
          status: 'active',
          createdAt: now,
        ),
      ];

      for (var t in tenants) {
        await txn.insert('tenants', t.toMap());
      }

      // Agreements
      final agreements = [
        RentalAgreement(
          id: 'agr-1',
          tenantId: 't-1',
          unitId: 'unit-1',
          startDate: '2026-01-01',
          terms: '1-year renewable residential lease. Rent due by 5th.',
          deposit: 32000,
          createdAt: now,
        ),
        RentalAgreement(
          id: 'agr-2',
          tenantId: 't-2',
          unitId: 'unit-2',
          startDate: '2026-03-01',
          terms: '2-year residential lease. Security deposit refundable upon inspection.',
          deposit: 37000,
          createdAt: now,
        ),
        RentalAgreement(
          id: 'agr-3',
          tenantId: 't-3',
          unitId: 'unit-4',
          startDate: '2025-11-01',
          terms: 'Executive luxury lease. Generator and lift charges included.',
          deposit: 64000,
          createdAt: now,
        ),
        RentalAgreement(
          id: 'agr-4',
          tenantId: 't-4',
          unitId: 'unit-5',
          startDate: '2026-02-15',
          terms: 'Family residence lease agreement. Subletting prohibited.',
          deposit: 70000,
          createdAt: now,
        ),
        RentalAgreement(
          id: 'agr-5',
          tenantId: 't-5',
          unitId: 'unit-7',
          startDate: '2026-04-01',
          terms: 'Standard flat lease agreement with 2-month notice period.',
          deposit: 28000,
          createdAt: now,
        ),
      ];

      for (var a in agreements) {
        await txn.insert('rental_agreements', a.toMap());
      }

      // Invoices
      final invoices = [
        // Past Paid
        Invoice(
          id: 'inv-1',
          tenantId: 't-1',
          unitId: 'unit-1',
          period: '2026-09',
          rent: 16000,
          utilityTotal: 1200,
          prevUnpaidRolled: 0,
          amount: 17200,
          balance: 0,
          status: 'paid',
          dueDate: '2026-09-05',
          createdAt: now,
        ),
        Invoice(
          id: 'inv-2',
          tenantId: 't-2',
          unitId: 'unit-2',
          period: '2026-09',
          rent: 18500,
          utilityTotal: 1200,
          prevUnpaidRolled: 0,
          amount: 19700,
          balance: 0,
          status: 'paid',
          dueDate: '2026-09-05',
          createdAt: now,
        ),
        Invoice(
          id: 'inv-3',
          tenantId: 't-3',
          unitId: 'unit-4',
          period: '2026-09',
          rent: 32000,
          utilityTotal: 3100,
          prevUnpaidRolled: 0,
          amount: 35100,
          balance: 0,
          status: 'paid',
          dueDate: '2026-09-05',
          createdAt: now,
        ),
        // Current Month (2026-10)
        Invoice(
          id: 'inv-4',
          tenantId: 't-1',
          unitId: 'unit-1',
          period: '2026-10',
          rent: 16000,
          utilityTotal: 1200,
          prevUnpaidRolled: 0,
          amount: 17200,
          balance: 17200,
          status: 'unpaid',
          dueDate: '2026-10-10',
          createdAt: now,
        ),
        Invoice(
          id: 'inv-5',
          tenantId: 't-2',
          unitId: 'unit-2',
          period: '2026-10',
          rent: 18500,
          utilityTotal: 1200,
          prevUnpaidRolled: 0,
          amount: 19700,
          balance: 7500,
          status: 'partial',
          dueDate: '2026-10-10',
          createdAt: now,
        ),
        Invoice(
          id: 'inv-6',
          tenantId: 't-3',
          unitId: 'unit-4',
          period: '2026-10',
          rent: 32000,
          utilityTotal: 3100,
          prevUnpaidRolled: 0,
          amount: 35100,
          balance: 0,
          status: 'paid',
          dueDate: '2026-10-05',
          createdAt: now,
        ),
        Invoice(
          id: 'inv-7',
          tenantId: 't-4',
          unitId: 'unit-5',
          period: '2026-10',
          rent: 35000,
          utilityTotal: 3100,
          prevUnpaidRolled: 0,
          amount: 38100,
          balance: 38100,
          status: 'unpaid',
          dueDate: '2026-10-10',
          createdAt: now,
        ),
        Invoice(
          id: 'inv-8',
          tenantId: 't-5',
          unitId: 'unit-7',
          period: '2026-10',
          rent: 14000,
          utilityTotal: 800,
          prevUnpaidRolled: 0,
          amount: 14800,
          balance: 0,
          status: 'paid',
          dueDate: '2026-10-05',
          createdAt: now,
        ),
      ];

      for (var inv in invoices) {
        await txn.insert('invoices', inv.toMap());
      }

      // Payments
      final payments = [
        Payment(
          id: 'pay-1',
          tenantId: 't-1',
          invoiceId: 'inv-1',
          amount: 17200,
          method: 'mobile',
          status: 'confirmed',
          date: '2026-09-03',
          transactionRef: 'bKash: BK8291823',
          createdAt: now,
        ),
        Payment(
          id: 'pay-2',
          tenantId: 't-2',
          invoiceId: 'inv-2',
          amount: 19700,
          method: 'mobile',
          status: 'confirmed',
          date: '2026-09-05',
          transactionRef: 'Nagad: NG5839201',
          createdAt: now,
        ),
        Payment(
          id: 'pay-3',
          tenantId: 't-3',
          invoiceId: 'inv-3',
          amount: 35100,
          method: 'bank',
          status: 'confirmed',
          date: '2026-09-02',
          transactionRef: 'CityBank: CB938210',
          createdAt: now,
        ),
        Payment(
          id: 'pay-4',
          tenantId: 't-3',
          invoiceId: 'inv-6',
          amount: 35100,
          method: 'bank',
          status: 'confirmed',
          date: '2026-10-02',
          transactionRef: 'CityBank: CB104928',
          createdAt: now,
        ),
        Payment(
          id: 'pay-5',
          tenantId: 't-2',
          invoiceId: 'inv-5',
          amount: 12200,
          method: 'mobile',
          status: 'confirmed',
          date: '2026-10-04',
          transactionRef: 'bKash: BK9948271',
          createdAt: now,
        ),
        Payment(
          id: 'pay-6',
          tenantId: 't-5',
          invoiceId: 'inv-8',
          amount: 14800,
          method: 'cash',
          status: 'confirmed',
          date: '2026-10-05',
          transactionRef: 'Cash Receipt #104',
          createdAt: now,
        ),
      ];

      for (var pay in payments) {
        await txn.insert('payments', pay.toMap());
      }

      // Expenses
      final expenses = [
        Expense(
          id: 'exp-1',
          propertyId: 'prop-2',
          category: 'Utility',
          description: 'Generator Diesel Fuel (50 Liters)',
          amount: 4500,
          bearer: 'landlord',
          date: '2026-10-03',
          createdAt: now,
        ),
        Expense(
          id: 'exp-2',
          propertyId: 'prop-1',
          category: 'Maintenance',
          description: 'Water Pump Capacitor Replacement',
          amount: 2800,
          bearer: 'landlord',
          date: '2026-10-06',
          createdAt: now,
        ),
        Expense(
          id: 'exp-3',
          propertyId: 'prop-3',
          category: 'Cleaning',
          description: 'Common Corridor and Stairway Cleaning',
          amount: 1500,
          bearer: 'landlord',
          date: '2026-10-08',
          createdAt: now,
        ),
        Expense(
          id: 'exp-4',
          propertyId: 'prop-2',
          category: 'Maintenance',
          description: 'Lift Monthly Servicing & Inspection',
          amount: 6000,
          bearer: 'landlord',
          date: '2026-09-28',
          createdAt: now,
        ),
      ];

      for (var exp in expenses) {
        await txn.insert('expenses', exp.toMap());
      }

      // Maintenance Tickets
      final tickets = [
        MaintenanceTicket(
          id: 'ticket-1',
          unitId: 'unit-1',
          tenantId: 't-1',
          title: 'Kitchen Sink Pipe Leakage',
          description: 'Water slowly dripping under kitchen cabinet, needs washer replacement.',
          status: 'pending',
          priority: 'medium',
          createdAt: now - (2 * 86400000),
        ),
        MaintenanceTicket(
          id: 'ticket-2',
          unitId: 'unit-4',
          tenantId: 't-3',
          title: 'AC Master Bedroom Cooling Issue',
          description: 'Compressor trips after running 10 minutes. Technician scheduled.',
          status: 'in_progress',
          priority: 'high',
          createdAt: now - (4 * 86400000),
        ),
        MaintenanceTicket(
          id: 'ticket-3',
          unitId: 'unit-2',
          tenantId: 't-2',
          title: 'Bathroom Geyser Repair',
          description: 'Heating element burnt out, replaced with new Ariston coil.',
          status: 'resolved',
          priority: 'high',
          createdAt: now - (10 * 86400000),
        ),
        MaintenanceTicket(
          id: 'ticket-4',
          unitId: 'unit-5',
          tenantId: 't-4',
          title: 'Balcony Light Switch Broken',
          description: 'Switch replaced with new gang box.',
          status: 'resolved',
          priority: 'low',
          createdAt: now - (15 * 86400000),
        ),
      ];

      for (var t in tickets) {
        await txn.insert('maintenance_tickets', t.toMap());
      }

      // Marketplace Requests
      final requests = [
        MarketplaceRequest(
          id: 'req-1',
          unitId: 'unit-3',
          applicantName: 'Mehedi Hasan',
          applicantPhone: '+880 1788-112233',
          message: 'Looking for a 2-bedroom apartment for family of 3. Can move in next month.',
          status: 'pending',
          createdAt: now - 86400000,
        ),
        MarketplaceRequest(
          id: 'req-2',
          unitId: 'unit-6',
          applicantName: 'Dr. Sabrina Islam',
          applicantPhone: '+880 1999-334455',
          message: 'Interested in visiting this Friday afternoon for 1-year corporate lease.',
          status: 'pending',
          createdAt: now - (2 * 86400000),
        ),
        MarketplaceRequest(
          id: 'req-3',
          unitId: 'unit-8',
          applicantName: 'Rashed Karim',
          applicantPhone: '+880 1822-667788',
          message: 'Security deposit ready, agreement requested.',
          status: 'approved',
          createdAt: now - (5 * 86400000),
        ),
      ];

      for (var r in requests) {
        await txn.insert('marketplace_requests', r.toMap());
      }

      // Conversations & Messages
      final conversations = [
        Conversation(
          id: 'conv-1',
          tenantId: 't-1',
          tenantName: 'Tanvir Ahmed',
          lastMessage: 'Plumber is scheduled for tomorrow at 11 AM.',
          lastMessageTime: now - 3600000,
          unreadCount: 0,
        ),
        Conversation(
          id: 'conv-2',
          tenantId: 't-3',
          tenantName: 'Farhan Chowdhury',
          lastMessage: 'Received payment confirmation. Thank you!',
          lastMessageTime: now - 86400000,
          unreadCount: 0,
        ),
        Conversation(
          id: 'conv-3',
          tenantId: 't-2',
          tenantName: 'Nusrat Jahan',
          lastMessage: 'I paid 12,200 today, remaining balance next week.',
          lastMessageTime: now - (2 * 86400000),
          unreadCount: 1,
        ),
      ];

      for (var c in conversations) {
        await txn.insert('conversations', c.toMap());
      }

      final messages = [
        MessageItem(
          id: 'msg-1',
          conversationId: 'conv-1',
          senderType: 'tenant',
          content: 'Salam Bhai, the kitchen sink pipe is leaking again.',
          sentAt: now - 7200000,
        ),
        MessageItem(
          id: 'msg-2',
          conversationId: 'conv-1',
          senderType: 'landlord',
          content: 'Walaykum Assalam. I have notified the technician. Plumber is scheduled for tomorrow at 11 AM.',
          sentAt: now - 3600000,
        ),
        MessageItem(
          id: 'msg-3',
          conversationId: 'conv-2',
          senderType: 'tenant',
          content: 'Transferred October rent 35,100 via City Bank. Txn CB104928.',
          sentAt: now - 90000000,
        ),
        MessageItem(
          id: 'msg-4',
          conversationId: 'conv-2',
          senderType: 'landlord',
          content: 'Received payment confirmation. Thank you!',
          sentAt: now - 86400000,
        ),
      ];

      for (var m in messages) {
        await txn.insert('messages', m.toMap());
      }

      // Notifications
      final notifications = [
        NotificationItem(
          id: 'notif-1',
          title: 'Rent Payment Pending',
          body: 'Tanvir Ahmed (Unit A-101) October invoice of ৳17,200 is due.',
          category: 'payment',
          read: false,
          createdAt: now - 1800000,
        ),
        NotificationItem(
          id: 'notif-2',
          title: 'New Maintenance Ticket',
          body: 'Kitchen sink pipe leakage reported in Green View A-101.',
          category: 'maintenance',
          read: false,
          createdAt: now - 3600000,
        ),
        NotificationItem(
          id: 'notif-3',
          title: 'Marketplace Inquiry',
          body: 'Dr. Sabrina Islam sent inquiry for Penthouse at Sunset Heights.',
          category: 'lead',
          read: false,
          createdAt: now - 12000000,
        ),
        NotificationItem(
          id: 'notif-4',
          title: 'Payment Received',
          body: '৳35,100 received from Farhan Chowdhury for Unit G-401.',
          category: 'payment',
          read: true,
          createdAt: now - 86400000,
        ),
      ];

      for (var n in notifications) {
        await txn.insert('notifications', n.toMap());
      }
    });
  }
}
