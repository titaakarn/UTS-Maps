import 'package:flutter_test/flutter_test.dart';
import 'package:uts_maps_titaa/main.dart';

void main() {
  testWidgets('menampilkan halaman Express Route Logistics', (tester) async {
    await tester.pumpWidget(const SmartRoutingApp());
    expect(find.text('Express Route Logistics'), findsOneWidget);
    expect(
      find.textContaining('Rute Terpendek Algoritma Dijkstra'),
      findsOneWidget,
    );
  });
}
