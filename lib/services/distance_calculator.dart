import 'dart:math';
import '../models/location_point.dart';

class DistanceCalculator {
  static const _earthRadiusKm = 6371.0;

  static double haversine(LocationPoint a, LocationPoint b) {
    final dLat = _radians(b.latitude - a.latitude);
    final dLon = _radians(b.longitude - a.longitude);
    final lat1 = _radians(a.latitude);
    final lat2 = _radians(b.latitude);
    final value =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    return 2 * _earthRadiusKm * asin(sqrt(value));
  }

  static double routeDistance(List<LocationPoint> points) {
    if (points.length < 2) return 0;
    return List.generate(
      points.length - 1,
      (i) => haversine(points[i], points[i + 1]),
    ).fold(0.0, (sum, distance) => sum + distance);
  }

  static double _radians(double degree) => degree * pi / 180;
}
