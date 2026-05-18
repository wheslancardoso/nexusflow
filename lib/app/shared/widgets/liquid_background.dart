import 'package:flutter/material.dart';

class LiquidBackground extends StatelessWidget {
  final Widget child;

  const LiquidBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🔮 Deep Dark Space Background
        Container(
          color: const Color(0xFF06040A),
        ),
        
        // 🌌 Neon Indigo Fluid Glow (Top Left)
        Positioned(
          top: -150,
          left: -150,
          child: Container(
            width: 450,
            height: 450,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.35),
                  const Color(0xFF6366F1).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),

        // 🌌 Neon Magenta Fluid Glow (Bottom Right)
        Positioned(
          bottom: -200,
          right: -200,
          child: Container(
            width: 550,
            height: 550,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFEC4899).withOpacity(0.25),
                  const Color(0xFFEC4899).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),

        // 🌌 Neon Cyan Fluid Glow (Center Left)
        Positioned(
          top: 250,
          left: -250,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF06B6D4).withOpacity(0.22),
                  const Color(0xFF06B6D4).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),

        // 🛡️ Safe child overlay
        child,
      ],
    );
  }
}
