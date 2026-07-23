import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Color(0xFF005CFF),
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google G Logo Widget
                  _buildGoogleLogo(),
                  const SizedBox(width: 12),
                  const Text(
                    'Sign in with Google',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGoogleLogo() {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(
        painter: GoogleLogoPainter(),
      ),
    );
  }
}

class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Red
    paint.color = const Color(0xFFEA4335);
    final Path redPath = Path()
      ..moveTo(width * 0.5, height * 0.2)
      ..cubicTo(width * 0.65, height * 0.2, width * 0.77, height * 0.25, width * 0.86, height * 0.33)
      ..lineTo(width * 0.98, height * 0.21)
      ..cubicTo(width * 0.86, height * 0.09, width * 0.7, 0, width * 0.5, 0)
      ..cubicTo(width * 0.26, 0, width * 0.06, height * 0.14, 0, height * 0.35)
      ..lineTo(width * 0.23, height * 0.52)
      ..cubicTo(width * 0.28, height * 0.33, width * 0.38, height * 0.2, width * 0.5, height * 0.2);
    canvas.drawPath(redPath, paint);

    // Blue
    paint.color = const Color(0xFF4285F4);
    final Path bluePath = Path()
      ..moveTo(width, height * 0.5)
      ..cubicTo(width, height * 0.46, width * 0.99, height * 0.41, width * 0.98, height * 0.37)
      ..lineTo(width * 0.5, height * 0.37)
      ..lineTo(width * 0.5, height * 0.62)
      ..lineTo(width * 0.79, height * 0.62)
      ..cubicTo(width * 0.77, height * 0.72, width * 0.7, height * 0.81, width * 0.6, height * 0.87)
      ..lineTo(width * 0.82, height * 1.04)
      ..cubicTo(width * 0.96, height * 0.91, width, height * 0.73, width, height * 0.5);
    canvas.drawPath(bluePath, paint);

    // Green
    paint.color = const Color(0xFF34A853);
    final Path greenPath = Path()
      ..moveTo(width * 0.5, height)
      ..cubicTo(width * 0.7, height, width * 0.86, height * 0.93, width * 0.97, height * 0.83)
      ..lineTo(width * 0.74, height * 0.65)
      ..cubicTo(width * 0.68, height * 0.7, width * 0.6, height * 0.73, width * 0.5, height * 0.73)
      ..cubicTo(width * 0.38, height * 0.73, width * 0.28, height * 0.6, width * 0.23, height * 0.46)
      ..lineTo(0, height * 0.64)
      ..cubicTo(width * 0.06, height * 0.86, width * 0.26, height, width * 0.5, height);
    canvas.drawPath(greenPath, paint);

    // Yellow
    paint.color = const Color(0xFFFBBC05);
    final Path yellowPath = Path()
      ..moveTo(0, height * 0.35)
      ..cubicTo(0, height * 0.4, 0.01, height * 0.45, 0.03, height * 0.5)
      ..cubicTo(0.01, height * 0.55, 0, height * 0.6, 0, height * 0.65)
      ..lineTo(width * 0.23, height * 0.47)
      ..cubicTo(width * 0.22, height * 0.43, width * 0.22, height * 0.39, width * 0.23, height * 0.35)
      ..lineTo(0, height * 0.17)
      ..cubicTo(0.01, height * 0.23, 0, height * 0.29, 0, height * 0.35);
    canvas.drawPath(yellowPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
