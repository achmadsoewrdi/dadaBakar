import 'dart:math';
import 'package:flutter/material.dart';

class BlynkGaugeWidget extends StatelessWidget {
  final String title;
  final String pin;
  final double value;
  final double maxValue;
  final String unit;
  final Color themeColor;
  final VoidCallback? onDelete;

  const BlynkGaugeWidget({
    super.key,
    required this.title,
    required this.pin,
    required this.value,
    this.maxValue = 100.0,
    required this.unit,
    required this.themeColor,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = (value / maxValue).clamp(0.0, 1.0);

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                  onPressed: onDelete,
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Gauge Dial Painter
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: value),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              final double percentage = (animatedValue / maxValue).clamp(0.0, 1.0);
              return SizedBox(
                height: 95,
                width: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(160, 95),
                      painter: _GaugePainter(
                        percentage: percentage,
                        color: themeColor,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Column(
                        children: [
                          Text(
                            '${animatedValue.toStringAsFixed(0)}$unit',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: themeColor,
                            ),
                          ),
                          Text(
                            'Max: ${maxValue.toStringAsFixed(0)}$unit',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percentage;
  final Color color;

  _GaugePainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 10;

    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final valuePaint = Paint()
      ..color = color
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw background arc (pi radians = semi-circle)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      backgroundPaint,
    );

    // Draw active value arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi * percentage,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) => true;
}
