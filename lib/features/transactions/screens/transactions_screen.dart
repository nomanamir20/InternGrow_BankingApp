import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/bank_transaction_model.dart';
import '../../../shared/widgets/transaction_tile.dart';
import '../../home/controllers/account_controller.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchController = TextEditingController();
  late final AccountController _controller;

  TxnType? _typeFilter;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AccountController>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BankTransaction> get _filteredTransactions {
    var results = _controller.transactions.toList();

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      results = results.where((t) {
        return t.description.toLowerCase().contains(query) || t.category.toLowerCase().contains(query);
      }).toList();
    }

    if (_typeFilter != null) {
      results = results.where((t) => t.type == _typeFilter).toList();
    }

    if (_dateRange != null) {
      results = results.where((t) {
        final date = DateTime(t.date.year, t.date.month, t.date.day);
        final start = DateTime(_dateRange!.start.year, _dateRange!.start.month, _dateRange!.start.day);
        final end = DateTime(_dateRange!.end.year, _dateRange!.end.month, _dateRange!.end.day);
        return !date.isBefore(start) && !date.isAfter(end);
      }).toList();
    }

    return results;
  }

  bool get _hasActiveFilters => _typeFilter != null || _dateRange != null;

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  void _clearFilters() {
    setState(() {
      _typeFilter = null;
      _dateRange = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = _filteredTransactions;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search by description or category...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() => _searchController.clear()),
                        )
                      : null,
                  isDense: true,
                ),
              ),
            ),

            // Filter row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(
                      label: 'All',
                      isSelected: _typeFilter == null,
                      onTap: () => setState(() => _typeFilter = null),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Credit',
                      isSelected: _typeFilter == TxnType.credit,
                      color: AppColors.income,
                      onTap: () => setState(() => _typeFilter = TxnType.credit),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Debit',
                      isSelected: _typeFilter == TxnType.debit,
                      color: AppColors.expense,
                      onTap: () => setState(() => _typeFilter = TxnType.debit),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: _dateRange == null
                          ? 'Date Range'
                          : '${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}',
                      isSelected: _dateRange != null,
                      icon: Icons.calendar_today_outlined,
                      onTap: _pickDateRange,
                    ),
                    if (_hasActiveFilters) ...[
                      const SizedBox(width: 8),
                      ActionChip(
                        label: const Text('Clear'),
                        onPressed: _clearFilters,
                        avatar: const Icon(Icons.close, size: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 56, color: subTextColor),
                            const SizedBox(height: 12),
                            Text(
                              _controller.transactions.isEmpty ? 'No transactions yet.' : 'No transactions match your search.',
                              style: TextStyle(color: subTextColor),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: results.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) => TransactionTile(transaction: results[index]),
                    ),
            ),
          ],
        );
      }),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final IconData? icon;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: chipColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: isSelected ? Colors.white : chipColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : chipColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}