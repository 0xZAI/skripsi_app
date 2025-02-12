import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BerandaView extends StatelessWidget {
  const BerandaView({super.key});

  Future<Map<String, dynamic>> fetchWeatherData(String city) async {
    const url =
        'https://api.openweathermap.org/data/2.5/weather?lat=-6.7905&lon=106.7239&appid=39c68107a1201cef883a235a7e90ac18';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: <Widget>[
          // Kolom pertama dengan Card untuk cuaca
          FutureBuilder<Map<String, dynamic>>(
            future: fetchWeatherData('Sukabumi'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Error loading weather data'),
                );
              } else {
                final weatherData = snapshot.data!;
                final kelvinTemp = weatherData['main']['temp'];
                final temperature = (kelvinTemp - 273.15).toStringAsFixed(1);
                final description =
                    weatherData['weather'][0]['description'].toString();

                final now = DateTime.now();
                final day = [
                  'Minggu',
                  'Senin',
                  'Selasa',
                  'Rabu',
                  'Kamis',
                  'Jumat',
                  'Sabtu'
                ][now.weekday % 7];
                final date = '${now.day}-${now.month}-${now.year}';

                return Container(
                  margin: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.teal.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kota Sukabumi',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.wb_sunny,
                                  size: 50, color: Colors.orange),
                              const SizedBox(width: 16),
                              Text(
                                '$temperature°C\n$description',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.teal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '$day, $date',
                            style: const TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          ),

          // ElevatedButton
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                buildCustomButton(
                  context,
                  icon: Icons.local_hospital,
                  text: 'Rumah Sakit',
                  route: '/rumah_sakit',
                ),
                const SizedBox(height: 16),
                buildCustomButton(
                  context,
                  icon: Icons.medical_services,
                  text: 'Klinik',
                  route: '/klinik',
                ),
                const SizedBox(height: 16),
                buildCustomButton(
                  context,
                  icon: Icons.local_pharmacy,
                  text: 'Puskesmas',
                  route: '/puskesmas',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCustomButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required String route,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pushNamed(context, route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.teal.shade400],
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(width: 16),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
