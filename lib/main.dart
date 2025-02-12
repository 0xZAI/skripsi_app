import 'package:flutter/material.dart';
import 'package:skripsi_app/mainwrapper.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Banner(
        message: 'za1_c0de',
        location: BannerLocation.bottomStart,
        child: mainwrapper(),
      ),
    );
  }
}
