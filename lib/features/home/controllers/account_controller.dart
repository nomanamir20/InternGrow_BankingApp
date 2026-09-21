import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../data/database/local_data_service.dart';
import '../../../data/models/bank_account_model.dart';
import '../../../data/models/bank_transaction_model.dart';

class AccountController extends GetxController {
  final LocalDataService _dataService = LocalDataService();

  final RxList<BankAccount> accounts = <BankAccount>[].obs;
  final RxList<BankTransaction> transactions = <BankTransaction>[].obs;
  final RxBool isLoading = true.obs;

  BankAccount? get primaryAccount => accounts.isNotEmpty ? accounts.first : null;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    accounts.assignAll(await _dataService.getAccounts());
    transactions.assignAll(await _dataService.getTransactions());
    isLoading.value = false;
  }

  List<BankTransaction> get recentTransactions => transactions.take(5).toList();

  double get totalBalance => accounts.fold(0.0, (sum, a) => sum + a.balance);

  /// Applies a transaction against the account's balance and persists both
  /// — the single source of truth for money actually moving in this app.
  Future<void> applyTransaction({
    required String accountId,
    required TxnType type,
    required double amount,
    required String category,
    required String description,
    String? beneficiaryId,
  }) async {
    final account = accounts.firstWhere((a) => a.id == accountId);
    final newBalance = type == TxnType.credit ? account.balance + amount : account.balance - amount;

    final transaction = BankTransaction(
      id: const Uuid().v4(),
      accountId: accountId,
      type: type,
      amount: amount,
      category: category,
      description: description,
      date: DateTime.now(),
      beneficiaryId: beneficiaryId,
    );

    await _dataService.insertTransaction(transaction);
    await _dataService.updateAccountBalance(accountId, newBalance);

    await loadData(); // refresh reactive state from persisted source of truth
  }
}