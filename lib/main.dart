import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide DistanceCalculator;

import 'models/location_point.dart';
import 'models/route_result.dart';
import 'services/alternative_routing.dart';
import 'services/dijkstra_routing.dart';
import 'services/distance_calculator.dart';

void main() => runApp(const SmartRoutingApp());

class SmartRoutingApp extends StatelessWidget {
  const SmartRoutingApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Express Route Logistics',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff1553a5)),
      scaffoldBackgroundColor: Colors.white,
    ),
    home: const RoutingPage(),
  );
}

class RoutingPage extends StatefulWidget {
  const RoutingPage({super.key});
  @override
  State<RoutingPage> createState() => _RoutingPageState();
}

class _RoutingPageState extends State<RoutingPage> {
  static const _defaultCenter = LatLng(-6.2088, 106.8456);
  final _mapController = MapController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _labelController = TextEditingController();
  final List<LocationPoint> _points = [];
  LatLng _center = _defaultCenter;
  double _mapZoom = 12;
  RouteResult? _sequential;
  RouteResult? _dijkstra;
  RouteResult? _greedy;
  RouteResult? _visibleRoute;
  Color _routeColor = Colors.blue;
  String _activeName = '';
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadDemoPoints(moveMap: false);
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _addFromForm() {
    final lat = double.tryParse(_latController.text.replaceAll(',', '.'));
    final lng = double.tryParse(_lngController.text.replaceAll(',', '.'));
    final label = _labelController.text.trim();
    if (lat == null ||
        lng == null ||
        label.isEmpty ||
        lat.abs() > 90 ||
        lng.abs() > 180) {
      _notice('Isi latitude, longitude, dan keterangan dengan benar.');
      return;
    }
    _addPoint(lat, lng, label);
  }

  void _addPoint(double lat, double lng, String label) {
    if (_points.length >= 10) {
      return _notice('Maksimal 10 titik sesuai ketentuan UTS.');
    }
    setState(() {
      _points.add(
        LocationPoint(
          id: _points.length + 1,
          latitude: lat,
          longitude: lng,
          label: label,
        ),
      );
      _center = LatLng(lat, lng);
      _clearResults();
      _latController.clear();
      _lngController.clear();
      _labelController.clear();
    });
    _mapController.move(_center, 13);
  }

  Future<void> _addFromMap(LatLng position) async {
    final labelController = TextEditingController();
    final label = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah titik dari peta'),
        content: TextField(
          controller: labelController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Keterangan lokasi',
            hintText: 'Contoh: Toko Pelanggan',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, labelController.text.trim()),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
    if (label != null && label.isNotEmpty) {
      _addPoint(position.latitude, position.longitude, label);
    }
    labelController.dispose();
  }

  void _loadDemoPoints({bool moveMap = true}) {
    const demo = [
      LocationPoint(
        id: 1,
        latitude: -6.2088,
        longitude: 106.8456,
        label: 'Gudang Pusat',
      ),
      LocationPoint(
        id: 2,
        latitude: -6.1450,
        longitude: 106.8260,
        label: 'Pelabuhan Utara',
      ),
      LocationPoint(
        id: 3,
        latitude: -6.1850,
        longitude: 106.8650,
        label: 'Outlet Cempaka',
      ),
      LocationPoint(
        id: 4,
        latitude: -6.2500,
        longitude: 106.7900,
        label: 'Pelanggan Selatan',
      ),
      LocationPoint(
        id: 5,
        latitude: -6.2250,
        longitude: 106.8250,
        label: 'Pelanggan Tebet',
      ),
    ];
    setState(() {
      _points
        ..clear()
        ..addAll(demo);
      _center = demo.first.latLng;
      _clearResults();
    });
    if (moveMap) {
      _mapController.move(_center, 12);
    }
  }

  void _clearResults() {
    _sequential = null;
    _dijkstra = null;
    _greedy = null;
    _visibleRoute = null;
    _activeName = '';
  }

  void _notice(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
  bool get _ready => _points.length >= 3;
  bool _requirePoints() {
    if (_ready) return true;
    _notice('Tambahkan minimal 3 titik terlebih dahulu.');
    return false;
  }

  void _showSequential() {
    if (!_requirePoints()) return;
    setState(() {
      _sequential = RouteResult(
        points: List.of(_points),
        distanceKm: DistanceCalculator.routeDistance(_points),
      );
      _visibleRoute = _sequential;
      _routeColor = Colors.orange.shade800;
      _activeName = 'Rute Sekuensial';
    });
  }

  void _showDijkstra() {
    if (!_requirePoints()) return;
    setState(() {
      _dijkstra = DijkstraRouting.calculate(_points);
      _visibleRoute = _dijkstra;
      _routeColor = Colors.blue.shade600;
      _activeName = 'Rute Terpendek Dijkstra';
    });
  }

  void _showGreedy() {
    if (!_requirePoints()) return;
    setState(() {
      _greedy = AlternativeRouting.nearestNeighbor(_points);
      _visibleRoute = _greedy;
      _routeColor = Colors.green.shade700;
      _activeName = 'Rute Nearest Neighbor';
    });
  }

  void _compareAll() {
    if (!_requirePoints()) return;
    setState(() {
      _sequential = RouteResult(
        points: List.of(_points),
        distanceKm: DistanceCalculator.routeDistance(_points),
      );
      _dijkstra = DijkstraRouting.calculate(_points);
      _greedy = AlternativeRouting.nearestNeighbor(_points);
      _visibleRoute = _dijkstra;
      _routeColor = Colors.blue.shade600;
      _activeName = 'Rute Terpendek Dijkstra';
    });
  }

  void _recenter() => _mapController.move(
    _points.isEmpty ? _defaultCenter : _points.first.latLng,
    12,
  );
  void _zoomBy(double value) =>
      _mapController.move(_center, (_mapZoom + value).clamp(3.0, 18.0));
  String _distance(RouteResult? value) => value == null
      ? 'Belum dihitung'
      : '${value.distanceKm.toStringAsFixed(2)} km';
  double? get _bestDistance {
    final results = [_dijkstra, _greedy].whereType<RouteResult>().toList();
    if (results.isEmpty) return null;
    return results
        .map((item) => item.distanceKm)
        .reduce((a, b) => a < b ? a : b);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      toolbarHeight: 58,
      backgroundColor: const Color(0xff1553a5),
      foregroundColor: Colors.white,
      titleSpacing: 14,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Express Route Logistics',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          Text(
            'UTS Maps Flutter - Route Optimization',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
          ),
        ],
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 14),
          child: Icon(Icons.info_outline),
        ),
      ],
    ),
    body: LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 820;
        final map = _mapPanel();
        final sidebar = _sidePanel();
        return desktop
            ? Row(
                children: [
                  Expanded(flex: 6, child: map),
                  SizedBox(width: 400, child: sidebar),
                ],
              )
            : Column(
                children: [
                  Expanded(flex: 5, child: map),
                  Expanded(flex: 6, child: sidebar),
                ],
              );
      },
    ),
  );

  Widget _mapPanel() => Stack(
    children: [
      FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _center,
          initialZoom: 12,
          onTap: (_, point) => _addFromMap(point),
          onPositionChanged: (position, _) => setState(() {
            _center = position.center;
            _mapZoom = position.zoom;
          }),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.uts_maps_titaa',
          ),
          if (_visibleRoute != null)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _visibleRoute!.points
                      .map((point) => point.latLng)
                      .toList(),
                  strokeWidth: 5,
                  color: _routeColor,
                ),
              ],
            ),
          MarkerLayer(markers: _points.map(_marker).toList()),
          RichAttributionWidget(
            attributions: [TextSourceAttribution('OpenStreetMap contributors')],
          ),
        ],
      ),
      Positioned(
        left: 12,
        right: 12,
        top: 10,
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.gps_fixed, color: Color(0xff2a79d8), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pusat Peta: ${_center.latitude.toStringAsFixed(4)}, ${_center.longitude.toStringAsFixed(4)} (Zoom: ${_mapZoom.toStringAsFixed(1)})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Text(
                  'Ketuk peta: +Titik',
                  style: TextStyle(color: Color(0xff5b519f), fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
      Positioned(
        right: 16,
        bottom: 16,
        child: Column(
          children: [
            _mapButton(Icons.add, 'Perbesar', () => _zoomBy(1)),
            const SizedBox(height: 7),
            _mapButton(Icons.remove, 'Perkecil', () => _zoomBy(-1)),
            const SizedBox(height: 7),
            _mapButton(
              Icons.center_focus_strong,
              'Kembali ke P1',
              _recenter,
              blue: true,
            ),
          ],
        ),
      ),
    ],
  );

  Marker _marker(LocationPoint point) => Marker(
    point: point.latLng,
    width: 70,
    height: 45,
    child: GestureDetector(
      onTap: () => _showPointInfo(point),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: point.id == 1
              ? const Color(0xff258237)
              : const Color(0xffd83333),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              point.id == 1 ? Icons.home : Icons.location_on,
              color: Colors.white,
              size: 16,
            ),
            Text(
              ' P${point.id}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _sidePanel() => DecoratedBox(
    decoration: const BoxDecoration(
      color: Color(0xfffbfbfe),
      border: Border(left: BorderSide(color: Color(0xffdfe1e8))),
    ),
    child: Column(
      children: [
        _tabs(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
            child: _selectedTab == 0
                ? _actionContent()
                : _selectedTab == 1
                ? _inputContent()
                : _listContent(),
          ),
        ),
      ],
    ),
  );

  Widget _tabs() => Row(
    children: [
      _tab(0, Icons.alt_route, 'Aksi Rute (${_visibleRoute == null ? 0 : 1})'),
      _tab(1, Icons.add_location_alt_outlined, 'Input Titik'),
      _tab(2, Icons.format_list_numbered, 'Daftar (${_points.length})'),
    ],
  );

  Widget _tab(int index, IconData icon, String text) => Expanded(
    child: InkWell(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _selectedTab == index
                  ? const Color(0xff334ca0)
                  : const Color(0xffe0e0e0),
              width: _selectedTab == index ? 3 : 1,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: _selectedTab == index
                  ? const Color(0xff334ca0)
                  : Colors.grey,
            ),
            const SizedBox(height: 3),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: _selectedTab == index
                    ? const Color(0xff334ca0)
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _actionContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _routeButton(
        '1. Rute Sesuai Urutan Input (Sekuensial)',
        Icons.linear_scale,
        Colors.orange.shade800,
        _showSequential,
      ),
      const SizedBox(height: 8),
      _routeButton(
        '2. Rute Terpendek Algoritma Dijkstra',
        Icons.hub,
        Colors.blue.shade600,
        _showDijkstra,
      ),
      const SizedBox(height: 8),
      _routeButton(
        '3. Rute Terpendek Nearest Neighbor (Greedy TSP)',
        Icons.navigation,
        Colors.green.shade700,
        _showGreedy,
      ),
      const SizedBox(height: 9),
      OutlinedButton.icon(
        onPressed: _compareAll,
        icon: const Icon(Icons.compare_arrows),
        label: const Text('Bandingkan Semua Ketiga Rute Sekaligus'),
      ),
      const SizedBox(height: 15),
      _analysisPanel(),
    ],
  );

  Widget _routeButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) => SizedBox(
    height: 39,
    child: FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 19),
      label: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    ),
  );

  Widget _analysisPanel() {
    final saving = _sequential != null && _bestDistance != null
        ? _sequential!.distanceKm - _bestDistance!
        : null;
    return Card(
      elevation: 3,
      color: const Color(0xfff7f7fc),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Color(0xff334ca0)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Panel Analisis Rute & Efisiensi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(
                  label: Text(
                    '${_points.length} Titik',
                    style: const TextStyle(fontSize: 10),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if (saving != null)
              Container(
                margin: const EdgeInsets.only(top: 9),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff68a900), Color(0xff008c87)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '⚡ PENGHEMATAN RUTE BERHASIL DICAPAI!\nHemat ${saving.toStringAsFixed(2)} km (${(saving / _sequential!.distanceKm * 100).toStringAsFixed(1)}% lebih efisien)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            if (_visibleRoute != null)
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xffe7f1ff),
                  border: Border.all(color: const Color(0xffa7c8f2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '● Rute Aktif: $_activeName',
                      style: TextStyle(
                        color: _routeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Alur: ${_visibleRoute!.orderLabel}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_visibleRoute!.distanceKm.toStringAsFixed(2)} km',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            const Text(
              'Komparasi Jarak Tempuh:',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
            const SizedBox(height: 5),
            _comparisonRow(
              Colors.orange.shade800,
              '1. Sekuensial (Urutan Input)',
              _distance(_sequential),
            ),
            _comparisonRow(
              Colors.blue.shade600,
              '2. Dijkstra Shortest Path',
              _distance(_dijkstra),
            ),
            _comparisonRow(
              Colors.green.shade700,
              '3. Nearest Neighbor (Heuristik)',
              _distance(_greedy),
            ),
          ],
        ),
      ),
    );
  }

  Widget _comparisonRow(Color color, String title, String value) => Container(
    margin: const EdgeInsets.only(top: 5),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(7),
    ),
    child: Row(
      children: [
        Icon(Icons.circle, color: color, size: 9),
        const SizedBox(width: 7),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 11))),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: value == 'Belum dihitung'
                ? FontWeight.normal
                : FontWeight.bold,
            fontStyle: value == 'Belum dihitung'
                ? FontStyle.italic
                : FontStyle.normal,
          ),
        ),
      ],
    ),
  );

  Widget _inputContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'Tambah Titik Koordinat',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
      ),
      const SizedBox(height: 5),
      const Text(
        'Isi form atau ketuk peta untuk mengambil koordinat.',
        style: TextStyle(fontSize: 12, color: Colors.black54),
      ),
      const SizedBox(height: 14),
      TextField(
        controller: _latController,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        decoration: const InputDecoration(
          labelText: 'Latitude',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: _lngController,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        decoration: const InputDecoration(
          labelText: 'Longitude',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: _labelController,
        decoration: const InputDecoration(
          labelText: 'Keterangan lokasi',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed: _addFromForm,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Titik'),
      ),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: _loadDemoPoints,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Muat 5 titik contoh demo'),
      ),
    ],
  );

  Widget _listContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          const Expanded(
            child: Text(
              'Daftar Titik Koordinat',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          TextButton(
            onPressed: _loadDemoPoints,
            child: const Text('Reset Contoh'),
          ),
        ],
      ),
      ..._points.map(
        (point) => Card(
          margin: const EdgeInsets.only(bottom: 7),
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              backgroundColor: point.id == 1 ? Colors.green : Colors.red,
              child: Text(
                'P${point.id}',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
            title: Text(point.label),
            subtitle: Text(
              '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _removePoint(point),
            ),
          ),
        ),
      ),
    ],
  );

  void _removePoint(LocationPoint target) {
    setState(() {
      _points.remove(target);
      for (var index = 0; index < _points.length; index++) {
        final point = _points[index];
        _points[index] = LocationPoint(
          id: index + 1,
          latitude: point.latitude,
          longitude: point.longitude,
          label: point.label,
        );
      }
      _clearResults();
    });
  }

  Widget _mapButton(
    IconData icon,
    String tooltip,
    VoidCallback callback, {
    bool blue = false,
  }) => Material(
    color: blue ? const Color(0xff315ac0) : Colors.white,
    elevation: 4,
    borderRadius: BorderRadius.circular(11),
    child: IconButton(
      tooltip: tooltip,
      onPressed: callback,
      icon: Icon(icon, color: blue ? Colors.white : Colors.black87),
    ),
  );

  void _showPointInfo(LocationPoint point) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('P${point.id} - ${point.label}'),
      content: Text(
        'Latitude: ${point.latitude.toStringAsFixed(6)}\nLongitude: ${point.longitude.toStringAsFixed(6)}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    ),
  );
}
