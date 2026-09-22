import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/branch_mock_data.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/branch_model.dart';

class AtmLocatorScreen extends StatefulWidget {
  const AtmLocatorScreen({super.key});

  @override
  State<AtmLocatorScreen> createState() => _AtmLocatorScreenState();
}

class _AtmLocatorScreenState extends State<AtmLocatorScreen> {
  final _mapController = MapController();
  final _locationService = LocationService();

  // Default to a neutral starting point until real location is available.
  LatLng _center = const LatLng(24.8607, 67.0011);
  List<Branch> _branches = [];
  bool _isLocating = false;
  Branch? _selectedBranch;

  @override
  void initState() {
    super.initState();
    _branches = generateNearbyBranches(_center.latitude, _center.longitude);
    _useCurrentLocation();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);

    final position = await _locationService.getCurrentPosition();

    if (!mounted) return;
    setState(() => _isLocating = false);

    if (position == null) return;

    final newCenter = LatLng(position.latitude, position.longitude);
    setState(() {
      _center = newCenter;
      _branches = generateNearbyBranches(newCenter.latitude, newCenter.longitude);
    });
    _mapController.move(newCenter, 13);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(title: const Text('ATM / Branch Locator')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.interngrow.interngrow_banking_app',
                    ),
                    MarkerLayer(
                      markers: [
                        // User's current position
                        Marker(
                          point: _center,
                          width: 24,
                          height: 24,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                          ),
                        ),
                        for (final branch in _branches)
                          Marker(
                            point: LatLng(branch.latitude, branch.longitude),
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedBranch = branch),
                              child: Icon(
                                branch.type == BranchType.atm ? Icons.local_atm : Icons.account_balance,
                                color: _selectedBranch?.id == branch.id ? AppColors.accent : AppColors.primary,
                                size: 36,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'locate-me',
                    onPressed: _isLocating ? null : _useCurrentLocation,
                    child: _isLocating
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),

          // Nearby list
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _branches.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final branch = _branches[index];
                  final isSelected = _selectedBranch?.id == branch.id;

                  return InkWell(
                    onTap: () {
                      setState(() => _selectedBranch = branch);
                      _mapController.move(LatLng(branch.latitude, branch.longitude), 15);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : null,
                        border: Border.all(color: isSelected ? AppColors.primary : borderColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            branch.type == BranchType.atm ? Icons.local_atm : Icons.account_balance,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(branch.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                Text(branch.address, style: TextStyle(color: subTextColor, fontSize: 11)),
                              ],
                            ),
                          ),
                          if (branch.isOpen24Hours)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('24/7', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w700)),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}