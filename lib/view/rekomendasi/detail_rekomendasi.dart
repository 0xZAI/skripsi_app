import 'package:flutter/material.dart';
import 'package:skripsi_app/db_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class TopsisResultPage extends StatefulWidget {
  final Map<String, double> bobot;

  const TopsisResultPage({super.key, required this.bobot});

  @override
  _TopsisResultPageState createState() => _TopsisResultPageState();
}

class _TopsisResultPageState extends State<TopsisResultPage> {
  List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    _loadTopsisResults();
  }

  // Fungsi untuk memuat hasil TOPSIS
  Future<void> _loadTopsisResults() async {
    final results = await DBHelper.calculateTopsis(widget.bobot);
    setState(() {
      _results = results;
    });
  }

  // Fungsi untuk membuka Google Maps
  void _openGoogleMaps(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open Google Maps.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Perhitungan TOPSIS'),
        backgroundColor: Colors.teal,
      ),
      body: _results.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final result = _results[index];
                return Card(
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result['nama'] ?? 'Tidak Diketahui',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Skor: ${result['skor']?.toStringAsFixed(3) ?? '0.000'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Radius: ${result['radius_asli']?.toStringAsFixed(2) ?? '0.00'} km',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Jarak: ${result['jarak_asli']?.toStringAsFixed(2) ?? '0.00'} km',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Waktu Tempuh: ${result['waktu_tempuh_asli']?.toStringAsFixed(2) ?? '0.00'} menit',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Rating: ${result['rating_asli']?.toStringAsFixed(1) ?? '0.0'} / 5.0',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            final latitude = result['latitude'];
                            final longitude = result['longitude'];

                            if (latitude != null && longitude != null) {
                              _openGoogleMaps(latitude, longitude);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Lokasi tidak tersedia.'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.directions),
                          label: Text(
                            'Lihat di Google Maps',
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor:
                                Colors.white, // Warna latar belakang tombol
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
