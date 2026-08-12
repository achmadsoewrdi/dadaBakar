import 'package:flutter/material.dart';
import 'device_connection_screen.dart'; // We can keep using this for now as one of the tabs if we want, or implement custom
import '../../../device_profile/presentation/pages/device_profile_page.dart';

class UnifiedDeviceScreen extends StatelessWidget {
  const UnifiedDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFF005CFF),
          elevation: 0,
          title: const Text(
            '🔌 Perangkat Saya',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Tersambung'),
              Tab(text: 'Tersimpan'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_link_rounded, color: Colors.white),
              onPressed: () {
                // Show Add Device Modal (this could be navigated to connection screen or modal)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tambah Device Baru...')),
                );
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            DeviceConnectionScreen(showBackButton: false),
            DeviceProfilePage(),
          ],
        ),
      ),
    );
  }
}
