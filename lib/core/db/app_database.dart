import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String dbPath;
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      final docDir = await getApplicationDocumentsDirectory();
      dbPath = p.join(docDir.path, 'landlord_master.db');
    } else {
      final databasesPath = await getDatabasesPath();
      dbPath = p.join(databasesPath, 'landlord_master.db');
    }

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE properties (
        local_id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        district TEXT NOT NULL,
        area TEXT NOT NULL,
        property_type TEXT NOT NULL,
        landlord_id INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE units (
        local_id TEXT PRIMARY KEY,
        property_id TEXT NOT NULL,
        unit_number TEXT NOT NULL,
        rent REAL NOT NULL,
        status TEXT NOT NULL,
        property_type TEXT NOT NULL,
        ad_paused INTEGER NOT NULL DEFAULT 0,
        utility_items_json TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tenants (
        local_id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        national_id TEXT NOT NULL,
        unit_id TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE rental_agreements (
        local_id TEXT PRIMARY KEY,
        tenant_id TEXT NOT NULL,
        unit_id TEXT NOT NULL,
        start_date TEXT NOT NULL,
        terms TEXT NOT NULL,
        deposit REAL NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE invoices (
        local_id TEXT PRIMARY KEY,
        tenant_id TEXT NOT NULL,
        unit_id TEXT NOT NULL,
        period TEXT NOT NULL,
        rent REAL NOT NULL,
        utility_total REAL NOT NULL,
        prev_unpaid_rolled REAL NOT NULL,
        amount REAL NOT NULL,
        balance REAL NOT NULL,
        status TEXT NOT NULL,
        due_date TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE payments (
        local_id TEXT PRIMARY KEY,
        tenant_id TEXT NOT NULL,
        invoice_id TEXT NOT NULL,
        amount REAL NOT NULL,
        method TEXT NOT NULL,
        status TEXT NOT NULL,
        date TEXT NOT NULL,
        transaction_ref TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        local_id TEXT PRIMARY KEY,
        property_id TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        bearer TEXT NOT NULL,
        tenant_id TEXT,
        date TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE maintenance_tickets (
        local_id TEXT PRIMARY KEY,
        unit_id TEXT NOT NULL,
        tenant_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        priority TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE marketplace_requests (
        local_id TEXT PRIMARY KEY,
        unit_id TEXT NOT NULL,
        applicant_name TEXT NOT NULL,
        applicant_phone TEXT NOT NULL,
        message TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE conversations (
        local_id TEXT PRIMARY KEY,
        tenant_id TEXT NOT NULL,
        tenant_name TEXT NOT NULL,
        last_message TEXT NOT NULL,
        last_message_time INTEGER NOT NULL,
        unread_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        local_id TEXT PRIMARY KEY,
        conversation_id TEXT NOT NULL,
        sender_type TEXT NOT NULL,
        content TEXT NOT NULL,
        sent_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        local_id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        category TEXT NOT NULL,
        read INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> clearAll([DatabaseExecutor? executor]) async {
    if (executor != null) {
      await _deleteTables(executor);
      return;
    }
    final db = await database;
    await db.transaction((txn) async {
      await _deleteTables(txn);
    });
  }

  static Future<void> _deleteTables(DatabaseExecutor exec) async {
    await exec.delete('notifications');
    await exec.delete('messages');
    await exec.delete('conversations');
    await exec.delete('marketplace_requests');
    await exec.delete('maintenance_tickets');
    await exec.delete('expenses');
    await exec.delete('payments');
    await exec.delete('invoices');
    await exec.delete('rental_agreements');
    await exec.delete('tenants');
    await exec.delete('units');
    await exec.delete('properties');
  }
}
