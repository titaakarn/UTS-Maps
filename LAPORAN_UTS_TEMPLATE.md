# LAPORAN UTS ADVANCED TOPICS IN MOBILE PROGRAMMING

## Smart Logistics Routing

| Identitas | Isi |
|---|---|
| Nama | [Isi nama lengkap] |
| NIM | [Isi NIM] |
| Kelas | [Isi kelas] |
| Repository | [Isi URL GitHub/GitLab] |
| Video demo | [Isi URL YouTube/Google Drive] |

## 1. Deskripsi aplikasi

Smart Logistics Routing adalah aplikasi Flutter untuk menentukan urutan pengiriman ke beberapa lokasi. Pengguna dapat menambahkan titik tujuan melalui form latitude-longitude atau dengan mengetuk peta OpenStreetMap. Aplikasi membandingkan rute sesuai urutan masukan, rute optimal Dijkstra, dan rute heuristik Greedy Nearest Neighbor.

## 2. Teknologi

- Flutter dan Dart
- `flutter_map` dengan OpenStreetMap
- `latlong2` untuk model koordinat
- Formula Haversine untuk jarak geodetik

## 3. Formula Haversine

Jarak antar koordinat dihitung dengan:

`d = 2R asin(sqrt(sin²(Δlat/2) + cos(lat1) cos(lat2) sin²(Δlon/2)))`

dengan `R = 6.371 km`. Perhitungan ini dipakai sebagai bobot antar titik pada graf.

## 4. Algoritma Dijkstra

Dijkstra mencari biaya minimum pada graf dengan bobot tidak negatif melalui proses relaksasi sisi: apabila `d(u) + w(u,v) < d(v)`, maka jarak ke `v` diperbarui. Dalam aplikasi ini, state pencarian berbentuk `(himpunan tujuan yang telah dikunjungi, titik saat ini)`. Pencarian dimulai dari P1 dan selesai saat seluruh tujuan telah masuk state kunjungan. Karena itu, hasilnya adalah urutan rute terbuka dengan jarak minimum dari titik awal yang mengunjungi semua tujuan.

## 5. Algoritma pembanding: Greedy Nearest Neighbor

Greedy Nearest Neighbor selalu memilih titik belum dikunjungi yang memiliki jarak Haversine paling kecil dari posisi saat ini. Kompleksitasnya `O(N²)` sehingga cepat untuk perangkat mobile. Kelemahannya, pilihan lokal terdekat belum tentu menghasilkan rute global paling pendek.

## 6. Pengujian

| Kode | Langkah | Hasil aktual |
|---|---|---|
| TC-01 | Buka aplikasi, geser dan zoom peta. | Peta termuat, indikator koordinat berubah, zoom/re-center bekerja. |
| TC-02 | Tambahkan empat titik atau tekan **Muat 4 titik contoh demo**. Ketuk marker. | Marker dan dialog nama/koordinat muncul. |
| TC-03 | Tekan **Rute Urutan**. | Polyline oranye mengikuti P1 → P2 → P3 → P4 dan jarak tampil. |
| TC-04 | Tekan **Dijkstra**. | Polyline biru dan urutan optimal tampil. |
| TC-05 | Tekan **Greedy NN**. | Polyline ungu, urutan, jarak, dan efisiensi tampil. |

> Sisipkan screenshot untuk setiap TC di bawah tabel ini sebelum mengubah dokumen menjadi PDF.

## 7. Potongan implementasi

Lokasi kode:

- Haversine: `lib/services/distance_calculator.dart`
- Dijkstra: `lib/services/dijkstra_routing.dart`
- Greedy NN: `lib/services/alternative_routing.dart`
- Antarmuka peta dan panel komparasi: `lib/main.dart`

## 8. Naskah video demo (3–5 menit)

1. Perkenalkan aplikasi dan tujuan optimasi rute.
2. Tunjukkan peta, koordinat dinamis, zoom, dan re-center.
3. Masukkan atau muat empat titik; ketuk marker untuk menunjukkan informasi titik.
4. Jalankan rute sekuensial, lalu jelaskan jaraknya.
5. Jalankan Dijkstra dan jelaskan bahwa state graph memilih urutan dengan biaya minimum.
6. Jalankan Greedy Nearest Neighbor, jelaskan pemilihan titik terdekat dan bandingkan hasilnya.
7. Tunjukkan panel penghematan serta simpulkan algoritma yang paling efisien pada data uji.
