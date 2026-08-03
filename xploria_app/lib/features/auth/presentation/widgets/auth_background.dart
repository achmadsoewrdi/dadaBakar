import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  final bool dimBubbles;
  const AuthBackground({
    super.key,
    required this.child,
    this.dimBubbles = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // 1. Vibrant Blue Gradient Background (matches Dashboard)
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C2FF), Color(0xFF005CFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // 2. Playful floating bubbles in semi-transparent white
        // Top-right bubble
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          top: dimBubbles ? -100 : -60,
          right: dimBubbles ? -120 : -60,
          child: _buildBubble(size.width * 0.6, Colors.white.withValues(alpha: dimBubbles ? 0.05 : 0.1)),
        ),
        // Top-left bubble
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          top: dimBubbles ? 20 : 80,
          left: dimBubbles ? -90 : -50,
          child: _buildBubble(110, Colors.white.withValues(alpha: 0.08)),
        ),
        // Center-bottom large bubble
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          bottom: dimBubbles ? -size.height * 0.3 : -size.height * 0.1,
          left: -50,
          child: _buildBubble(size.width * 0.8, Colors.white.withValues(alpha: 0.05)),
        ),
        // Bottom-right bubble
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          bottom: dimBubbles ? -50 : 30,
          right: dimBubbles ? -60 : -20,
          child: _buildBubble(90, Colors.white.withValues(alpha: dimBubbles ? 0.05 : 0.1)),
        ),

        // Main content
        child,
      ],
    );
  }

  // Floating background bubbles helper
  Widget _buildBubble(double size, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
