/// One day of forecast (Open-Meteo daily or compatible).
class ForecastModel {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final String description;
  final String iconCode; // WMO code as string
  final int humidity;
  final double windSpeed;

  const ForecastModel({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.iconCode,
    this.humidity = 0,
    this.windSpeed = 0,
  });

  /// From Open-Meteo daily arrays (time, weather_code, temperature_2m_max, temperature_2m_min).
  static List<ForecastModel> listFromOpenMeteoDaily(
      Map<String, dynamic> daily) {
    final times = daily['time'] as List<dynamic>? ?? [];
    final codes = daily['weather_code'] as List<dynamic>? ?? [];
    final maxT = daily['temperature_2m_max'] as List<dynamic>? ?? [];
    final minT = daily['temperature_2m_min'] as List<dynamic>? ?? [];

    final list = <ForecastModel>[];
    for (var i = 0; i < times.length && i < 5; i++) {
      final dateStr = times[i] as String? ?? '';
      DateTime date;
      try {
        date = DateTime.parse(dateStr);
      } catch (_) {
        date = DateTime.now();
      }
      final code = (i < codes.length ? codes[i] as num? : null)?.toInt() ?? 0;
      final tMax = (i < maxT.length ? maxT[i] as num? : null)?.toDouble() ?? 0.0;
      final tMin = (i < minT.length ? minT[i] as num? : null)?.toDouble() ?? 0.0;
      list.add(ForecastModel(
        date: date,
        tempMin: tMin,
        tempMax: tMax,
        description: _wmoDescription(code),
        iconCode: code.toString(),
      ));
    }
    return list;
  }

  static String _wmoDescription(int code) {
    if (code == 0) return 'Clear';
    if (code <= 3) return 'Partly cloudy';
    if (code == 45 || code == 48) return 'Fog';
    if (code >= 51 && code <= 57) return 'Drizzle';
    if (code >= 61 && code <= 67) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Showers';
    if (code >= 85 && code <= 86) return 'Snow showers';
    if (code >= 95) return 'Thunderstorm';
    return 'Cloudy';
  }
}
