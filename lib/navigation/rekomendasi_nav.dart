import 'package:flutter/material.dart';
import 'package:skripsi_app/view/rekomendasi/main_rekomendasi.dart';

class Rekomendasi extends StatefulWidget {
  const Rekomendasi({super.key});

  @override
  State<Rekomendasi> createState() => _RekomendasiState();
}

class _RekomendasiState extends State<Rekomendasi> {
  GlobalKey<NavigatorState> rekomendasiNavigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
        key: rekomendasiNavigatorKey,
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              settings: settings,
              builder: (BuildContext context) {
                if (settings.name == '/r') {
                  return Container();
                }

                ///BERANDA NYA DISINI GES
                return const RekomendasiView();
              });
        });
  }
}
