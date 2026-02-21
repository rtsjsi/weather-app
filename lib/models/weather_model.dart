/// Current weather (Open-Meteo or compatible).
class WeatherModel {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String iconCode; // WMO code as string for Open-Meteo
  final String cityName;
  final String countryCode;

  const WeatherModel({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.iconCode,
    required this.cityName,
    required this.countryCode,
  });

  /// From Open-Meteo current object.
  factory WeatherModel.fromOpenMeteo(
    Map<String, dynamic> current, {
    String cityName = '',
    String countryCode = '',
  }) {
    final code = (current['weather_code'] as num?)?.toInt() ?? 0;
    return WeatherModel(
      temperature: (current['temperature_2m'] as num?)?.toDouble() ?? 0,
      feelsLike: (current['apparent_temperature'] as num?)?.toDouble() ??
          (current['temperature_2m'] as num?)?.toDouble() ?? 0,
      humidity: (current['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      windSpeed: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0,
      description: _wmoDescription(code),
      iconCode: code.toString(),
      cityName: cityName,
      countryCode: countryCode,
    );
  }

  static String _wmoDescription(int code) {
    if (code == 0) return 'Clear sky';
    if (code <= 3) return 'Partly cloudy';
    if (code == 45 || code == 48) return 'Foggy';
    if (code >= 51 && code <= 57) return 'Drizzle';
    if (code >= 61 && code <= 67) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain showers';
    if (code >= 85 && code <= 86) return 'Snow showers';
    if (code == 95) return 'Thunderstorm';
    if (code >= 96) return 'Thunderstorm with hail';
    return 'Unknown';
  }
}
