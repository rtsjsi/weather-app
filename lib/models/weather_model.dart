/// Current weather data from OpenWeatherMap API
class WeatherModel {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String iconCode;
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

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>? ?? {};
    final weather = (json['weather'] as List<dynamic>?)?[0] as Map<String, dynamic>? ?? {};
    final wind = json['wind'] as Map<String, dynamic>? ?? {};

    return WeatherModel(
      temperature: (main['temp'] as num?)?.toDouble() ?? 0,
      feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0,
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
      description: (weather['description'] as String?) ?? '',
      iconCode: (weather['icon'] as String?) ?? '01d',
      cityName: (json['name'] as String?) ?? '',
      countryCode: (json['sys'] as Map<String, dynamic>?)?['country'] as String? ?? '',
    );
  }
}
