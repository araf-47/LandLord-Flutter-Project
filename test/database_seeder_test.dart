import 'dart:ffi';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3/sqlite3.dart' as ffi_sqlite;
import 'package:landlord_app/core/db/app_database.dart';
import 'package:landlord_app/core/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    try {
      final candidates = [
        '/usr/lib/x86_64-linux-gnu/libsqlite3.so.0',
        '/usr/lib/x86_64-linux-gnu/libsqlite3.so',
      ];
      for (var c in candidates) {
        if (File(c).existsSync()) {
          ffi_sqlite.sqlite3.open;
          break;
        }
      }
    } catch (_) {}

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Database clearAll with transaction does not deadlock', () async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('CREATE TABLE properties (local_id TEXT PRIMARY KEY, name TEXT, address TEXT, district TEXT, area TEXT, property_type TEXT, landlord_id INTEGER, created_at INTEGER)');
          await db.execute('CREATE TABLE units (local_id TEXT PRIMARY KEY, property_id TEXT, unit_number TEXT, rent REAL, status TEXT, property_type TEXT, ad_paused INTEGER, utility_items_json TEXT, created_at INTEGER)');
          await db.execute('CREATE TABLE tenants (local_id TEXT PRIMARY KEY, name TEXT, phone TEXT, email TEXT, national_id TEXT, unit_id TEXT, status TEXT, created_at INTEGER)');
          await db.execute('CREATE TABLE rental_agreements (local_id TEXT PRIMARY KEY, tenant_id TEXT, unit_id TEXT, start_date TEXT, terms TEXT, deposit REAL, created_at INTEGER)');
          await db.execute('CREATE TABLE invoices (local_id TEXT PRIMARY KEY, tenant_id TEXT, unit_id TEXT, period TEXT, rent REAL, utility_total REAL, prev_unpaid_rolled REAL, amount REAL, balance REAL, status TEXT, due_date TEXT, created_at INTEGER)');
          await db.execute('CREATE TABLE payments (local_id TEXT PRIMARY KEY, tenant_id TEXT, invoice_id TEXT, amount REAL, method TEXT, status TEXT, date TEXT, transaction_ref TEXT, created_at INTEGER)');
          await db.execute('CREATE TABLE expenses (local_id TEXT PRIMARY KEY, property_id TEXT, category TEXT, description TEXT, amount REAL, bearer TEXT, tenant_id TEXT, date TEXT, created_at INTEGER)');
          await db.execute('CREATE TABLE maintenance_tickets (local_id TEXT PRIMARY KEY, unit_id TEXT, tenant_id TEXT, title TEXT, description TEXT, status TEXT, priority TEXT, created_at INTEGER)');
          await db.execute('CREATE TABLE marketplace_requests (local_id TEXT PRIMARY KEY, unit_id TEXT, applicant_name TEXT, applicant_phone TEXT, message TEXT, status TEXT, created_at INTEGER)');
          await db.execute('CREATE TABLE conversations (local_id TEXT PRIMARY KEY, tenant_id TEXT, tenant_name TEXT, last_message TEXT, last_message_time INTEGER, unread_count INTEGER)');
          await db.execute('CREATE TABLE messages (local_id TEXT PRIMARY KEY, conversation_id TEXT, sender_type TEXT, content TEXT, sent_at INTEGER)');
          await db.execute('CREATE TABLE notifications (local_id TEXT PRIMARY KEY, title TEXT, body TEXT, category TEXT, read INTEGER, created_at INTEGER)');
        },
      ),
    );

    // Seed transaction
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      await AppDatabase.instance.clearAll(txn);

      final p = Property(
        id: 'prop-1',
        name: 'Green View Apartments',
        address: 'Road 12, Dhanmondi',
        district: 'Dhaka',
        area: 'Dhanmondi',
        propertyType: 'apartment',
        landlordId: 101,
        createdAt: now,
      );
      await txn.insert('properties', p.toMap());

      final u = PropertyUnit(
        id: 'unit-1',
        propertyId: 'prop-1',
        unitNumber: 'A-101',
        rent: 16000,
        status: 'occupied',
        propertyType: 'apartment',
        adPaused: false,
        utilityItemsJson: '[]',
        createdAt: now,
      );
      await txn.insert('units', u.toMap());

      final t = Tenant(
        id: 't-1',
        name: 'Tanvir Ahmed',
        phone: '+880 1712-345678',
        email: 'tanvir.ahmed@gmail.com',
        nationalId: '8293817263',
        unitId: 'unit-1',
        status: 'active',
        createdAt: now,
      );
      await txn.insert('tenants', t.toMap());
    });

    final propCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM properties')) ?? 0;
    final unitCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM units')) ?? 0;
    final tenantCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM tenants')) ?? 0;

    expect(propCount, equals(1));
    expect(unitCount, equals(1));
    expect(tenantCount, equals(1));

    await db.close();
  });
}
