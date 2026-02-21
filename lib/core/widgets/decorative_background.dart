import 'package:flutter/material.dart';

/// Soft circular blobs for background depth. Weather-agnostic.
class DecorativeBackground extends StatelessWidget {
  final List<Color> gradientColors;
  final bool showBlobs;

  const DecorativeBackground({
    super.key,
    required this.gradientColors,
    this.showBlobs = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gradientColors[0],
                  gradientColors[1],
                  gradientColors.length > 2 ? gradientColors[2] : gradientColors[0].withOpacity(0.9),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        if (showBlobs) ..._buildBlobs(context),
      ],
    );
  }

  List<Widget> _buildBlobs(BuildContext context) {
    final c = gradientColors[0];
    final light = c.withOpacity(0.15);
    return [
      Positioned(
        top: -80,
        right: -60,
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: light,
          ),
        ),
      ),
      Positioned(
        top: 120,
        left: -100,
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: light,
          ),
        ),
      ),
      Positioned(
        bottom: 100,
        right: -40,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: light,
          ),
        ),
      ),
    ];
  }
}
