class Beneficiary {
  final String id;
  final String nickname;
  final String fullName;
  final String accountNumber;
  final String bankName;

  const Beneficiary({
    required this.id,
    required this.nickname,
    required this.fullName,
    required this.accountNumber,
    required this.bankName,
  });

  Beneficiary copyWith({
    String? nickname,
    String? fullName,
    String? accountNumber,
    String? bankName,
  }) {
    return Beneficiary(
      id: id,
      nickname: nickname ?? this.nickname,
      fullName: fullName ?? this.fullName,
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'fullName': fullName,
      'accountNumber': accountNumber,
      'bankName': bankName,
    };
  }

  factory Beneficiary.fromMap(Map<String, dynamic> map) {
    return Beneficiary(
      id: map['id'] as String,
      nickname: map['nickname'] as String,
      fullName: map['fullName'] as String,
      accountNumber: map['accountNumber'] as String,
      bankName: map['bankName'] as String,
    );
  }
}