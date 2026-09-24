import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/notification_service.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/app_notification_model.dart';
import '../../features/notifications/controllers/notification_center_controller.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/transactions/screens/transactions_screen.dart';
import '../../features/currency/screens/currency_exchange_screen.dart';
import '../../features/atm_locator/screens/atm_locator_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import 'notification_banner.dart';
import 'offline_banner.dart';

class NavShellController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeTab(int index) => currentIndex.value = index;
}

class ScaffoldWithNavBar extends StatefulWidget {
  const ScaffoldWithNavBar({super.key});

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  final _notificationService = NotificationService();

  static const _destinations = [
    (icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Home'),
    (icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'Transactions'),
    (icon: Icons.currency_exchange, activeIcon: Icons.currency_exchange, label: 'Exchange'),
    (icon: Icons.map_outlined, activeIcon: Icons.map, label: 'ATM/Branch'),
    (icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initNotifications());
  }

  Future<void> _initNotifications() async {
    await _notificationService.initialize(
      onForegroundMessage: (RemoteMessage message) {
        final title = message.notification?.title ?? 'Notification';
        final body = message.notification?.body ?? '';
        Get.find<NotificationCenterController>().add(
          type: AppNotificationType.general,
          title: title,
          body: body,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavShellController(), permanent: true);

    final screens = [
      const HomeScreen(),
      const TransactionsScreen(),
      const CurrencyExchangeScreen(),
      const AtmLocatorScreen(),
      const ProfileScreen(),
    ];

    final isWideScreen = Responsive.isDesktop(context);

    return Obx(() {
      final content = Column(
        children: [
          const OfflineBanner(),
          const NotificationBanner(),
          Expanded(
            child: IndexedStack(
              index: controller.currentIndex.value,
              children: screens,
            ),
          ),
        ],
      );

      // Desktop/wide web: side navigation rail instead of a bottom bar —
      // the standard responsive pattern for wide screens, since a bottom
      // bar stretched across a 1400px window looks and behaves poorly.
      if (isWideScreen) {
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: controller.currentIndex.value,
                onDestinationSelected: controller.changeTab,
                labelType: NavigationRailLabelType.all,
                destinations: [
                  for (final dest in _destinations)
                    NavigationRailDestination(
                      icon: Icon(dest.icon),
                      selectedIcon: Icon(dest.activeIcon),
                      label: Text(dest.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: content),
            ],
          ),
        );
      }

      // Mobile/tablet: standard bottom navigation bar.
      return Scaffold(
        body: content,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: [
            for (final dest in _destinations)
              BottomNavigationBarItem(
                icon: Icon(dest.icon),
                activeIcon: Icon(dest.activeIcon),
                label: dest.label,
              ),
          ],
        ),
      );
    });
  }
}