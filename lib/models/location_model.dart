class LocationModel {
  final double latitude;
  final double longitude;
  final String? cityName;
  final String? countryCode;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    this.cityName,
    this.countryCode,
  });

  String get displayName {
    if (cityName != null && cityName!.isNotEmpty) {
      return countryCode != null ? '$cityName, $countryCode' : cityName!;
    }
    return '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
  }
}
