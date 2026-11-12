import '../models/location_point.dart';
import '../models/route_result.dart';
import 'distance_calculator.dart';

class AlternativeRouting {
  /// Greedy Nearest Neighbor: repeatedly visit the closest unvisited point.
  static RouteResult nearestNeighbor(List<LocationPoint> points) {
    if (points.length < 2) {
      return RouteResult(points: List.of(points), distanceKm: 0);
    }
    final remaining = points.skip(1).toList();
    final route = <LocationPoint>[points.first];
    var total = 0.0;
    while (remaining.isNotEmpty) {
      remaining.sort(
        (a, b) => DistanceCalculator.haversine(
          route.last,
          a,
        ).compareTo(DistanceCalculator.haversine(route.last, b)),
      );
      final next = remaining.removeAt(0);
      total += DistanceCalculator.haversine(route.last, next);
      route.add(next);
    }
    return RouteResult(points: route, distanceKm: total);
  }
}
