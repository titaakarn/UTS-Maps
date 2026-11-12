import 'models/location_point.dart';
import 'services/dijkstra_routing.dart';
import 'services/alternative_routing.dart';

void main() {
  // Koordinat asli dari aplikasi Express Route Logistics
  final points = [
    const LocationPoint(
      id: 1,
      latitude: -6.20880,
      longitude: 106.84560,
      label: 'Gudang Pusat',
    ),
    const LocationPoint(
      id: 2,
      latitude: -6.14500,
      longitude: 106.82600,
      label: 'Pelabuhan Utara',
    ),
    const LocationPoint(
      id: 3,
      latitude: -6.18500,
      longitude: 106.86500,
      label: 'Outlet Cempaka',
    ),
    const LocationPoint(
      id: 4,
      latitude: -6.25000,
      longitude: 106.79000,
      label: 'Pelanggan Selatan',
    ),
    const LocationPoint(
      id: 5,
      latitude: -6.22500,
      longitude: 106.82500,
      label: 'Pelanggan Tebet',
    ),
  ];

  // Menghitung rute Dijkstra
  final dijkstra = DijkstraRouting.calculate(points);

  // Menghitung rute Nearest Neighbor
  final greedy = AlternativeRouting.nearestNeighbor(points);

  // Menampilkan hasil
  print('================================');
  print('     HASIL TEST ROUTING');
  print('================================');

  print('\n--- DIJKSTRA ---');
  print('Jarak: ${dijkstra.distanceKm.toStringAsFixed(2)} km');
  print('Urutan: ${dijkstra.points.map((p) => p.label).join(' -> ')}');

  print('\n--- NEAREST NEIGHBOR ---');
  print('Jarak: ${greedy.distanceKm.toStringAsFixed(2)} km');
  print('Urutan: ${greedy.points.map((p) => p.label).join(' -> ')}');

  // Membandingkan jarak kedua algoritma
  print('\n--- PERBANDINGAN ---');

  final difference = greedy.distanceKm - dijkstra.distanceKm;

  print('Selisih jarak: ${difference.toStringAsFixed(2)} km');

  if (difference > 0.000001) {
    print('Dijkstra menghasilkan rute lebih pendek.');
  } else if (difference < -0.000001) {
    print('Nearest Neighbor menghasilkan rute lebih pendek.');
  } else {
    print('Kedua algoritma menghasilkan jarak yang sama.');
  }

  print('================================');
}
