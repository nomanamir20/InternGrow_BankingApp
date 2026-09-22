enum BranchType { branch, atm }

class Branch {
  final String id;
  final String name;
  final BranchType type;
  final double latitude;
  final double longitude;
  final String address;
  final bool isOpen24Hours;

  const Branch({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.isOpen24Hours = false,
  });
}