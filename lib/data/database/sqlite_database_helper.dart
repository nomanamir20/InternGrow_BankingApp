import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Real SQLite database — used on Android/iOS (and desktop), where sqflite
/// has genuine, stable native support.
class SqliteDatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'interngrow_banking.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE accounts (
            id TEXT PRIMARY KEY,
            accountNumber TEXT NOT NULL,
            accountType TEXT NOT NULL,
            balance REAL NOT NULL,
            currency TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE transactions (
            id TEXT PRIMARY KEY,
            accountId TEXT NOT NULL,
            type INTEGER NOT NULL,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            description TEXT NOT NULL,
            date TEXT NOT NULL,
            beneficiaryId TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE beneficiaries (
            id TEXT PRIMARY KEY,
            nickname TEXT NOT NULL,
            fullName TEXT NOT NULL,
            accountNumber TEXT NOT NULL,
            bankName TEXT NOT NULL
          )
        ''');
      },
    );
  }
}