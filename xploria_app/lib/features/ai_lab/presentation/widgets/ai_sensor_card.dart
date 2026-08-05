import 'package:flutter/material.dart';

class AiSensorCard extends StatelessWidget {
  final String title;
  final String value;
  final Widget icon;
  final Color graphColor;
  final List<double> dataPoints;

  const AiSensorCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.graphColor,
    required this.dataPoints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
              icon,
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 30,
            width: double.infinity,
            child: CustomPaint(
              painter: _SparklinePainter(
                data: dataPoints,
                color: graphColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double max = data.reduce((curr, next) => curr > next ? curr : next);
    final double min = data.reduce((curr, next) => curr < next ? curr : next);
    final double range = max - min == 0 ? 1 : max - min;

    final double dx = size.width / (data.length - 1);

    final Path path = Path();
    path.moveTo(0, size.height - ((data[0] - min) / range) * size.height);

    for (int i = 1; i < data.length; i++) {
      final double x = i * dx;
      final double y = size.height - ((data[i] - min) / range) * size.height;
      // Simple cubic bezier curve approximation for smooth lines
      final double prevX = (i - 1) * dx;
      final double prevY = size.height - ((data[i - 1] - min) / range) * size.height;
      final double cpX1 = prevX + dx / 2;
      final double cpY1 = prevY;
      final double cpX2 = prevX + dx / 2;
      final double cpY2 = y;
      
      path.cubicTo(cpX1, cpY1, cpX2, cpY2, x, y);
    }

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);

    // Gradient fill under the line
    final Path fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.3),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}
