import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AiAnalysisResultScreen extends StatelessWidget {
  final List<double> chartData;

  const AiAnalysisResultScreen({
    super.key,
    this.chartData = const [], // Default empty data
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF003092)),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFF005CFF)),
            const SizedBox(width: 8),
            Text(
              'Analysis Result',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0A122C),
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Executive Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE0F7FA), Color(0xFFBBDEFB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF005CFF).withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Executive Summary',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: const Color(0xFF0A122C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'The analysis shows optimal plant growth is achieved when maintaining temperatures between 26°C - 28°C.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1E293B),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Image.asset(
                    'assets/images/modules/project/plant.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Chart Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _AnalysisChartPainter(
                        dataPoints: chartData.isEmpty 
                            ? [25.0, 27.0, 28.0, 26.0, 29.0, 27.0, 26.0] // Dummy data if empty
                            : chartData,
                        minY: 20,
                        maxY: 30,
                        optimalMinY: 26,
                        optimalMaxY: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // AI Recommendations Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Recommendations',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: const Color(0xFF0A122C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRecommendationItem('Maintain temperature between 26°C - 28°C'),
                  const SizedBox(height: 12),
                  _buildRecommendationItem('Water when soil humidity falls below 65%'),
                  const SizedBox(height: 12),
                  _buildRecommendationItem('Increase morning light exposure for 2 hours'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Download Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005CFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.download_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Download PDF Report',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF005CFF), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _AnalysisChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final double minY;
  final double maxY;
  final double optimalMinY;
  final double optimalMaxY;

  _AnalysisChartPainter({
    required this.dataPoints,
    required this.minY,
    required this.maxY,
    required this.optimalMinY,
    required this.optimalMaxY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Leave space for Y axis labels on the left and X axis labels at the bottom
    const double paddingLeft = 40;
    const double paddingBottom = 30;
    const double paddingTop = 10;
    const double paddingRight = 10;
    
    final double graphWidth = size.width - paddingLeft - paddingRight;
    final double graphHeight = size.height - paddingBottom - paddingTop;
    final double graphTop = paddingTop;
    final double graphBottom = size.height - paddingBottom;
    final double graphLeft = paddingLeft;
    final double graphRight = size.width - paddingRight;

    final paintGrid = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw horizontal grid lines and Y axis labels
    const int yDivisions = 5; // 20, 22, 24, 26, 28, 30
    for (int i = 0; i <= yDivisions; i++) {
      final double yValue = minY + (maxY - minY) * (i / yDivisions);
      final double yPos = graphBottom - (graphHeight * (i / yDivisions));
      
      canvas.drawLine(Offset(graphLeft, yPos), Offset(graphRight, yPos), paintGrid);
      
      textPainter.text = TextSpan(
        text: '${yValue.toInt()}°C',
        style: const TextStyle(color: Color(0xFF475569), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(graphLeft - textPainter.width - 8, yPos - textPainter.height / 2));
    }
    
    // Y axis title
    canvas.save();
    canvas.translate(0, graphTop + graphHeight / 2);
    canvas.rotate(-3.14159 / 2);
    textPainter.text = const TextSpan(
      text: 'Temperature (°C)',
      style: TextStyle(color: Color(0xFF475569), fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, 2));
    canvas.restore();

    // Draw X axis labels and vertical grid lines
    final List<String> xLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final int xDivisions = xLabels.length;
    final double xStep = graphWidth / (xDivisions - 1);
    
    for (int i = 0; i < xDivisions; i++) {
      final double xPos = graphLeft + (i * xStep);
      
      canvas.drawLine(Offset(xPos, graphTop), Offset(xPos, graphBottom), paintGrid);
      
      textPainter.text = TextSpan(
        text: xLabels[i],
        style: const TextStyle(color: Color(0xFF475569), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(xPos - textPainter.width / 2, graphBottom + 8));
    }

    // X axis title
    textPainter.text = const TextSpan(
      text: 'Temperature (°C)', // This acts as X-axis title in the screenshot
      style: TextStyle(color: Color(0xFF475569), fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(graphLeft + graphWidth / 2 - textPainter.width / 2, graphBottom + 22));

    // Draw Optimal Zone (Green Background)
    final double optimalBottomY = graphBottom - (graphHeight * ((optimalMinY - minY) / (maxY - minY)));
    final double optimalTopY = graphBottom - (graphHeight * ((optimalMaxY - minY) / (maxY - minY)));
    
    final paintOptimalZone = Paint()
      ..color = Colors.green.withOpacity(0.15)
      ..style = PaintingStyle.fill;
      
    final optimalRect = Rect.fromLTRB(graphLeft, optimalTopY, graphRight, optimalBottomY);
    canvas.drawRect(optimalRect, paintOptimalZone);

    // Draw "Optimal Zone" text badge
    final paintBadge = Paint()
      ..color = Colors.green.withOpacity(0.2)
      ..style = PaintingStyle.fill;
      
    textPainter.text = const TextSpan(
      text: 'Optimal Zone',
      style: TextStyle(color: Color(0xFF166534), fontSize: 10, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    
    final badgeRect = Rect.fromLTWH(
      graphLeft + 8, 
      optimalTopY + 4, 
      textPainter.width + 12, 
      textPainter.height + 8
    );
    
    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(4)), paintBadge);
    textPainter.paint(canvas, Offset(badgeRect.left + 6, badgeRect.top + 4));

    if (dataPoints.isEmpty) return;

    // Draw data line
    final Path path = Path();
    final Path fillPath = Path();
    
    final double pointStep = graphWidth / (dataPoints.length - 1);
    
    // Generate smooth curve using Bezier
    List<Offset> points = [];
    for (int i = 0; i < dataPoints.length; i++) {
      double val = dataPoints[i];
      if (val < minY) val = minY;
      if (val > maxY) val = maxY;
      
      final double xPos = graphLeft + (i * pointStep);
      final double yPos = graphBottom - (graphHeight * ((val - minY) / (maxY - minY)));
      points.add(Offset(xPos, yPos));
    }

    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      fillPath.moveTo(points.first.dx, graphBottom);
      fillPath.lineTo(points.first.dx, points.first.dy);

      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        
        final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
        final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
        
        path.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          p1.dx, p1.dy,
        );
        
        fillPath.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          p1.dx, p1.dy,
        );
      }
      
      fillPath.lineTo(points.last.dx, graphBottom);
      fillPath.close();

      // Draw Fill Gradient
      final Paint paintFill = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF005CFF).withOpacity(0.2),
            const Color(0xFF005CFF).withOpacity(0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTRB(graphLeft, graphTop, graphRight, graphBottom))
        ..style = PaintingStyle.fill;
        
      canvas.drawPath(fillPath, paintFill);

      // Draw Line
      final Paint paintLine = Paint()
        ..color = const Color(0xFF005CFF)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
        
      canvas.drawPath(path, paintLine);
    }
  }

  @override
  bool shouldRepaint(covariant _AnalysisChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints;
  }
}
