import 'package:flutter/material.dart';

class BlynkChartWidget extends StatelessWidget {
  final String title;
  final String pin;
  final List<double> history;
  final Color themeColor;
  final String unit;
  final VoidCallback? onDelete;

  const BlynkChartWidget({
    super.key,
    required this.title,
    required this.pin,
    required this.history,
    required this.themeColor,
    required this.unit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final double latestValue = history.isNotEmpty ? history.last : 0.0;
    final double minVal = history.isNotEmpty ? history.reduce((a, b) => a < b ? a : b) - 2 : 0;
    final double maxVal = history.isNotEmpty ? history.reduce((a, b) => a > b ? a : b) + 2 : 100;

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: themeColor.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.show_chart_rounded, color: themeColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0A122C),
                        ),
                      ),
                      Text(
                        'Pin: $pin',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${latestValue.toStringAsFixed(1)} $unit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: themeColor,
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                      onPressed: onDelete,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Paint Line Chart
          SizedBox(
            height: 100,
            width: double.infinity,
            child: CustomPaint(
              painter: _SparklinePainter(
                dataPoints: history,
                color: themeColor,
                minVal: minVal,
                maxVal: maxVal,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> dataPoints;
  final Color color;
  final double minVal;
  final double maxVal;

  _SparklinePainter({
    required this.dataPoints,
    required this.color,
    required this.minVal,
    required this.maxVal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.length < 2) return;

    final paintLine = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintFill = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (dataPoints.length - 1);
    final rangeY = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final y = size.height - ((dataPoints[i] - minVal) / rangeY * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);

    // Active end point dot
    final lastX = size.width;
    final lastY = size.height - ((dataPoints.last - minVal) / rangeY * size.height);
    canvas.drawCircle(Offset(lastX, lastY), 5, Paint()..color = color);
    canvas.drawCircle(Offset(lastX, lastY), 8, Paint()..color = color.withValues(alpha: 0.3));
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => true;
}
