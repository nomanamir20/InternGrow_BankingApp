import 'package:get/get.dart';

import '../../../core/services/currency_api_service.dart';

class CurrencyController extends GetxController {
  final CurrencyApiService _api = CurrencyApiService();

  final RxString baseCurrency = 'USD'.obs;
  final RxMap<String, double> rates = <String, double>{}.obs;
  final RxString lastUpdated = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  // A curated set of common currencies, so the picker isn't an
  // overwhelming list of 160+ codes.
  static const commonCurrencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'CNY',
    'INR', 'PKR', 'AED', 'SAR', 'SGD', 'NZD', 'ZAR', 'BRL',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchRates();
  }

  Future<void> fetchRates() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final result = await _api.fetchRates(baseCurrency.value);
      rates.assignAll(result.rates);
      lastUpdated.value = result.lastUpdated;
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeBaseCurrency(String currency) async {
    baseCurrency.value = currency;
    await fetchRates();
  }

  double? convert(double amount, String toCurrency) {
    final rate = rates[toCurrency];
    if (rate == null) return null;
    return amount * rate;
  }
}