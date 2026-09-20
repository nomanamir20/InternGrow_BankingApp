enum TxnType { credit, debit }

class BankTransaction {
  final String id;
  final String accountId;
  final TxnType type;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String? beneficiaryId;

  const BankTransaction({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.beneficiaryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'type': type.index,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'beneficiaryId': beneficiaryId,
    };
  }

  factory BankTransaction.fromMap(Map<String, dynamic> map) {
    return BankTransaction(
      id: map['id'] as String,
      accountId: map['accountId'] as String,
      type: TxnType.values[map['type'] as int],
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      description: map['description'] as String,
      date: DateTime.parse(map['date'] as String),
      beneficiaryId: map['beneficiaryId'] as String?,
    );
  }
}