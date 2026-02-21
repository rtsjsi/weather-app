import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import '../models/forecast_model.dart';
import '../models/weather_model.dart';

class WeatherServiceException implements Exception {
  final String message;
  final int? statusCode;

  WeatherServiceException(this.message, [this.statusCode]);

  @override
  String toString() =>
      'WeatherServiceException: $message (status: $statusCode)';
}

class WeatherService {
  final http.Client _client = http.Client();

  /// Fetches current weather + 5-day forecast from Open-Meteo (no API key).
  /// Pass [cityName] and [countryCode] for display; Open-Meteo does not return place names.
  Future<({WeatherModel weather, List<ForecastModel> forecast})>
      getWeatherAndForecast(
    double lat,
    double lon, {
    String cityName = '',
    String countryCode = '',
  }) async {
    final uri = Uri.parse('${AppConfig.forecastBaseUrl}/forecast').replace(
      queryParameters: {
        'latitude': lat.toString(),
        'longitude': lon.toString(),
        'current': [
          'temperature_2m',
          'relative_humidity_2m',
          'apparent_temperature',
          'weather_code',
          'wind_speed_10m',
        ].join(','),
        'daily': [
          'weather_code',
          'temperature_2m_max',
          'temperature_2m_min',
        ].join(','),
        'timezone': 'auto',
      },
    );

    final response = await _getWithErrorHandling(uri);
    if (response.statusCode != 200) {
      String msg = 'Failed to load weather';
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>?;
        msg = body?['reason'] as String? ?? msg;
      } catch (_) {}
      throw WeatherServiceException(msg, response.statusCode);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final current = data['current'] as Map<String, dynamic>? ?? {};
    final daily = data['daily'] as Map<String, dynamic>? ?? {};

    final weather = WeatherModel.fromOpenMeteo(
      current,
      cityName: cityName,
      countryCode: countryCode,
    );
    final forecast = ForecastModel.listFromOpenMeteoDaily(daily);
    return (weather: weather, forecast: forecast);
  }

  Future<http.Response> _getWithErrorHandling(Uri uri) async {
    try {
      return await _client.get(uri).timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw WeatherServiceException(
                'Request timed out. Check your internet connection.'),
          );
    } on SocketException catch (_) {
      throw WeatherServiceException(
          'No internet connection. Please check your network and try again.');
    } on TimeoutException catch (_) {
      throw WeatherServiceException(
          'Request timed out. Check your internet connection.');
    } on HandshakeException catch (_) {
      throw WeatherServiceException(
          'Connection error. Please check your internet connection.');
    }
  }
}
