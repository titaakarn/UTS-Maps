import 'location_point.dart';

class RouteResult {
  const RouteResult({required this.points, required this.distanceKm});

  final List<LocationPoint> points;
  final double distanceKm;

  String get orderLabel => points.map((point) => 'P${point.id}').join(' → ');
}
