import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../../core/services/tello_service.dart';

class DroneCameraWidget extends StatefulWidget {
  const DroneCameraWidget({super.key});

  @override
  State<DroneCameraWidget> createState() => _DroneCameraWidgetState();
}

class _DroneCameraWidgetState extends State<DroneCameraWidget> {
  late final Player player;
  late final VideoController controller;
  bool _isStreamRequested = false;
  bool _isStreamReady = false;

  @override
  void initState() {
    super.initState();
    // Initialize MediaKit player with low latency configuration
    player = Player(configuration: const PlayerConfiguration(
      bufferSize: 1024 * 1024, // 1MB buffer to prevent large latency build-up
    ));
    controller = VideoController(player);
  }

  Future<void> _startDroneStream() async {
    setState(() => _isStreamRequested = true);
    final success = await TelloService.instance.startVideoStream();
    
    if (success) {
      if (mounted) {
        setState(() => _isStreamReady = true);
        // Buka stream UDP dari drone (media_kit sangat stabil untuk ini)
        await player.open(Media('udp://0.0.0.0:11111'), play: true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim perintah streamon ke drone')),
        );
        setState(() => _isStreamRequested = false);
      }
    }
  }

  @override
  void dispose() {
    TelloService.instance.stopVideoStream();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Jika stream sudah di-request dan OK, tampilkan Video Widget
          if (_isStreamReady)
            Video(
              controller: controller,
              controls: NoVideoControls, // Matikan kontrol bawaan (play/pause slider) karena ini live stream
              fit: BoxFit.contain,
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          
          // Overlay to ask user to start stream
          if (!_isStreamRequested)
            Container(
              color: Colors.black54,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _startDroneStream,
                  icon: const Icon(Icons.videocam),
                  label: const Text('Mulai Kamera Tello (MediaKit)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
