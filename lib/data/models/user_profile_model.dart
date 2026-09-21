class UserProfile {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String? photoPath; // local file path (mobile) or base64 data URL (web)

  const UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phoneNumber = '',
    this.address = '',
    this.photoPath,
  });

  UserProfile copyWith({
    String? fullName,
    String? phoneNumber,
    String? address,
    String? photoPath,
  }) {
    return UserProfile(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'photoPath': photoPath,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String,
      fullName: map['fullName'] as String,
      email: map['email'] as String,
      phoneNumber: map['phoneNumber'] as String? ?? '',
      address: map['address'] as String? ?? '',
      photoPath: map['photoPath'] as String?,
    );
  }
}