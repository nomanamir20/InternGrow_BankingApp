import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/bank_account_model.dart';
import '../models/beneficiary_model.dart';
import '../models/bank_transaction_model.dart';
import 'sqlite_database_helper.dart';
import 'web_storage_helper.dart';

/// Single entry point for all local persistence — every controller talks
/// to this class only, never directly to SQLite or SharedPreferences.
/// Internally routes to real SQLite (mobile/desktop) or a JSON-based web
/// fallback, but callers never need to know which one is active.
class LocalDataService {
  static const _accountsTable = 'accounts';
  static const _transactionsTable = 'transactions';
  static const _beneficiariesTable = 'beneficiaries';

  // ---------- Accounts ----------

  Future<List<BankAccount>> getAccounts() async {
    if (kIsWeb) {
      final rows = await WebStorageHelper.getAll(_accountsTable);
      return rows.map(BankAccount.fromMap).toList();
    }
    final db = await SqliteDatabaseHelper.database;
    final rows = await db.query(_accountsTable);
    return rows.map(BankAccount.fromMap).toList();
  }

  Future<void> insertAccount(BankAccount account) async {
    if (kIsWeb) {
      await WebStorageHelper.insert(_accountsTable, account.toMap());
      return;
    }
    final db = await SqliteDatabaseHelper.database;
    await db.insert(_accountsTable, account.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    final accounts = await getAccounts();
    final account = accounts.firstWhere((a) => a.id == accountId);
    final updated = account.copyWith(balance: newBalance);

    if (kIsWeb) {
      await WebStorageHelper.update(_accountsTable, accountId, updated.toMap());
      return;
    }
    final db = await SqliteDatabaseHelper.database;
    await db.update(_accountsTable, updated.toMap(), where: 'id = ?', whereArgs: [accountId]);
  }

  // ---------- Transactions ----------

  Future<List<BankTransaction>> getTransactions() async {
    if (kIsWeb) {
      final rows = await WebStorageHelper.getAll(_transactionsTable);
      final list = rows.map(BankTransaction.fromMap).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    }
    final db = await SqliteDatabaseHelper.database;
    final rows = await db.query(_transactionsTable, orderBy: 'date DESC');
    return rows.map(BankTransaction.fromMap).toList();
  }

  Future<void> insertTransaction(BankTransaction transaction) async {
    if (kIsWeb) {
      await WebStorageHelper.insert(_transactionsTable, transaction.toMap());
      return;
    }
    final db = await SqliteDatabaseHelper.database;
    await db.insert(_transactionsTable, transaction.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteTransaction(String id) async {
    if (kIsWeb) {
      await WebStorageHelper.delete(_transactionsTable, id);
      return;
    }
    final db = await SqliteDatabaseHelper.database;
    await db.delete(_transactionsTable, where: 'id = ?', whereArgs: [id]);
  }

  // ---------- Beneficiaries ----------

  Future<List<Beneficiary>> getBeneficiaries() async {
    if (kIsWeb) {
      final rows = await WebStorageHelper.getAll(_beneficiariesTable);
      return rows.map(Beneficiary.fromMap).toList();
    }
    final db = await SqliteDatabaseHelper.database;
    final rows = await db.query(_beneficiariesTable);
    return rows.map(Beneficiary.fromMap).toList();
  }

  Future<void> insertBeneficiary(Beneficiary beneficiary) async {
    if (kIsWeb) {
      await WebStorageHelper.insert(_beneficiariesTable, beneficiary.toMap());
      return;
    }
    final db = await SqliteDatabaseHelper.database;
    await db.insert(_beneficiariesTable, beneficiary.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateBeneficiary(Beneficiary beneficiary) async {
    if (kIsWeb) {
      await WebStorageHelper.update(_beneficiariesTable, beneficiary.id, beneficiary.toMap());
      return;
    }
    final db = await SqliteDatabaseHelper.database;
    await db.update(_beneficiariesTable, beneficiary.toMap(), where: 'id = ?', whereArgs: [beneficiary.id]);
  }

  Future<void> deleteBeneficiary(String id) async {
    if (kIsWeb) {
      await WebStorageHelper.delete(_beneficiariesTable, id);
      return;
    }
    final db = await SqliteDatabaseHelper.database;
    await db.delete(_beneficiariesTable, where: 'id = ?', whereArgs: [id]);
  }

  // ---------- First-run seeding ----------

  /// Creates a starter checking account with a small transaction history,
  /// so the dashboard isn't empty on first login — a small UX touch, same
  /// pattern used for default categories in Task 4.
  Future<void> seedIfEmpty() async {
    final existingAccounts = await getAccounts();
    if (existingAccounts.isNotEmpty) return;

    const uuid = Uuid();
    final accountId = uuid.v4();

    await insertAccount(BankAccount(
      id: accountId,
      accountNumber: '4521 **** **** 8890',
      accountType: 'Checking',
      balance: 2450.75,
      currency: 'USD',
      createdAt: DateTime.now(),
    ));

    final now = DateTime.now();
    final starterTransactions = [
      BankTransaction(
        id: uuid.v4(),
        accountId: accountId,
        type: TxnType.credit,
        amount: 3000.00,
        category: 'Salary',
        description: 'Monthly Salary Deposit',
        date: now.subtract(const Duration(days: 5)),
      ),
      BankTransaction(
        id: uuid.v4(),
        accountId: accountId,
        type: TxnType.debit,
        amount: 249.25,
        category: 'Shopping',
        description: 'Online Purchase',
        date: now.subtract(const Duration(days: 3)),
      ),
      BankTransaction(
        id: uuid.v4(),
        accountId: accountId,
        type: TxnType.debit,
        amount: 300.00,
        category: 'Bills',
        description: 'Electricity Bill',
        date: now.subtract(const Duration(days: 1)),
      ),
    ];

    for (final txn in starterTransactions) {
      await insertTransaction(txn);
    }
  }
}