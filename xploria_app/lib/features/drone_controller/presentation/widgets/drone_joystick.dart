import 'package:flutter/material.dart';

class DroneJoystick extends StatefulWidget {
  final void Function(double x, double y) onChanged;
  final String title;
  final Color knobColor;

  const DroneJoystick({
    super.key,
    required this.onChanged,
    required this.title,
    this.knobColor = const Color(0xFF00E3A2), // Default to Green
  });

  @override
  State<DroneJoystick> createState() => _DroneJoystickState();
}

class _DroneJoystickState extends State<DroneJoystick> {
  Offset _position = Offset.zero;
  final double _baseSize = 180.0;
  final double _knobSize = 60.0;

  void _updatePosition(Offset localPosition) {
    final center = Offset(_baseSize / 2, _baseSize / 2);
    final maxDistance = (_baseSize - _knobSize) / 2;

    var offsetFromCenter = localPosition - center;
    final distance = offsetFromCenter.distance;

    if (distance > maxDistance) {
      offsetFromCenter = Offset.fromDirection(offsetFromCenter.direction, maxDistance);
    }

    setState(() {
      _position = offsetFromCenter;
    });

    // Normalize to -1.0 to 1.0
    // In Flutter, down is positive y, up is negative y.
    // We want: Y up is positive, Y down is negative.
    // X right is positive, X left is negative.
    final x = offsetFromCenter.dx / maxDistance;
    final y = -offsetFromCenter.dy / maxDistance; // Invert Y

    widget.onChanged(x, y);
  }

  void _onPanStart(DragStartDetails details) {
    _updatePosition(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _updatePosition(details.localPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _position = Offset.zero;
    });
    widget.onChanged(0, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Container(
            width: _baseSize,
            height: _baseSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.03),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Crosshairs
                CustomPaint(
                  size: Size(_baseSize, _baseSize),
                  painter: _CrosshairPainter(),
                ),
                // Knob
                Transform.translate(
                  offset: _position,
                  child: Container(
                    width: _knobSize,
                    height: _knobSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [widget.knobColor, widget.knobColor.withValues(alpha: 0.6)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.knobColor.withValues(alpha: 0.3),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white54, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw concentric circles
    canvas.drawCircle(center, size.width / 2 * 0.5, paint);
    canvas.drawCircle(center, size.width / 2 * 0.9, paint);
    
    // Draw lines
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width / 2, size.height);
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width, size.height / 2);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
