import 'package:flutter/material.dart';
import 'package:skripsi_app/view/beranda/klinik_beranda_view.dart';
import 'package:skripsi_app/view/beranda/rs_beranda_view.dart';
import 'package:skripsi_app/view/beranda/main_beranda_view.dart';
import 'package:skripsi_app/view/beranda/puskesmas_beranda_view.dart';

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  GlobalKey<NavigatorState> berandaNavigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
        key: berandaNavigatorKey,
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              settings: settings,
              builder: (BuildContext context) {
                if (settings.name == '/rumah_sakit') {
                  return const DetailBerandaView();
                }
                if (settings.name == '/puskesmas') {
                  return const PuskesmasBerandaView();
                }
                if (settings.name == '/klinik') {
                  return const KlinikBerandaView();
                }

                ///BERANDA NYA DISINI GES
                return const BerandaView();
              });
        });
  }
}
