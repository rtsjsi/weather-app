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
  final String _apiKey;
  final String _baseUrl = AppConfig.weatherApiBaseUrl;
  final http.Client _client = http.Client();

  WeatherService({String? apiKey}) : _apiKey = apiKey ?? AppConfig.apiKey;

  Future<WeatherModel> getCurrentWeather(double lat, double lon) async {
    _ensureApiKey();
    final uri = Uri.parse('$_baseUrl/weather').replace(queryParameters: {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'appid': _apiKey,
      'units': 'metric',
    });
    final response = await _getWithErrorHandling(uri);
    return _handleWeatherResponse(response);
  }

  Future<WeatherModel> getWeatherByCity(String cityName) async {
    _ensureApiKey();
    final uri = Uri.parse('$_baseUrl/weather').replace(queryParameters: {
      'q': cityName,
      'appid': _apiKey,
      'units': 'metric',
    });
    final response = await _getWithErrorHandling(uri);
    return _handleWeatherResponse(response);
  }

  Future<List<ForecastModel>> getForecast(double lat, double lon) async {
    _ensureApiKey();
    final uri = Uri.parse('$_baseUrl/forecast').replace(queryParameters: {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'appid': _apiKey,
      'units': 'metric',
    });
    final response = await _getWithErrorHandling(uri);
    if (response.statusCode != 200) {
      throw WeatherServiceException(
          'Failed to load forecast: ${response.body}', response.statusCode);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['list'] as List<dynamic>? ?? [];
    final byDay = <String, Map<String, dynamic>>{};
    for (final item in list) {
      final map = item as Map<String, dynamic>;
      final dt = map['dt'] as int? ?? 0;
      final date = DateTime.fromMillisecondsSinceEpoch(dt * 1000);
      final dayKey = '${date.year}-${date.month}-${date.day}';
      if (!byDay.containsKey(dayKey) || date.hour >= 11) {
        byDay[dayKey] = map;
      }
    }
    final sorted = byDay.values.toList()
      ..sort((a, b) =>
          ((a['dt'] as int?) ?? 0).compareTo((b['dt'] as int?) ?? 0));
    return sorted.take(5).map((e) => ForecastModel.fromJson(e)).toList();
  }

  WeatherModel _handleWeatherResponse(http.Response response) {
    if (response.statusCode != 200) {
      String message = 'Failed to load weather';
      try {
        final body =
            jsonDecode(response.body) as Map<String, dynamic>;
        message = body['message'] as String? ?? message;
      } catch (_) {}
      throw WeatherServiceException(message, response.statusCode);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return WeatherModel.fromJson(data);
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

  void _ensureApiKey() {
    if (_apiKey.isEmpty) {
      throw WeatherServiceException(
          'API key not set. Run with: flutter run --dart-define=WEATHER_API_KEY=your_key');
    }
  }
}
