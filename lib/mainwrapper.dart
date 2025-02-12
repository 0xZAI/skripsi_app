import 'package:flutter/material.dart';
import 'package:skripsi_app/navigation/beranda_nav.dart';
import 'package:skripsi_app/navigation/rekomendasi_nav.dart';

class mainwrapper extends StatefulWidget {
  const mainwrapper({super.key});

  @override
  State<mainwrapper> createState() => _mainwrapperState();
}

class _mainwrapperState extends State<mainwrapper> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ///BNB
      bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const <NavigationDestination>[
            NavigationDestination(
                selectedIcon: Icon(Icons.home),
                icon: Icon(Icons.home_sharp),
                label: 'Beranda'),
            NavigationDestination(
                selectedIcon: Icon(Icons.lightbulb),
                icon: Icon(Icons.lightbulb_circle),
                label: 'Rekomendasi'),
          ]),

      ///BODY
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: const [
            //halaman beranda
            Beranda(),
            //halaman Rekomendasi
            Rekomendasi()
          ],
        ),
      ),
    );
  }
}
