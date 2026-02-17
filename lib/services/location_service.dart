import 'package:geolocator/geolocator.dart';

import '../models/location_model.dart';

/// Exception for location errors
class LocationServiceException implements Exception {
  final String message;

  LocationServiceException(this.message);

  @override
  String toString() => 'LocationServiceException: $message';
}

/// Service for device location and permissions
class LocationService {
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  /// Check current permission status
  Future<LocationPermission> checkPermission() async {
    return Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    return Geolocator.requestPermission();
  }

  /// Get current device position
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
        'Location permission denied. Please enable in settings.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );

    return LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
