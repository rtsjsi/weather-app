import 'package:geolocator/geolocator.dart';

import '../models/location_model.dart';

class LocationServiceException implements Exception {
  final String message;

  LocationServiceException(this.message);

  @override
  String toString() => 'LocationServiceException: $message';
}

class LocationService {
  Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkPermission() async {
    return Geolocator.checkPermission();
  }

  Future<LocationPermission> requestPermission() async {
    return Geolocator.requestPermission();
  }

  Future<LocationModel> getCurrentPosition() async {
    final enabled = await isLocationServiceEnabled();
    if (!enabled) {
      throw LocationServiceException('Location services are disabled');
    }
    var permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
          'Location permission denied. Please enable in settings.');
    }
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
    return LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
