import 'package:get/get.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/transactions/screens/transfer_screen.dart';
import '../../features/beneficiaries/screens/beneficiaries_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../shared/widgets/scaffold_with_nav_bar.dart';
import '../../shared/widgets/splash_screen.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.signUp, page: () => const SignUpScreen()),
    GetPage(name: AppRoutes.home, page: () => const ScaffoldWithNavBar()),
    GetPage(name: AppRoutes.transfer, page: () => const TransferScreen()),
    GetPage(name: AppRoutes.beneficiaries, page: () => const BeneficiariesScreen()),
    GetPage(name: AppRoutes.editProfile, page: () => const EditProfileScreen()),
  ];
}