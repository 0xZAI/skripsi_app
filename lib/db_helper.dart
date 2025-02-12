import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skripsi_app/api_call.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  // Fungsi untuk inisialisasi database
  static Future<Database> initializeDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'skripsi.db');
    print('Database path: $path');

    final exists = await File(path).exists();
    if (!exists) {
      ByteData data = await rootBundle.load('assets/database/skripsi.db');
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
      print("Database berhasil disalin ke lokasi aplikasi.");
    } else {
      print("Database sudah ada di lokasi aplikasi.");
    }

    return openDatabase(path);
  }

  // Fungsi untuk mengambil data dari tabel fasilita
  static Future<List<Map<String, dynamic>>> fetchRs() async {
    final db = await initializeDatabase();
    return await db.query(
      'fasilitas',
      where: 'tipe = ?',
      whereArgs: ['rumah_sakit'],
    );
  }

  // Fungsi mengambil puskesmas
  static Future<List<Map<String, dynamic>>> fetchPs() async {
    final db = await initializeDatabase();
    return await db.query(
      'fasilitas',
      where: 'tipe = ?',
      whereArgs: ['puskesmas'],
    );
  }

  // Fungsi mengambil klinik
  static Future<List<Map<String, dynamic>>> fetchKl() async {
    final db = await initializeDatabase();
    return await db.query(
      'fasilitas',
      where: 'tipe = ?',
      whereArgs: ['klinik'],
    );
  }

  // Fungsi untuk menghitung Haversine
  double calculateHaversine(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Radius bumi dalam kilometer
    final dLat = (lat2 - lat1) * (pi / 180);
    final dLon = (lon2 - lon1) * (pi / 180);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Hasil dalam kilometer
  }

  // Fungsi untuk menghitung Haversine dan update tabel `rekomendasi`
  static Future<void> updateHaversine(double userLat, double userLon) async {
    final db = await initializeDatabase();
    final facilities = await db.query('fasilitas');

    for (var facility in facilities) {
      double lat = ((facility['latitude'] ?? 0.0) as num).toDouble();
      double lon = ((facility['longitude'] ?? 0.0) as num).toDouble();

      double radius = DBHelper().calculateHaversine(userLat, userLon, lat, lon);

      await db.update(
        'rekomendasi',
        {'radius': radius},
        where: 'fasilitas_id = ?',
        whereArgs: [facility['id']],
      );

      print(
          'Radius diperbarui untuk fasilitas_id ${facility['id']} menjadi $radius');
    }

    print("Radius diperbarui di tabel rekomendasi.");
    await printTableData('rekomendasi');
  }

  // Fungsi untuk mengupdate data dari API OpenRouteService
  Future<void> updateDistancesAndDurationsFromORS(
      double userLat, double userLng) async {
    final db = await initializeDatabase();

    // Ambil 10 fasilitas terdekat berdasarkan radius
    final topFacilities = await db.query(
      'rekomendasi',
      orderBy: 'radius ASC',
      limit: 10,
    );

    for (var facility in topFacilities) {
      int fasilitasId = facility['fasilitas_id'] as int;

      // Ambil data latitude dan longitude dari tabel `fasilitas`
      final facilityData = await db.query(
        'fasilitas',
        where: 'id = ?',
        whereArgs: [fasilitasId],
        limit: 1,
      );

      if (facilityData.isNotEmpty) {
        final destLat =
            ((facilityData[0]['latitude'] ?? 0.0) as num).toDouble();
        final destLng =
            ((facilityData[0]['longitude'] ?? 0.0) as num).toDouble();

        try {
          // Panggil API OpenRouteService
          final apiData = await getDistanceAndDurationFromORS(
            userLat,
            userLng,
            destLat,
            destLng,
          );

          // Update tabel `rekomendasi` dengan data jarak dan waktu tempuh
          await db.update(
            'rekomendasi',
            {
              'jarak': apiData['distance'],
              'waktu_tempuh': apiData['duration'],
            },
            where: 'fasilitas_id = ?',
            whereArgs: [fasilitasId],
          );

          print('Berhasil memperbarui fasilitas ID $fasilitasId: '
              'Jarak: ${apiData['distance']} km, Waktu Tempuh: ${apiData['duration']} menit.');
        } catch (e) {
          print('Error saat memproses fasilitas ID $fasilitasId: $e');
        }
      }
    }

    print(
        "Proses pembaruan jarak dan waktu tempuh selesai untuk 10 fasilitas teratas.");
  }

  // Fungsi untuk mengambil bobot kriteria
  static Future<Map<String, double>> getBobotKriteria() async {
    final db = await initializeDatabase();
    final result = await db.query('bobot_kriteria', limit: 1);

    if (result.isNotEmpty) {
      return {
        'bobot_radius': result[0]['bobot_radius'] as double,
        'bobot_jarak': result[0]['bobot_jarak'] as double,
        'bobot_waktu_tempuh': result[0]['bobot_waktu_tempuh'] as double,
        'bobot_rating': result[0]['bobot_rating'] as double,
      };
    }

    return {
      'bobot_radius': 0.1,
      'bobot_jarak': 0.1,
      'bobot_waktu_tempuh': 0.1,
      'bobot_rating': 0.1,
    };
  }

  // Fungsi untuk menyimpan bobot kriteria
  static Future<void> saveBobotKriteria(Map<String, double> bobot) async {
    final db = await initializeDatabase();
    await db.update(
      'bobot_kriteria',
      {
        'bobot_radius': bobot['bobot_radius'],
        'bobot_jarak': bobot['bobot_jarak'],
        'bobot_waktu_tempuh': bobot['bobot_waktu_tempuh'],
        'bobot_rating': bobot['bobot_rating'],
      },
    );

    print("Bobot kriteria berhasil diperbarui.");
    await printTableData('bobot_kriteria');
  }

  // Fungsi untuk mencetak isi tabel
  static Future<void> printTableData(String tableName) async {
    final db = await initializeDatabase();

    try {
      final data = await db.query(tableName);
      if (data.isEmpty) {
        print('Tabel $tableName kosong.');
      } else {
        print('Isi tabel $tableName:');
        for (var row in data) {
          print(row);
        }
      }
    } catch (e) {
      print('Gagal membaca tabel $tableName: $e');
    }
  }

  // Fungsi untuk perhitungan TOPSIS
  static Future<List<Map<String, dynamic>>> calculateTopsis(
      Map<String, double> bobot) async {
    final db = await initializeDatabase();
    print('Bobot yang diterima untuk perhitungan TOPSIS: $bobot');
    // Ambil semua data dari tabel rekomendasi
    final data = await db.rawQuery('''
  SELECT r.*, f.nama, f.rating, f.latitude AS fasilitas_latitude, f.longitude AS fasilitas_longitude
  FROM rekomendasi r
  JOIN fasilitas f ON r.fasilitas_id = f.id
  ORDER BY r.radius ASC
  LIMIT 10
  ''');

    print('Data yang diambil untuk TOPSIS:');
    for (var row in data) {
      print(row);
    }

    // Normalisasi Matriks Keputusan
    double totalRadius = 0;
    double totalJarak = 0;
    double totalWaktuTempuh = 0;
    double totalRating = 0;

    for (var row in data) {
      totalRadius +=
          (row['radius'] as double? ?? 0) * (row['radius'] as double? ?? 0);
      totalJarak +=
          (row['jarak'] as double? ?? 0) * (row['jarak'] as double? ?? 0);
      totalWaktuTempuh += (row['waktu_tempuh'] as double? ?? 0) *
          (row['waktu_tempuh'] as double? ?? 0);
      totalRating +=
          (row['rating'] as double? ?? 0) * (row['rating'] as double? ?? 0);
    }

    totalRadius = sqrt(totalRadius);
    totalJarak = sqrt(totalJarak);
    totalWaktuTempuh = sqrt(totalWaktuTempuh);
    totalRating = sqrt(totalRating);

    // Matriks Keputusan Ternormalisasi dan Terbobot
    final List<Map<String, dynamic>> normalizedData = [];
    for (var row in data) {
      final normalRadius = (row['radius'] as double? ?? 0) / totalRadius;
      final normalJarak = (row['jarak'] as double? ?? 0) / totalJarak;
      final normalWaktuTempuh =
          (row['waktu_tempuh'] as double? ?? 0) / totalWaktuTempuh;
      final normalRating = (row['rating'] as double? ?? 0) / totalRating;

      normalizedData.add({
        'nama': row['nama'],
        'radius_asli': row['radius'], // Nilai asli
        'jarak_asli': row['jarak'], // Nilai asli
        'waktu_tempuh_asli': row['waktu_tempuh'], // Nilai asli
        'rating_asli': row['rating'], // Nilai asli
        'radius': normalRadius * bobot['bobot_radius']!, // Nilai ternormalisasi
        'jarak': normalJarak * bobot['bobot_jarak']!,
        'waktu_tempuh': normalWaktuTempuh * bobot['bobot_waktu_tempuh']!,
        'rating': normalRating * bobot['bobot_rating']!,
        'fasilitas_latitude': row['fasilitas_latitude'],
        'fasilitas_longitude': row['fasilitas_longitude'],
      });
    }

    // Solusi Ideal Positif (A⁺) dan Negatif (A⁻)
    final idealPositive = {
      'radius':
          normalizedData.map((e) => e['radius'] as double).reduce(min), // Cost
      'jarak':
          normalizedData.map((e) => e['jarak'] as double).reduce(min), // Cost
      'waktu_tempuh': normalizedData
          .map((e) => e['waktu_tempuh'] as double)
          .reduce(min), // Cost
      'rating': normalizedData
          .map((e) => e['rating'] as double)
          .reduce(max), // Benefit
    };

    final idealNegative = {
      'radius':
          normalizedData.map((e) => e['radius'] as double).reduce(max), // Cost
      'jarak':
          normalizedData.map((e) => e['jarak'] as double).reduce(max), // Cost
      'waktu_tempuh': normalizedData
          .map((e) => e['waktu_tempuh'] as double)
          .reduce(max), // Cost
      'rating': normalizedData
          .map((e) => e['rating'] as double)
          .reduce(min), // Benefit
    };

    print('Solusi Ideal Positif (A⁺): $idealPositive');
    print('Solusi Ideal Negatif (A⁻): $idealNegative');

    // Menghitung Jarak ke Solusi Ideal Positif (D⁺) dan Negatif (D⁻)
    final List<Map<String, dynamic>> results = [];
    for (var row in normalizedData) {
      final dPositive = sqrt(
        pow(row['radius'] - idealPositive['radius'], 2) +
            pow(row['jarak'] - idealPositive['jarak'], 2) +
            pow(row['waktu_tempuh'] - idealPositive['waktu_tempuh'], 2) +
            pow(row['rating'] - idealPositive['rating'], 2),
      );

      final dNegative = sqrt(
        pow(row['radius'] - idealNegative['radius'], 2) +
            pow(row['jarak'] - idealNegative['jarak'], 2) +
            pow(row['waktu_tempuh'] - idealNegative['waktu_tempuh'], 2) +
            pow(row['rating'] - idealNegative['rating'], 2),
      );

      // Menghitung Nilai Preferensi
      final preferensi = dNegative / (dPositive + dNegative);

      results.add({
        'nama': row['nama'],
        'skor': preferensi,
        'radius_asli': row['radius_asli'], // Nilai asli
        'jarak_asli': row['jarak_asli'], // Nilai asli
        'waktu_tempuh_asli': row['waktu_tempuh_asli'], // Nilai asli
        'rating_asli': row['rating_asli'], // Nilai asli
        'latitude': row['fasilitas_latitude'],
        'longitude': row['fasilitas_longitude'],
      });
    }

    // Urutkan Berdasarkan Nilai Preferensi (Skor)
    results.sort((a, b) => b['skor'].compareTo(a['skor']));

    print('Hasil TOPSIS:');
    for (var result in results) {
      print('Nama: ${result['nama']}, Skor: ${result['skor']}, '
          'Radius: ${result['radius_asli']}, Jarak: ${result['jarak_asli']}, '
          'Waktu Tempuh: ${result['waktu_tempuh_asli']}, Rating: ${result['rating_asli']}');
    }

    return results;
  }
}
