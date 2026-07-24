import 'package:flutter/material.dart';

class XploriaLogo extends StatelessWidget {
  final double scale;
  const XploriaLogo({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    double size = 110 * scale;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. The stylized "X" with rocket
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Left-to-right blue bar
              Transform.rotate(
                angle: -0.785398, // -math.pi / 4
                child: Container(
                  width: 17 * scale,
                  height: 92 * scale,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF005CFF), Color(0xFF00C2FF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(9 * scale),
                  ),
                ),
              ),
              // Right-to-left teal bar
              Transform.rotate(
                angle: 0.785398, // math.pi / 4
                child: Container(
                  width: 17 * scale,
                  height: 92 * scale,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E3A2), Color(0xFF00C6AB)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(9 * scale),
                  ),
                ),
              ),
              // Rocket icon flying out of the teal bar
              Positioned(
                top: 10 * scale,
                right: 10 * scale,
                child: Transform.rotate(
                  angle: 0.785398,
                  child: Container(
                    padding: EdgeInsets.all(4 * scale),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0A122C), // Cutout matching background
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.rocket_launch_rounded,
                      color: const Color(0xFF00E3A2),
                      size: 32 * scale,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16 * scale),

        // 2. Stylized logo text: "PLORIA" (using custom 'O' with dot)
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'PL',
              style: TextStyle(
                fontSize: 34 * scale,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2ED9C3), // Mint green
                letterSpacing: 2.0 * scale,
                fontFamily: 'Montserrat',
              ),
            ),
            // Custom circular 'O' with center dot
            Container(
              width: 24 * scale,
              height: 24 * scale,
              margin: EdgeInsets.symmetric(horizontal: 4 * scale),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2ED9C3), width: 3.5 * scale),
              ),
              child: Center(
                child: Container(
                  width: 5 * scale,
                  height: 5 * scale,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2ED9C3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Text(
              'RIA',
              style: TextStyle(
                fontSize: 34 * scale,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2ED9C3),
                letterSpacing: 2.0 * scale,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
        SizedBox(height: 6 * scale),
        // Slogan (hidden when scaled down significantly to avoid overcrowding)
        if (scale > 0.8)
          Text(
            'Explore the fun of learning!',
            style: TextStyle(
              fontSize: 14 * scale,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
