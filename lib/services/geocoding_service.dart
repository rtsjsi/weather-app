import 'dart:convert';
import 'dart:io';

import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import '../models/location_model.dart';

/// Search: Open-Meteo (no API key). Reverse: Dart geocoding package.
class GeocodingService {
  final http.Client _client = http.Client();

  /// Search by city/place name using Open-Meteo Geocoding API.
  Future<List<LocationModel>> searchByCityName(String query) async {
    if (query.trim().length < 2) return [];
    try {
      final uri = Uri.parse('${AppConfig.geocodingBaseUrl}/search')
          .replace(queryParameters: {
        'name': query.trim(),
        'count': '5',
        'language': 'en',
        'format': 'json',
      });
      final response = await _client.get(uri).timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Search timed out'),
          );
      if (response.statusCode != 200) return [];
      final data = jsonDecode(response.body) as Map<String, dynamic>?;
      final results = data?['results'] as List<dynamic>? ?? [];
      final list = <LocationModel>[];
      for (final r in results) {
        final map = r as Map<String, dynamic>;
        final name = map['name'] as String? ?? '';
        final country = map['country_code'] as String?;
        final admin1 = map['admin1'] as String?;
        final lat = (map['latitude'] as num?)?.toDouble() ?? 0.0;
        final lon = (map['longitude'] as num?)?.toDouble() ?? 0.0;
        final cityName = [name, if (admin1 != null && admin1.isNotEmpty) admin1]
            .join(', ');
        list.add(LocationModel(
          latitude: lat,
          longitude: lon,
          cityName: cityName.isEmpty ? null : cityName,
          countryCode: country,
        ));
      }
      return list;
    } on SocketException catch (_) {
      return [];
    } on HttpException catch (_) {
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Resolve place name to first result (for search → weather flow).
  Future<LocationModel?> getLocationFromPlace(String placeName) async {
    final list = await searchByCityName(placeName);
    return list.isNotEmpty ? list.first : null;
  }

  /// Reverse geocoding: get display name from coordinates (uses device/platform).
  Future<String> getCityName(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isEmpty) return _coordsFallback(lat, lon);
      final p = placemarks.first;
      final parts = <String>[];
      if (p.locality != null && p.locality!.isNotEmpty) parts.add(p.locality!);
      if (p.administrativeArea != null &&
          p.administrativeArea!.isNotEmpty) {
        parts.add(p.administrativeArea!);
      }
      if (p.country != null && p.country!.isNotEmpty) parts.add(p.country!);
      return parts.isEmpty ? _coordsFallback(lat, lon) : parts.join(', ');
    } catch (_) {
      return _coordsFallback(lat, lon);
    }
  }

  static String _coordsFallback(double lat, double lon) =>
      '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
}
