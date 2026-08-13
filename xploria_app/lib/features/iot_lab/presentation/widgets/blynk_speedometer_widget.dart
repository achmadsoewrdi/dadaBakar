import 'dart:math';
import 'package:flutter/material.dart';

class BlynkSpeedometerWidget extends StatelessWidget {
  final String title;
  final String pin;
  final double value;
  final double maxValue;
  final String unit;
  final Color themeColor;
  final VoidCallback? onDelete;

  const BlynkSpeedometerWidget({
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
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A24), // Dark mode background for premium feel
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
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
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Pin: $pin',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
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
            const SizedBox(height: 20),

            // Speedometer Dial Painter
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: value),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, animatedValue, child) {
                final double percentage = (animatedValue / maxValue).clamp(0.0, 1.0);
                
                // Determine active zone (0, 1, or 2)
                int activeZone = 0;
                if (percentage > 0.66) {
                  activeZone = 2;
                } else if (percentage > 0.33) {
                  activeZone = 1;
                }

                return Column(
                  children: [
                    SizedBox(
                      height: 110,
                      width: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          CustomPaint(
                            size: const Size(200, 110),
                            painter: _SpeedometerPainter(
                              percentage: percentage,
                            ),
                          ),
                          Positioned(
                            bottom: -10,
                            child: Column(
                              children: [
                                Text(
                                  '${animatedValue.toStringAsFixed(0)}$unit',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Lamps Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildLamp(
                          color: const Color(0xFF00C2FF), // Blue
                          isActive: activeZone == 0,
                          label: 'LOW',
                        ),
                        _buildLamp(
                          color: const Color(0xFFFFD700), // Yellow
                          isActive: activeZone == 1,
                          label: 'MED',
                        ),
                        _buildLamp(
                          color: const Color(0xFFFF3B30), // Red
                          isActive: activeZone == 2,
                          label: 'HIGH',
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLamp({required Color color, required bool isActive, required String label}) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? color : color.withValues(alpha: 0.1),
            boxShadow: isActive
                ? [
                    BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 15, spreadRadius: 2),
                    BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 5),
                  ]
                : [],
            border: Border.all(
              color: isActive ? Colors.white : color.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.lightbulb,
            color: isActive ? Colors.white : color.withValues(alpha: 0.5),
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? color : Colors.grey.shade600,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SpeedometerPainter extends CustomPainter {
  final double percentage;

  _SpeedometerPainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 15;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Zone colors
    final colors = [
      const Color(0xFF00C2FF), // Blue
      const Color(0xFFFFD700), // Yellow
      const Color(0xFFFF3B30), // Red
    ];

    // Draw segmented track
    double startAngle = pi;
    double sweepAngle = pi / 3; // 60 degrees for each of the 3 segments

    for (int i = 0; i < 3; i++) {
      final trackPaint = Paint()
        ..color = colors[i].withValues(alpha: 0.3)
        ..strokeWidth = 14
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle + (i * sweepAngle), sweepAngle - 0.05, false, trackPaint);
    }

    // Draw active track (glow effect)
    int activeZone = 0;
    if (percentage > 0.66) activeZone = 2;
    else if (percentage > 0.33) activeZone = 1;

    final activePaint = Paint()
      ..color = colors[activeZone]
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 5);

    // Calculate active sweep up to the current percentage
    double activeSweep = pi * percentage;
    canvas.drawArc(rect, pi, activeSweep, false, activePaint);

    // Draw Needle
    final needleAngle = pi + (pi * percentage);
    
    // Calculate needle points
    final needleLength = radius - 5;
    final tip = Offset(
      center.dx + needleLength * cos(needleAngle),
      center.dy + needleLength * sin(needleAngle),
    );
    
    // Draw needle line
    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
      
    canvas.drawLine(center, tip, needlePaint);
    
    // Draw center pivot
    final pivotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(center, 8, pivotPaint);
    
    final pivotInnerPaint = Paint()
      ..color = colors[activeZone]
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(center, 4, pivotInnerPaint);
  }

  @override
  bool shouldRepaint(covariant _SpeedometerPainter oldDelegate) => true;
}
