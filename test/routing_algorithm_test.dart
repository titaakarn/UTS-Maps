import 'package:flutter_test/flutter_test.dart';
import 'package:uts_maps_titaa/models/location_point.dart';
import 'package:uts_maps_titaa/services/alternative_routing.dart';
import 'package:uts_maps_titaa/services/dijkstra_routing.dart';
import 'package:uts_maps_titaa/services/distance_calculator.dart';

void main() {
  const points = [
    LocationPoint(
      id: 1,
      latitude: -6.2088,
      longitude: 106.8456,
      label: 'Gudang',
    ),
    LocationPoint(id: 2, latitude: -6.1805, longitude: 106.8284, label: 'Hub'),
    LocationPoint(
      id: 3,
      latitude: -6.1754,
      longitude: 106.8650,
      label: 'Outlet',
    ),
    LocationPoint(
      id: 4,
      latitude: -6.2250,
      longitude: 106.8000,
      label: 'Pelanggan',
    ),
  ];

  test('Haversine memberi jarak nol untuk titik yang sama', () {
    expect(DistanceCalculator.haversine(points.first, points.first), 0);
  });

  test(
    'Dijkstra mengunjungi semua titik dan tidak lebih jauh dari input acak',
    () {
      final sequential = DistanceCalculator.routeDistance(points);
      final result = DijkstraRouting.calculate(points);
      expect(result.points.length, points.length);
      expect(result.points.first.id, 1);
      expect(result.distanceKm, lessThanOrEqualTo(sequential));
    },
  );

  test('Greedy selalu menghasilkan rute dari P1 yang memuat semua titik', () {
    final result = AlternativeRouting.nearestNeighbor(points);
    expect(result.points.first.id, 1);
    expect(
      result.points.map((point) => point.id).toSet().length,
      points.length,
    );
  });
}
