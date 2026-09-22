import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/notification_service.dart';
import '../../data/models/app_notification_model.dart';
import '../../features/notifications/controllers/notification_center_controller.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/transactions/screens/transactions_screen.dart';
import '../../features/currency/screens/currency_exchange_screen.dart';
import '../../features/atm_locator/screens/atm_locator_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import 'notification_banner.dart';

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

    return Obx(() {
      return Scaffold(
        body: Column(
          children: [
            const NotificationBanner(),
            Expanded(
              child: IndexedStack(
                index: controller.currentIndex.value,
                children: screens,
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Transactions'),
            BottomNavigationBarItem(icon: Icon(Icons.currency_exchange), label: 'Exchange'),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'ATM/Branch'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      );
    });
  }
}