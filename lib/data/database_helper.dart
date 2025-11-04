import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/transaction_entry.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const _databaseName = 'brancash.db';
  static const _databaseVersion = 1;

  static const _tableTransactions = 'transactions';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableTransactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            category TEXT NOT NULL,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            date TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

  Future<int> insertTransaction(TransactionEntry entry) async {
    final db = await database;
    return db.insert(_tableTransactions, entry.toMap());
  }

  Future<List<TransactionEntry>> getRecentTransactions({int limit = 20}) async {
    final db = await database;
    final maps = await db.query(
      _tableTransactions,
      orderBy: 'date DESC',
      limit: limit,
    );
    return maps.map(TransactionEntry.fromMap).toList();
  }

  Future<List<TransactionEntry>> getTransactionsBetween(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final maps = await db.query(
      _tableTransactions,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date ASC',
    );
    return maps.map(TransactionEntry.fromMap).toList();
  }

  Future<Map<TransactionType, double>> getTotals() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT type, SUM(amount) as total FROM $_tableTransactions GROUP BY type',
    );

    final Map<TransactionType, double> totals = {
      TransactionType.income: 0,
      TransactionType.expense: 0,
    };

    for (final row in result) {
      final typeString = row['type'] as String;
      final total = (row['total'] as num?)?.toDouble() ?? 0.0;
      if (typeString == TransactionType.income.name) {
        totals[TransactionType.income] = total;
      } else {
        totals[TransactionType.expense] = total;
      }
    }

    return totals;
  }
}
