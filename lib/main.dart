import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'features/profile/controllers/profile_controller.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'data/database/local_data_service.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/home/controllers/account_controller.dart';
import 'features/beneficiaries/controllers/beneficiary_controller.dart';
import 'features/currency/controllers/currency_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Seed a starter account/transactions on first-ever launch, regardless
  // of platform — LocalDataService internally handles SQLite vs. web
  // storage, so this call is identical either way.
  await LocalDataService().seedIfEmpty();

         Get.put(ThemeController());
         Get.put(AuthController(), permanent: true);
         Get.put(ProfileController(), permanent: true);
         Get.put(AccountController(), permanent: true);
         Get.put(BeneficiaryController(), permanent: true);
         Get.put(CurrencyController(), permanent: true);

  runApp(const InternGrowBankingApp());
}

class InternGrowBankingApp extends StatelessWidget {
  const InternGrowBankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      return GetMaterialApp(
        title: 'InternGrow Bank',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        initialRoute: AppRoutes.splash,
        getPages: AppPages.pages,
      );
    });
  }
}