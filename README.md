# Smart Logistics Routing

Proyek UTS **Advanced Topics in Mobile Programming** untuk optimasi rute pengiriman multi-destinasi menggunakan Flutter dan OpenStreetMap.

## Fitur

- Peta interaktif OpenStreetMap: geser, zoom, re-center, serta indikator koordinat tengah peta.
- Tambah 3–10 titik melalui form atau ketukan peta; setiap titik memiliki latitude, longitude, dan keterangan.
- Marker P1 (hijau) dan tujuan (merah); marker dapat diketuk untuk melihat detail koordinat.
- Rute sekuensial sesuai urutan input, Dijkstra, dan Greedy Nearest Neighbor dengan polyline berbeda warna.
- Panel komparasi jarak, urutan kunjungan, penghematan, dan persentase efisiensi.
- Tombol **Muat 4 titik contoh demo** untuk kebutuhan rekaman video.

## Menjalankan

```bash
flutter pub get
flutter run
```

## Teori singkat

Jarak setiap sisi dihitung dengan formula Haversine dan radius bumi 6.371 km. Dijkstra diimplementasikan pada state graph `(tujuan yang sudah dikunjungi, posisi saat ini)`, sehingga menghasilkan rute terbuka minimum dari P1 yang mengunjungi seluruh tujuan. Karena batas aplikasi adalah 10 titik, jumlah state masih layak untuk perangkat mobile. Pembandingnya adalah Greedy Nearest Neighbor yang memilih titik belum dikunjungi terdekat pada setiap langkah (O(N²)); cepat tetapi tidak selalu optimal secara global.
