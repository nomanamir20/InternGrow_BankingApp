import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../features/notifications/controllers/notification_center_controller.dart';

/// Shows the most recent unread notification as a dismissible top banner,
/// visible regardless of which tab is active.
class NotificationBanner extends StatelessWidget {
  const NotificationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationCenterController>();

    return Obx(() {
      final latest = controller.notifications.isNotEmpty ? controller.notifications.first : null;
      if (latest == null || latest.isRead) return const SizedBox.shrink();

      return Material(
        color: AppColors.primary,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.notifications_active, color: AppColors.accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(latest.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                      Text(latest.body, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  onPressed: () => controller.markAsRead(latest.id),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}