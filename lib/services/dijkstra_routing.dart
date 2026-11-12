import '../models/location_point.dart';
import '../models/route_result.dart';
import 'distance_calculator.dart';

/// Dijkstra on a state graph: a state is (visited destinations, current node).
/// This finds the shortest open route that starts at P1 and visits every point.
class DijkstraRouting {
  static RouteResult calculate(List<LocationPoint> points) {
    if (points.length < 2) {
      return RouteResult(points: List.of(points), distanceKm: 0);
    }
    final destinationCount = points.length - 1;
    final fullMask = (1 << destinationCount) - 1;
    final queue = <_State>[
      _State(mask: 0, current: 0, cost: 0, route: [0]),
    ];
    final best = <String, double>{'0-0': 0};

    while (queue.isNotEmpty) {
      queue.sort((a, b) => a.cost.compareTo(b.cost));
      final state = queue.removeAt(0);
      if (state.mask == fullMask) {
        return RouteResult(
          points: state.route.map((i) => points[i]).toList(),
          distanceKm: state.cost,
        );
      }
      for (var next = 1; next < points.length; next++) {
        final bit = 1 << (next - 1);
        if ((state.mask & bit) != 0) continue;
        final newMask = state.mask | bit;
        final newCost =
            state.cost +
            DistanceCalculator.haversine(points[state.current], points[next]);
        final key = '$newMask-$next';
        if (newCost < (best[key] ?? double.infinity)) {
          best[key] = newCost;
          queue.add(
            _State(
              mask: newMask,
              current: next,
              cost: newCost,
              route: [...state.route, next],
            ),
          );
        }
      }
    }
    return RouteResult(points: List.of(points), distanceKm: 0);
  }
}

class _State {
  const _State({
    required this.mask,
    required this.current,
    required this.cost,
    required this.route,
  });
  final int mask;
  final int current;
  final double cost;
  final List<int> route;
}
