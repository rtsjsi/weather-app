import 'package:flutter/foundation.dart';

import '../../../models/forecast_model.dart';
import '../../../models/location_model.dart';
import '../../../models/weather_model.dart';
import '../../../services/geocoding_service.dart';
import '../../../services/location_service.dart';
import '../../../services/weather_service.dart';

enum WeatherStatus { initial, loading, loaded, error }

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  final GeocodingService _geocodingService = GeocodingService();

  WeatherStatus _status = WeatherStatus.initial;
  WeatherModel? _weather;
  List<ForecastModel> _forecast = [];
  LocationModel? _currentLocation;
  String? _errorMessage;

  WeatherStatus get status => _status;
  WeatherModel? get weather => _weather;
  List<ForecastModel> get forecast => _forecast;
  LocationModel? get currentLocation => _currentLocation;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == WeatherStatus.loading;
  bool get hasError => _status == WeatherStatus.error;
  bool get hasData => _weather != null;

  Future<void> loadWeatherForCurrentLocation() async {
    _status = WeatherStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final location = await _locationService.getCurrentPosition();
      await _loadWeatherForLocation(location);
    } catch (e) {
      _status = WeatherStatus.error;
      _errorMessage =
          e.toString().replaceFirst('LocationServiceException: ', '');
      notifyListeners();
    }
  }

  Future<void> loadWeatherForLocation(LocationModel location) async {
    _status = WeatherStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _loadWeatherForLocation(location);
    } on WeatherServiceException catch (e) {
      _status = WeatherStatus.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _status = WeatherStatus.error;
      _errorMessage =
          e.toString().replaceFirst('WeatherServiceException: ', '');
      notifyListeners();
    }
  }

  Future<void> loadWeatherByCity(String cityName) async {
    _status = WeatherStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final location = await _geocodingService.getLocationFromPlace(cityName);
      if (location == null) {
        throw WeatherServiceException('City not found: $cityName');
      }
      await _loadWeatherForLocation(location);
    } catch (e) {
      _status = WeatherStatus.error;
      _errorMessage = e
          .toString()
          .replaceFirst('WeatherServiceException: ', '')
          .replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> _loadWeatherForLocation(LocationModel location) async {
    final cityName = location.cityName ?? '';
    final countryCode = location.countryCode ?? '';

    final result = await _weatherService.getWeatherAndForecast(
      location.latitude,
      location.longitude,
      cityName: cityName,
      countryCode: countryCode,
    );

    String displayCity = result.weather.cityName;
    if (displayCity.isEmpty) {
      displayCity = await _geocodingService.getCityName(
        location.latitude,
        location.longitude,
      );
    }

    _currentLocation = LocationModel(
      latitude: location.latitude,
      longitude: location.longitude,
      cityName: displayCity.isEmpty ? null : displayCity,
      countryCode: result.weather.countryCode.isNotEmpty
          ? result.weather.countryCode
          : null,
    );
    _weather = WeatherModel(
      temperature: result.weather.temperature,
      feelsLike: result.weather.feelsLike,
      humidity: result.weather.humidity,
      windSpeed: result.weather.windSpeed,
      description: result.weather.description,
      iconCode: result.weather.iconCode,
      cityName: displayCity,
      countryCode: result.weather.countryCode.isNotEmpty
          ? result.weather.countryCode
          : countryCode,
    );
    _forecast = result.forecast;
    _status = WeatherStatus.loaded;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_currentLocation != null) {
      await loadWeatherForLocation(_currentLocation!);
    } else {
      await loadWeatherForCurrentLocation();
    }
  }

  void reset() {
    _status = WeatherStatus.initial;
    _weather = null;
    _forecast = [];
    _currentLocation = null;
    _errorMessage = null;
    notifyListeners();
  }
}
