import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../data/database/local_data_service.dart';
import '../../../data/models/beneficiary_model.dart';

class BeneficiaryController extends GetxController {
  final LocalDataService _dataService = LocalDataService();

  final RxList<Beneficiary> beneficiaries = <Beneficiary>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadBeneficiaries();
  }

  Future<void> loadBeneficiaries() async {
    isLoading.value = true;
    beneficiaries.assignAll(await _dataService.getBeneficiaries());
    isLoading.value = false;
  }

  Beneficiary? byId(String id) {
    try {
      return beneficiaries.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addBeneficiary({
    required String nickname,
    required String fullName,
    required String accountNumber,
    required String bankName,
  }) async {
    final beneficiary = Beneficiary(
      id: const Uuid().v4(),
      nickname: nickname,
      fullName: fullName,
      accountNumber: accountNumber,
      bankName: bankName,
    );

    await _dataService.insertBeneficiary(beneficiary);
    await loadBeneficiaries();
  }

  Future<void> updateBeneficiary({
    required String id,
    required String nickname,
    required String fullName,
    required String accountNumber,
    required String bankName,
  }) async {
    final existing = byId(id);
    if (existing == null) return;

    final updated = existing.copyWith(
      nickname: nickname,
      fullName: fullName,
      accountNumber: accountNumber,
      bankName: bankName,
    );

    await _dataService.updateBeneficiary(updated);
    await loadBeneficiaries();
  }

  Future<void> deleteBeneficiary(String id) async {
    await _dataService.deleteBeneficiary(id);
    await loadBeneficiaries();
  }
}