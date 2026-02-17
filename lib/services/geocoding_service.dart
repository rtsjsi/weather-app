import 'package:geocoding/geocoding.dart';

import '../models/location_model.dart';

/// Service for geocoding (city search) and reverse geocoding
class GeocodingService {
  /// Search for locations by city/place name. Returns up to 5 results.
  Future<List<LocationModel>> searchByCityName(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final locations = await locationFromAddress(query);
      final results = <LocationModel>[];

      for (final loc in locations.take(5)) {
        final name = await getCityName(loc.latitude, loc.longitude);
        results.add(LocationModel(
          latitude: loc.latitude,
          longitude: loc.longitude,
          cityName: name,
          countryCode: null,
        ));
      }
      return results;
    } catch (_) {
      return [];
    }
  }

  /// Get city name from coordinates (reverse geocoding)
  Future<String> getCityName(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isEmpty) return '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';

      final p = placemarks.first;
      final parts = <String>[];
      if (p.locality != null && p.locality!.isNotEmpty) parts.add(p.locality!);
      if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) {
        parts.add(p.administrativeArea!);
      }
      if (p.country != null && p.country!.isNotEmpty) parts.add(p.country!);

      return parts.isEmpty ? '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}' : parts.join(', ');
    } catch (_) {
      return '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
    }
  }

  /// Get location from place name (returns first result)
  Future<LocationModel?> getLocationFromPlace(String placeName) async {
    try {
      final locations = await locationFromAddress(placeName);
      if (locations.isEmpty) return null;

      final loc = locations.first;
      final name = await getCityName(loc.latitude, loc.longitude);
      return LocationModel(
        latitude: loc.latitude,
        longitude: loc.longitude,
        cityName: name,
        countryCode: null,
      );
    } catch (_) {
      return null;
    }
  }
}
