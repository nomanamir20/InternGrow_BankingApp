import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/bank_transaction_model.dart';

const Map<String, IconData> categoryIcons = {
  'Salary': Icons.work_outline,
  'Shopping': Icons.shopping_bag_outlined,
  'Bills': Icons.receipt_long_outlined,
  'Transfer': Icons.swap_horiz,
  'Food': Icons.restaurant_outlined,
  'Entertainment': Icons.movie_outlined,
};

class TransactionTile extends StatelessWidget {
  final BankTransaction transaction;
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final isCredit = transaction.type == TxnType.credit;
    final amountColor = isCredit ? AppColors.income : AppColors.expense;
    final icon = categoryIcons[transaction.category] ?? Icons.account_balance_wallet_outlined;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: amountColor.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: amountColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                    '${transaction.category} • ${DateFormat('MMM d, h:mm a').format(transaction.date)}',
                    style: TextStyle(color: subTextColor, fontSize: 11),
                  ),
                ],
              ),
            ),
            Text(
              '${isCredit ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(color: amountColor, fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}