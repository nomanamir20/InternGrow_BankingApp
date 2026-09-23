import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/bank_transaction_model.dart';
import '../../../data/models/beneficiary_model.dart';
import '../../beneficiaries/controllers/beneficiary_controller.dart';
import '../../home/controllers/account_controller.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  late final AccountController _accountController;
  late final BeneficiaryController _beneficiaryController;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  Beneficiary? _selectedBeneficiary;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _accountController = Get.find<AccountController>();
    _beneficiaryController = Get.find<BeneficiaryController>();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleTransfer() async {
    if (_selectedBeneficiary == null) {
      Get.snackbar('Select a Recipient', 'Please choose a beneficiary to send money to.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      Get.snackbar('Invalid Amount', 'Please enter a valid amount.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final account = _accountController.primaryAccount;
    if (account == null) return;

    if (amount > account.balance) {
      Get.snackbar('Insufficient Funds', 'You don\'t have enough balance for this transfer.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => _isSending = true);

    await _accountController.applyTransaction(
      accountId: account.id,
      type: TxnType.debit,
      amount: amount,
      category: 'Transfer',
      description: 'Transfer to ${_selectedBeneficiary!.nickname}${_noteController.text.trim().isNotEmpty ? ' — ${_noteController.text.trim()}' : ''}',
      beneficiaryId: _selectedBeneficiary!.id,
    );

    setState(() => _isSending = false);

    Get.back();
    Get.snackbar(
      'Transfer Successful',
      '\$${amount.toStringAsFixed(2)} sent to ${_selectedBeneficiary!.nickname}.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Money')),
      body: Obx(() {
        final account = _accountController.primaryAccount;
        final beneficiaries = _beneficiaryController.beneficiaries;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Available Balance', style: TextStyle(color: subTextColor, fontSize: 13)),
                  Text(
                    '\$${(account?.balance ?? 0).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('Select Recipient', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),

            if (beneficiaries.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Text('No beneficiaries yet.', style: TextStyle(color: subTextColor)),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () => Get.toNamed('/beneficiaries'),
                      child: const Text('Add a Beneficiary'),
                    ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final beneficiary in beneficiaries)
                    ChoiceChip(
                      label: Text(beneficiary.nickname),
                      selected: _selectedBeneficiary?.id == beneficiary.id,
                      onSelected: (_) => setState(() => _selectedBeneficiary = beneficiary),
                    ),
                ],
              ),
            const SizedBox(height: 24),

            Text('Amount', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: AppColors.primary),
              decoration: const InputDecoration(prefixText: '\$ ', hintText: '0.00'),
            ),
            const SizedBox(height: 24),

            Text('Note (optional)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(hintText: 'What\'s this for?'),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSending ? null : _handleTransfer,
                child: _isSending
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Send Money'),
              ),
            ),
          ],
        );
      }),
    );
  }
}