import 'package:flutter/material.dart';

/// Weather condition category for theming and animations.
enum WeatherMood {
  clear,
  partlyCloudy,
  cloudy,
  fog,
  rain,
  snow,
  thunderstorm,
}

WeatherMood weatherMoodFromCode(String code) {
  final c = int.tryParse(code) ?? 0;
  if (c == 0) return WeatherMood.clear;
  if (c >= 1 && c <= 3) return WeatherMood.partlyCloudy;
  if (c == 45 || c == 48) return WeatherMood.fog;
  if (c >= 51 && c <= 57) return WeatherMood.rain;
  if (c >= 61 && c <= 67) return WeatherMood.rain;
  if (c >= 71 && c <= 77) return WeatherMood.snow;
  if (c >= 80 && c <= 82) return WeatherMood.rain;
  if (c >= 85 && c <= 86) return WeatherMood.snow;
  if (c >= 95 && c <= 99) return WeatherMood.thunderstorm;
  return WeatherMood.cloudy;
}

/// Gradient colors for background based on weather and brightness.
List<Color> gradientColorsForMood(WeatherMood mood, Brightness brightness) {
  const warmStart = Color(0xFFFFB74D);
  const warmEnd = Color(0xFFFFCC80);
  const cloudyStart = Color(0xFF90A4AE);
  const cloudyEnd = Color(0xFFB0BEC5);
  const rainStart = Color(0xFF5C6BC0);
  const rainEnd = Color(0xFF7986CB);
  const snowStart = Color(0xFF81D4FA);
  const snowEnd = Color(0xFFB3E5FC);
  const stormStart = Color(0xFF37474F);
  const stormEnd = Color(0xFF546E7A);
  const fogStart = Color(0xFF78909C);
  const fogEnd = Color(0xFF90A4AE);

  if (brightness == Brightness.dark) {
    switch (mood) {
      case WeatherMood.clear:
        return [const Color(0xFF1A237E), const Color(0xFF0D47A1)];
      case WeatherMood.partlyCloudy:
        return [const Color(0xFF263238), const Color(0xFF37474F)];
      case WeatherMood.rain:
        return [const Color(0xFF283593), const Color(0xFF3949AB)];
      case WeatherMood.snow:
        return [const Color(0xFF01579B), const Color(0xFF0277BD)];
      case WeatherMood.thunderstorm:
        return [const Color(0xFF212121), const Color(0xFF37474F)];
      case WeatherMood.fog:
        return [const Color(0xFF37474F), const Color(0xFF455A64)];
      default:
        return [const Color(0xFF263238), const Color(0xFF37474F)];
    }
  }
  switch (mood) {
    case WeatherMood.clear:
      return [warmStart, warmEnd];
    case WeatherMood.partlyCloudy:
      return [cloudyStart, cloudyEnd];
    case WeatherMood.rain:
      return [rainStart, rainEnd];
    case WeatherMood.snow:
      return [snowStart, snowEnd];
    case WeatherMood.thunderstorm:
      return [stormStart, stormEnd];
    case WeatherMood.fog:
      return [fogStart, fogEnd];
    default:
      return [cloudyStart, cloudyEnd];
  }
}
