import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/connectivity_controller.dart';
import '../../core/theme/app_colors.dart';

/// A persistent banner shown whenever the device has no network connection
/// — honest, always-visible feedback rather than letting features silently
/// fail. Since almost everything in this app works fully offline (local
/// SQLite/web storage), this is reassuring rather than alarming: it tells
/// the user exactly what still works and what doesn't.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivity = Get.find<ConnectivityController>();

    return Obx(() {
      if (connectivity.isOnline.value) return const SizedBox.shrink();

      return Material(
        color: AppColors.warning,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.cloud_off, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You\'re offline. Banking features work normally — currency rates need a connection.',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}