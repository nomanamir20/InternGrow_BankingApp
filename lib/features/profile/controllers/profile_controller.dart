import 'package:get/get.dart';

import '../../../core/services/image_storage_service.dart';
import '../../../data/database/local_data_service.dart';
import '../../../data/models/user_profile_model.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final LocalDataService _dataService = LocalDataService();
  final ImageStorageService _imageService = ImageStorageService();

  final Rxn<UserProfile> profile = Rxn<UserProfile>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser;
    if (user == null) return;

    isLoading.value = true;

    var existing = await _dataService.getProfile(user.uid);

    // First-ever load: seed a profile record from the Firebase Auth
    // identity, so there's always something to edit rather than a blank
    // form the very first time someone visits Profile.
    existing ??= UserProfile(
      uid: user.uid,
      fullName: user.displayName ?? 'InternGrow User',
      email: user.email ?? '',
    );

    await _dataService.saveProfile(existing);
    profile.value = existing;

    isLoading.value = false;
  }

  Future<void> updateProfile({
    required String fullName,
    required String phoneNumber,
    required String address,
  }) async {
    final current = profile.value;
    if (current == null) return;

    final updated = current.copyWith(
      fullName: fullName,
      phoneNumber: phoneNumber,
      address: address,
    );

    await _dataService.saveProfile(updated);
    profile.value = updated;

    final authController = Get.find<AuthController>();
    // Keep Firebase Auth's own displayName in sync too, so it stays
    // consistent anywhere else in the app that reads it directly.
    await authController.updateDisplayNamePublic(fullName);
  }

  Future<void> updatePhoto() async {
    final newPath = await _imageService.pickAndStoreProfilePhoto();
    if (newPath == null) return;

    final current = profile.value;
    if (current == null) return;

    final updated = current.copyWith(photoPath: newPath);
    await _dataService.saveProfile(updated);
    profile.value = updated;
  }
}