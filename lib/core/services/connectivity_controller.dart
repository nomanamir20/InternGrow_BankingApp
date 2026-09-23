import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// Tracks real-time network connectivity app-wide. Any screen can watch
/// `isOnline` to adjust its behavior — most of this banking app works
/// fully offline already (all core data lives in local storage), so this
/// is mainly used to gracefully degrade the one feature that genuinely
/// needs the network: live currency rates.
class ConnectivityController extends GetxController {
  final RxBool isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    Connectivity().onConnectivityChanged.listen((results) {
      isOnline.value = !results.contains(ConnectivityResult.none);
    });
  }

  Future<void> _checkInitialConnection() async {
    final result = await Connectivity().checkConnectivity();
    isOnline.value = !result.contains(ConnectivityResult.none);
  }
}