import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, double>> getDistanceAndDurationFromORS(
    double originLat, double originLng, double destLat, double destLng) async {
  const String apiKey =
      '5b3ce3597851110001cf6248e9f85fd256f449c085c6875aa9c29a04'; // Ganti dengan API Key Anda
  const String endpoint =
      'https://api.openrouteservice.org/v2/matrix/driving-car';

  try {
    // Siapkan payload untuk API
    final body = jsonEncode({
      "locations": [
        [originLng, originLat], // Lokasi asal (longitude, latitude)
        [destLng, destLat] // Lokasi tujuan (longitude, latitude)
      ],
      "metrics": ["distance", "duration"]
    });

    // Kirim permintaan POST ke API
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': apiKey,
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Ambil jarak (dalam meter) dan waktu tempuh (dalam detik)
      final distance =
          (data['distances'][0][1] as num).toDouble() / 1000; // Convert ke km
      final duration =
          (data['durations'][0][1] as num).toDouble() / 60; // Convert ke menit

      return {
        'distance': distance,
        'duration': duration,
      };
    } else {
      throw Exception('API Error: ${response.body}');
    }
  } catch (e) {
    print('Error saat mengambil data dari OpenRouteService: $e');
    return {
      'distance': 0.0,
      'duration': 0.0,
    };
  }
}
