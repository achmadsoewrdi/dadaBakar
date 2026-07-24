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
        // 1. Premium Dark Navy Background
        Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF0A122C),
        ),

        // 2. Playful floating circles in logo colors (Blue & Teal)
        // Top-right light blue/cyan bubble
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          top: dimBubbles ? -100 : -60,
          right: dimBubbles ? -120 : -60,
          child: _buildBubble(size.width * 0.6, const Color(0xFF00C2FF).withOpacity(dimBubbles ? 0.15 : 0.35)),
        ),
        // Top-left soft teal bubble
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          top: dimBubbles ? 20 : 80,
          left: dimBubbles ? -90 : -50,
          child: _buildBubble(110, const Color(0xFF00E3A2).withOpacity(0.15)),
        ),
        // Center-bottom large blue/violet bubble
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          bottom: dimBubbles ? -size.height * 0.3 : -size.height * 0.1,
          left: -50,
          child: _buildBubble(size.width * 0.8, const Color(0xFF005CFF).withOpacity(0.12)),
        ),
        // Bottom-right teal/cyan bubble
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          bottom: dimBubbles ? -50 : 30,
          right: dimBubbles ? -60 : -20,
          child: _buildBubble(90, const Color(0xFF00E3A2).withOpacity(dimBubbles ? 0.15 : 0.25)),
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
