import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/beneficiary_model.dart';
import '../../../shared/widgets/responsive_scaffold_body.dart';
import '../controllers/beneficiary_controller.dart';

class BeneficiariesScreen extends StatelessWidget {
  const BeneficiariesScreen({super.key});

  void _showBeneficiaryForm(BuildContext context, BeneficiaryController controller, {Beneficiary? existing}) {
    final nicknameController = TextEditingController(text: existing?.nickname ?? '');
    final fullNameController = TextEditingController(text: existing?.fullName ?? '');
    final accountNumberController = TextEditingController(text: existing?.accountNumber ?? '');
    final bankNameController = TextEditingController(text: existing?.bankName ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                existing != null ? 'Edit Beneficiary' : 'Add Beneficiary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: nicknameController,
                decoration: const InputDecoration(labelText: 'Nickname', hintText: 'e.g. Mom, Landlord'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: accountNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Account Number'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bankNameController,
                decoration: const InputDecoration(labelText: 'Bank Name'),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nicknameController.text.trim().isEmpty ||
                        fullNameController.text.trim().isEmpty ||
                        accountNumberController.text.trim().isEmpty ||
                        bankNameController.text.trim().isEmpty) {
                      Get.snackbar('Missing Info', 'Please fill in all fields.', snackPosition: SnackPosition.BOTTOM);
                      return;
                    }

                    if (existing != null) {
                      controller.updateBeneficiary(
                        id: existing.id,
                        nickname: nicknameController.text.trim(),
                        fullName: fullNameController.text.trim(),
                        accountNumber: accountNumberController.text.trim(),
                        bankName: bankNameController.text.trim(),
                      );
                    } else {
                      controller.addBeneficiary(
                        nickname: nicknameController.text.trim(),
                        fullName: fullNameController.text.trim(),
                        accountNumber: accountNumberController.text.trim(),
                        bankName: bankNameController.text.trim(),
                      );
                    }

                    Navigator.of(sheetContext).pop();
                  },
                  child: Text(existing != null ? 'Save Changes' : 'Add Beneficiary'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BeneficiaryController controller, Beneficiary beneficiary) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Remove Beneficiary'),
        content: Text('Remove "${beneficiary.nickname}" from your beneficiaries?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Remove')),
        ],
      ),
    );

    if (confirmed == true) {
      controller.deleteBeneficiary(beneficiary.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BeneficiaryController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beneficiaries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Beneficiary',
            onPressed: () => _showBeneficiaryForm(context, controller),
          ),
        ],
      ),
      body: ResponsiveScaffoldBody(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.beneficiaries.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: subTextColor),
                    const SizedBox(height: 16),
                    Text('No beneficiaries yet', style: TextStyle(color: subTextColor, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text('Add someone to send money to quickly.', style: TextStyle(color: subTextColor, fontSize: 13)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _showBeneficiaryForm(context, controller),
                      child: const Text('Add Beneficiary'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.beneficiaries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final beneficiary = controller.beneficiaries[index];

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        beneficiary.nickname.isNotEmpty ? beneficiary.nickname[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(beneficiary.nickname, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          Text(
                            '${beneficiary.fullName} • ${beneficiary.bankName}',
                            style: TextStyle(color: subTextColor, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: () => _showBeneficiaryForm(context, controller, existing: beneficiary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                      onPressed: () => _confirmDelete(controller, beneficiary),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}