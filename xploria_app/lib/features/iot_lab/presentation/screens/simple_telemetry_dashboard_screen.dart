import 'package:flutter/material.dart';
import '../../../../core/services/device_connection_service.dart';

class SimpleTelemetryDashboardScreen extends StatefulWidget {
  const SimpleTelemetryDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SimpleTelemetryDashboardScreen> createState() => _SimpleTelemetryDashboardScreenState();
}

class _SimpleTelemetryDashboardScreenState extends State<SimpleTelemetryDashboardScreen> {
  // Map untuk menyimpan data terbaru dari setiap pin sensor
  final Map<String, dynamic> _liveData = {};

  @override
  void initState() {
    super.initState();
    // Berlangganan langsung ke sistem koneksi Xploria yang sudah ada!
    DeviceConnectionService.instance.telemetryStream.listen((data) {
      if (mounted) {
        setState(() {
          // Format dari server kita: {"type": "telemetry", "pin": "V1", "value": 30.5}
          final pin = data['pin'].toString();
          final value = data['value'];
          _liveData[pin] = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Live Dashboard'),
        backgroundColor: Colors.indigo,
      ),
      body: _liveData.isEmpty
          ? const Center(
              child: Text(
                'Belum Ada Data Sensor (Telemetri)\nSilakan hubungkan alat dan jalankan script.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _liveData.length,
              itemBuilder: (context, index) {
                final pin = _liveData.keys.elementAt(index);
                final value = _liveData[pin];

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'PIN: $pin',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$value',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
