/// App configuration and constants.
/// API key is passed via --dart-define=WEATHER_API_KEY=xxx at build/run time.
class AppConfig {
  static const String appName = 'Weather App';

  /// OpenWeatherMap API base URL
  static const String weatherApiBaseUrl = 'https://api.openweathermap.org/data/2.5';

  /// Get API key from compile-time define. Fallback for development only.
  static String get apiKey {
    const key = String.fromEnvironment(
      'WEATHER_API_KEY',
      defaultValue: '',
    );
    return key;
  }
}
