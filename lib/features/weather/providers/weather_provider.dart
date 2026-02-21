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
  WeatherStatus get status => _status;

  WeatherModel? _weather;
  WeatherModel? get weather => _weather;

  List<ForecastModel> _forecast = [];
  List<ForecastModel> get forecast => _forecast;

  LocationModel? _currentLocation;
  LocationModel? get currentLocation => _currentLocation;

  String? _errorMessage;
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
      final location =
          await _geocodingService.getLocationFromPlace(cityName);
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
    final weather = await _weatherService.getCurrentWeather(
      location.latitude,
      location.longitude,
    );
    final forecastList = await _weatherService.getForecast(
      location.latitude,
      location.longitude,
    );
    String? cityDisplay = weather.cityName;
    if (cityDisplay.isEmpty) {
      cityDisplay = await _geocodingService.getCityName(
        location.latitude,
        location.longitude,
      );
    }
    _currentLocation = LocationModel(
      latitude: location.latitude,
      longitude: location.longitude,
      cityName: cityDisplay,
      countryCode:
          weather.countryCode.isNotEmpty ? weather.countryCode : null,
    );
    _weather = weather;
    _forecast = forecastList;
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
