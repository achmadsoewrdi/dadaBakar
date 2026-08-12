import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../widgets/drone_camera_widget.dart';
import '../widgets/drone_joystick.dart';
import '../../../../core/services/tello_service.dart';

class DroneControllerScreen extends StatefulWidget {
  const DroneControllerScreen({super.key});

  @override
  State<DroneControllerScreen> createState() => _DroneControllerScreenState();
}

class _DroneControllerScreenState extends State<DroneControllerScreen> {
  Timer? _rcTimer;
  int _roll = 0; // -100 to 100
  int _pitch = 0;
  int _throttle = 0;
  int _yaw = 0;
  bool _isFlying = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    // Loop timer untuk mengirim perintah RC (100ms / 10Hz)
    _rcTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (TelloService.instance.isConnected) {
        TelloService.instance.setRC(_roll, _pitch, _throttle, _yaw);
      }
    });
  }

  @override
  void dispose() {
    _rcTimer?.cancel();
    // Kembalikan orientasi ke portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Stop drone movement when exiting
    if (TelloService.instance.isConnected) {
      TelloService.instance.setRC(0, 0, 0, 0);
    }
    super.dispose();
  }

  void _onLeftJoystickChanged(double x, double y) {
    // Left joystick: Yaw (X) & Throttle (Y)
    setState(() {
      _yaw = (x * 100).round();
      _throttle = (y * 100).round();
    });
  }

  void _onRightJoystickChanged(double x, double y) {
    // Right joystick: Roll (X) & Pitch (Y)
    setState(() {
      _roll = (x * 100).round();
      _pitch = (y * 100).round();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // 1. FPV Camera Background (Disembunyikan sementara sesuai permintaan)
          /*
          const Positioned.fill(
            child: DroneCameraWidget(),
          ),
          */
          
          // 2. Dark Overlay & Grid pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0A1128).withValues(alpha: 0.9),
                // Kita tidak bisa menggunakan NetworkImage di sini karena HP terhubung
                // ke Wi-Fi Drone yang tidak memiliki koneksi internet.
              ),
              child: CustomPaint(
                painter: _GridPainter(),
              ),
            ),
          ),

          // 3. UI Layer
          SafeArea(
            child: Column(
              children: [
                // TOP BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // Back Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Title
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Drone X1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('FPV Live Feed', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      // Action Buttons
                      _buildTopButton(Icons.camera_alt, 'Foto'),
                      const SizedBox(width: 8),
                      _buildTopButton(Icons.fiber_manual_record, 'Rekam'),
                      const SizedBox(width: 8),
                      _buildTopButton(Icons.flip_camera_android, 'Flip'),
                      const SizedBox(width: 8),
                      _buildTopButton(Icons.home, 'RTH'),
                      const Spacer(),
                      // Status & Takeoff
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                        child: const Row(
                          children: [Icon(Icons.signal_cellular_alt, color: Colors.greenAccent, size: 16), SizedBox(width: 4), Text('Kuat', style: TextStyle(color: Colors.white))],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ListenableBuilder(
                        listenable: TelloService.instance,
                        builder: (context, _) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                            child: Row(
                              children: [const Icon(Icons.battery_full, color: Colors.white, size: 16), const SizedBox(width: 4), Text('${TelloService.instance.battery}%', style: const TextStyle(color: Colors.white))],
                            ),
                          );
                        }
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFlying ? const Color(0xFFFF4B4B) : const Color(0xFF00E3A2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onPressed: () {
                          if (_isFlying) {
                            TelloService.instance.sendCommand('land');
                            setState(() => _isFlying = false);
                          } else {
                            TelloService.instance.sendCommand('takeoff');
                            setState(() => _isFlying = true);
                          }
                        },
                        icon: Icon(_isFlying ? Icons.flight_land : Icons.flight_takeoff, size: 20),
                        label: Text(_isFlying ? 'LANDING' : 'TAKEOFF', style: const TextStyle(fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
                
                // CENTER CONTENT & CONTROLS
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Joystick (Throttle & Yaw)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: DroneJoystick(
                            title: 'Throttle & Yaw',
                            knobColor: const Color(0xFF00E3A2),
                            onChanged: _onLeftJoystickChanged,
                          ),
                        ),
                        
                        // Artificial Horizon
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.navigation, color: Colors.white, size: 14),
                                    SizedBox(width: 8),
                                    Text('038°', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Horizon visualizer
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 2),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 5),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Container(color: const Color(0xFF7B61FF)), // Sky/Purple
                                      ),
                                      Expanded(
                                        child: Container(
                                          color: const Color(0xFF00E3A2), // Ground/Green
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            alignment: Alignment.topCenter,
                                            children: [
                                              // Airplane crosshair
                                              Positioned(
                                                top: -1,
                                                child: Container(width: 60, height: 2, color: Colors.white),
                                              ),
                                              Positioned(
                                                top: -6,
                                                child: Container(width: 12, height: 12, color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                ),
                                child: const Text(
                                  'SIAP LEPAS LANDAS',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Right Joystick (Pitch & Roll)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: DroneJoystick(
                            title: 'Pitch & Roll',
                            knobColor: const Color(0xFF9D74FF),
                            onChanged: _onRightJoystickChanged,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopButton(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const double step = 40.0;

    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
