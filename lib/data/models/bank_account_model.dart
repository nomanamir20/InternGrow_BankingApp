class BankAccount {
  final String id;
  final String accountNumber;
  final String accountType; // "Checking" or "Savings"
  final double balance;
  final String currency;
  final DateTime createdAt;

  const BankAccount({
    required this.id,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
    required this.currency,
    required this.createdAt,
  });

  BankAccount copyWith({double? balance}) {
    return BankAccount(
      id: id,
      accountNumber: accountNumber,
      accountType: accountType,
      balance: balance ?? this.balance,
      currency: currency,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountNumber': accountNumber,
      'accountType': accountType,
      'balance': balance,
      'currency': currency,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BankAccount.fromMap(Map<String, dynamic> map) {
    return BankAccount(
      id: map['id'] as String,
      accountNumber: map['accountNumber'] as String,
      accountType: map['accountType'] as String,
      balance: (map['balance'] as num).toDouble(),
      currency: map['currency'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}