import 'package:flutter/material.dart';

class AssignmentsMockupScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const AssignmentsMockupScreen({Key? key, this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Tugas (Mockup)'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (onBack != null) {
              onBack!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: const Center(
        child: Text(
          'Fitur Pemberian & Penilaian Tugas akan hadir di sini!\n\n(Ini adalah layar mockup sementera)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
