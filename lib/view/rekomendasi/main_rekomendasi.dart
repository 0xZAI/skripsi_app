import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:skripsi_app/db_helper.dart';
import 'detail_rekomendasi.dart'; // Import halaman hasil TOPSIS

class RekomendasiView extends StatefulWidget {
  const RekomendasiView({super.key});

  @override
  _RekomendasiViewState createState() => _RekomendasiViewState();
}

class _RekomendasiViewState extends State<RekomendasiView> {
  Position? _currentPosition; // Variabel untuk lokasi pengguna
  bool _isLoading = true; // Status loading untuk seluruh proses
  bool _isCalculating = true; // Status loading perhitungan Haversine
  List<Map<String, dynamic>> _facilities =
      []; // Data fasilitas dari tabel `rekomendasi`

  // Bobot kriteria (hanya untuk UI)
  double _radiusWeight = 0.1;
  double _jarakWeight = 0.1;
  double _waktuTempuhWeight = 0.1;
  double _ratingWeight = 0.1;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Fungsi untuk menginisialisasi data saat halaman dimuat
  Future<void> _initializeData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Langkah 1: Dapatkan lokasi pengguna
      await _getUserLocation();

      // Langkah 2: Pastikan tabel rekomendasi berisi data awal
      final db = await DBHelper.initializeDatabase();
      final recommendations = await db.query('rekomendasi');
      if (recommendations.isEmpty) {
        // Tambahkan data awal ke tabel rekomendasi dari fasilitas
        await db.execute('''
        INSERT INTO rekomendasi (fasilitas_id, radius, jarak, waktu_tempuh)
        SELECT id, 0, 0, 0 FROM fasilitas
      ''');
      }

      // Langkah 3: Hitung Haversine
      if (_currentPosition != null) {
        await _calculateHaversine(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );

        // Langkah 4: Update data jarak dan waktu tempuh dari API
        await DBHelper().updateDistancesAndDurationsFromORS(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      }
    } catch (e) {
      print('Error saat inisialisasi data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk mendapatkan lokasi pengguna
  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan lokasi tidak aktif.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak secara permanen.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      throw Exception('Gagal mendapatkan lokasi: $e');
    }
  }

  // Fungsi untuk menghitung Haversine
  Future<void> _calculateHaversine(double userLat, double userLon) async {
    try {
      // Hitung Haversine dan update ke tabel rekomendasi
      await DBHelper.updateHaversine(userLat, userLon);

      // Ambil data dari tabel rekomendasi
      final db = await DBHelper.initializeDatabase();
      List<Map<String, dynamic>> recommendations = await db.query(
        'rekomendasi',
        orderBy: 'radius ASC', // Urutkan berdasarkan radius terkecil
      );

      // Gabungkan dengan data dari tabel fasilitas untuk menampilkan nama
      List<Map<String, dynamic>> facilities = [];
      for (var recommendation in recommendations) {
        final facility = await db.query(
          'fasilitas',
          where: 'id = ?',
          whereArgs: [recommendation['fasilitas_id']],
          limit: 1,
        );

        if (facility.isNotEmpty) {
          facilities.add({
            'nama': facility[0]['nama'],
            'radius': recommendation['radius'],
          });
        }
      }

      setState(() {
        _facilities = facilities;
        _isCalculating = false;
      });
    } catch (e) {
      print('Error saat menghitung Haversine: $e');
      setState(() {
        _isCalculating = false;
      });
    }
  }

  // Fungsi untuk menyimpan bobot dan berpindah ke halaman hasil TOPSIS
  void _submitAndNavigate() async {
    final bobot = {
      'bobot_radius': _radiusWeight,
      'bobot_jarak': _jarakWeight,
      'bobot_waktu_tempuh': _waktuTempuhWeight,
      'bobot_rating': _ratingWeight,
    };

    // Simpan bobot ke database
    await DBHelper.saveBobotKriteria(bobot);

    // Navigasi ke halaman hasil TOPSIS
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopsisResultPage(bobot: bobot),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekomendasi'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Atur Bobot Kriteria',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    _currentPosition == null
                        ? const Text(
                            'Gagal mendapatkan lokasi pengguna.',
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          )
                        : Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.red, size: 24),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Lokasi Anda: \nLatitude: ${_currentPosition?.latitude}, Longitude: ${_currentPosition?.longitude}',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 16),
                    ..._buildSliders(), // Bagian slider
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitAndNavigate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Submit & Lihat Hasil',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  List<Widget> _buildSliders() {
    return [
      _buildSlider(
        label: 'Radius',
        value: _radiusWeight,
        icon: Icons.radio_button_checked,
        color: Colors.blue,
        onChanged: (value) => setState(() => _radiusWeight = value),
      ),
      _buildSlider(
        label: 'Jarak',
        value: _jarakWeight,
        icon: Icons.directions_car,
        color: Colors.green,
        onChanged: (value) => setState(() => _jarakWeight = value),
      ),
      _buildSlider(
        label: 'Waktu Tempuh',
        value: _waktuTempuhWeight,
        icon: Icons.timer,
        color: Colors.orange,
        onChanged: (value) => setState(() => _waktuTempuhWeight = value),
      ),
      _buildSlider(
        label: 'Rating',
        value: _ratingWeight,
        icon: Icons.star,
        color: Colors.purple,
        onChanged: (value) => setState(() => _ratingWeight = value),
      ),
    ];
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required IconData icon,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              '$label: ${value.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0.1,
          max: 0.5,
          divisions: 4,
          activeColor: color,
          label: value.toStringAsFixed(1),
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
