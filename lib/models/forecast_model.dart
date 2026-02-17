/// Daily forecast item from OpenWeatherMap 5-day forecast API
class ForecastModel {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;

  const ForecastModel({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>? ?? {};
    final weather = (json['weather'] as List<dynamic>?)?[0] as Map<String, dynamic>? ?? {};
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final dt = (json['dt'] as int?) ?? 0;
    final temp = (main['temp'] as num?)?.toDouble();
    final tempMin = (main['temp_min'] as num?)?.toDouble();
    final tempMax = (main['temp_max'] as num?)?.toDouble();

    return ForecastModel(
      date: DateTime.fromMillisecondsSinceEpoch(dt * 1000),
      tempMin: tempMin ?? temp ?? 0,
      tempMax: tempMax ?? temp ?? 0,
      description: (weather['description'] as String?) ?? '',
      iconCode: (weather['icon'] as String?) ?? '01d',
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
    );
  }
}
