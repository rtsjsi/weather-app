/// App configuration and constants.
/// Set API key via: flutter run --dart-define=WEATHER_API_KEY=your_key
class AppConfig {
  static const String appName = 'Weather';

  static const String weatherApiBaseUrl =
      'https://api.openweathermap.org/data/2.5';

  static String get apiKey {
    const key = String.fromEnvironment('WEATHER_API_KEY', defaultValue: '');
    return key;
  }
}
