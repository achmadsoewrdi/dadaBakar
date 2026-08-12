import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/drone_camera_widget.dart';
import '../../../../core/services/tello_service.dart';

class DroneControllerScreen extends StatefulWidget {
  const DroneControllerScreen({super.key});

  @override
  State<DroneControllerScreen> createState() => _DroneControllerScreenState();
}

class _DroneControllerScreenState extends State<DroneControllerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Tello Drone Camera'),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          const AspectRatio(
            aspectRatio: 16 / 9,
            child: DroneCameraWidget(),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.white54,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  ListenableBuilder(
                    listenable: TelloService.instance,
                    builder: (context, _) {
                      final battery = TelloService.instance.battery;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            battery > 20 ? Icons.battery_full : Icons.battery_alert,
                            color: battery > 20 ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Baterai: $battery%',
                            style: TextStyle(
                              color: battery > 20 ? Colors.white : Colors.redAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kamera Tello sedang mengudara.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pastikan HP Anda terhubung ke Wi-Fi Tello. Anda dapat kembali ke layar sebelumnya untuk menjalankan kode Drone Blockly selagi kamera aktif.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await TelloService.instance.sendCommand('takeoff');
                    },
                    icon: const Icon(Icons.flight_takeoff),
                    label: const Text('Uji Coba Terbang (Takeoff)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await TelloService.instance.sendCommand('land');
                    },
                    icon: const Icon(Icons.flight_land),
                    label: const Text('Mendarat Darurat (Land)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
