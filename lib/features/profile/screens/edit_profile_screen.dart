import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final ProfileController _controller;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileController>();
    final profile = _controller.profile.value;
    _nameController = TextEditingController(text: profile?.fullName ?? '');
    _phoneController = TextEditingController(text: profile?.phoneNumber ?? '');
    _addressController = TextEditingController(text: profile?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_nameController.text.trim().isEmpty) {
      Get.snackbar('Name Required', 'Please enter your full name.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => _isSaving = true);

    await _controller.updateProfile(
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    setState(() => _isSaving = false);
    Get.back();
    Get.snackbar('Profile Updated', 'Your details have been saved.', snackPosition: SnackPosition.BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppTextField(
            controller: _nameController,
            label: 'Full Name',
            hintText: 'Enter your full name',
            prefixIcon: const Icon(Icons.person_outline),
          ),
          const SizedBox(height: 20),
          AppTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hintText: '+1 234 567 8900',
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
          const SizedBox(height: 20),
          AppTextField(
            controller: _addressController,
            label: 'Address',
            hintText: 'Enter your address',
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.home_outlined),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _handleSave,
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}