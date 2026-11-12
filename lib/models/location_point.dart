import 'package:latlong2/latlong.dart';

class LocationPoint {
  const LocationPoint({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.label,
  });

  final int id;
  final double latitude;
  final double longitude;
  final String label;

  LatLng get latLng => LatLng(latitude, longitude);
}
