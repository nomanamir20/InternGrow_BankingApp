import 'package:dio/dio.dart';

/// Fetches real, live exchange rates from ExchangeRate-API's free tier —
/// no API key or signup required for the open endpoint.
/// https://www.exchangerate-api.com/docs/free
class CurrencyApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://open.er-api.com/v6',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// Returns a map of currency code -> rate relative to [baseCurrency],
  /// plus the timestamp the rates were last updated.
  Future<({Map<String, double> rates, String lastUpdated})> fetchRates(String baseCurrency) async {
    final response = await _dio.get('/latest/$baseCurrency');

    final data = response.data as Map<String, dynamic>;

    if (data['result'] != 'success') {
      throw Exception('Failed to fetch exchange rates');
    }

    final ratesRaw = data['rates'] as Map<String, dynamic>;
    final rates = ratesRaw.map((key, value) => MapEntry(key, (value as num).toDouble()));

    return (
      rates: rates,
      lastUpdated: data['time_last_update_utc'] as String? ?? '',
    );
  }
}