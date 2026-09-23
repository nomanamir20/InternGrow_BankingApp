import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/connectivity_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../controllers/currency_controller.dart';

class CurrencyExchangeScreen extends StatefulWidget {
  const CurrencyExchangeScreen({super.key});

  @override
  State<CurrencyExchangeScreen> createState() => _CurrencyExchangeScreenState();
}

class _CurrencyExchangeScreenState extends State<CurrencyExchangeScreen> {
  final _amountController = TextEditingController(text: '100');
  late final CurrencyController _controller;
  String _targetCurrency = 'EUR';

  @override
  void initState() {
    super.initState();
    _controller = Get.find<CurrencyController>();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Exchange'),
        actions: [
          Obx(() => IconButton(
                icon: _controller.isLoading.value
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh),
                onPressed: _controller.isLoading.value ? null : _controller.fetchRates,
              )),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.rates.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

                if (_controller.hasError.value && _controller.rates.isEmpty) {
          final connectivity = Get.find<ConnectivityController>();
          final isOffline = !connectivity.isOnline.value;

          return ErrorStateView(
            icon: isOffline ? Icons.cloud_off : Icons.wifi_off,
            title: isOffline ? 'You\'re currently offline' : 'Could not load exchange rates',
            message: isOffline
                ? 'Live currency rates need an internet connection. All other banking features still work normally.'
                : 'Check your internet connection and try again.',
            onRetry: _controller.fetchRates,
          );
        }

        final amount = double.tryParse(_amountController.text.trim()) ?? 0;
        final converted = _controller.convert(amount, _targetCurrency);
        final rate = _controller.rates[_targetCurrency];

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // From currency
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('From', style: TextStyle(color: subTextColor, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                        ),
                      ),
                      _CurrencyDropdown(
                        value: _controller.baseCurrency.value,
                        onChanged: (value) {
                          if (value != null) _controller.changeBaseCurrency(value);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Icon(Icons.swap_vert, color: AppColors.primary),
              ),
            ),

            // To currency
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('To', style: TextStyle(color: subTextColor, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          converted != null ? converted.toStringAsFixed(2) : '—',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ),
                      _CurrencyDropdown(
                        value: _targetCurrency,
                        onChanged: (value) {
                          if (value != null) setState(() => _targetCurrency = value);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (rate != null) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '1 ${_controller.baseCurrency.value} = ${rate.toStringAsFixed(4)} $_targetCurrency',
                  style: TextStyle(color: subTextColor, fontSize: 13),
                ),
              ),
            ],

            if (_controller.lastUpdated.value.isNotEmpty) ...[
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Live rates • Updated ${_controller.lastUpdated.value}',
                  style: TextStyle(color: subTextColor, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            const SizedBox(height: 28),
            Text('Popular Rates', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            for (final currency in CurrencyController.commonCurrencies)
              if (currency != _controller.baseCurrency.value)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(currency, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(
                          _controller.rates[currency]?.toStringAsFixed(4) ?? '—',
                          style: TextStyle(color: subTextColor),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        );
      }),
    );
  }
}

class _CurrencyDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _CurrencyDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      underline: const SizedBox.shrink(),
      items: [
        for (final currency in CurrencyController.commonCurrencies)
          DropdownMenuItem(value: currency, child: Text(currency, style: const TextStyle(fontWeight: FontWeight.w700))),
      ],
      onChanged: onChanged,
    );
  }
}