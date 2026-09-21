import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../shared/widgets/profile_avatar.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Log Out')),
        ],
      ),
    );

    if (confirmed == true) {
      Get.find<AuthController>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    final themeController = Get.find<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Obx(() {
        final profile = profileController.profile.value;

        if (profileController.isLoading.value || profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final initial = profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?';

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Stack(
                children: [
                  ProfileAvatar(photoPath: profile.photoPath, initial: initial, radius: 48),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: profileController.updatePhoto,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Column(
                children: [
                  Text(profile.fullName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(profile.email, style: TextStyle(color: subTextColor, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text('Account', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.edit_outlined,
              title: 'Edit Personal Details',
              onTap: () => Get.toNamed(AppRoutes.editProfile),
            ),
            _SettingsTile(
              icon: Icons.people_outline,
              title: 'Beneficiaries',
              onTap: () => Get.toNamed(AppRoutes.beneficiaries),
            ),

            const SizedBox(height: 20),
            Text('Preferences', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Obx(() => _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  trailing: Switch(
                    value: themeController.isDarkMode.value,
                    onChanged: themeController.toggleTheme,
                  ),
                )),

            const SizedBox(height: 20),
            Text('Account Actions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.logout,
              title: 'Log Out',
              titleColor: AppColors.error,
              iconColor: AppColors.error,
              onTap: () => _handleLogout(context),
            ),

            const SizedBox(height: 20),
            Center(child: Text('InternGrow Bank v1.0.0', style: TextStyle(color: subTextColor, fontSize: 12))),
          ],
        );
      }),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.iconColor,
    this.titleColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor))),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: titleColor)),
            ),
            trailing ?? const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}