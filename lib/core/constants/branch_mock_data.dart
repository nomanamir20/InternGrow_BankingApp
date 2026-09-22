import 'dart:math';

import '../../data/models/branch_model.dart';

/// Generates mock ATM/branch locations scattered within a few km of the
/// given center point — works anywhere in the world, since it's relative
/// to the user's real (or default) location, not hardcoded to one city.
List<Branch> generateNearbyBranches(double centerLat, double centerLng) {
  final random = Random(42); // fixed seed — same locations every load

  final branchNames = [
    'InternGrow Bank — Main Branch',
    'InternGrow Bank — Downtown',
    'InternGrow Bank — Westside',
    'InternGrow ATM — Mall Plaza',
    'InternGrow ATM — Central Station',
    'InternGrow ATM — Riverside',
    'InternGrow Bank — Eastgate',
    'InternGrow ATM — University',
  ];

  return List.generate(branchNames.length, (index) {
    // Scatter points within roughly a 5km radius.
    final angle = random.nextDouble() * 2 * pi;
    final distanceKm = 0.5 + random.nextDouble() * 4.5;
    final latOffset = (distanceKm / 111) * cos(angle);
    final lngOffset = (distanceKm / (111 * cos(centerLat * pi / 180))) * sin(angle);

    final isAtm = branchNames[index].contains('ATM');

    return Branch(
      id: 'branch-$index',
      name: branchNames[index],
      type: isAtm ? BranchType.atm : BranchType.branch,
      latitude: centerLat + latOffset,
      longitude: centerLng + lngOffset,
      address: '${100 + index * 12} Main Street',
      isOpen24Hours: isAtm || random.nextBool(),
    );
  });
}