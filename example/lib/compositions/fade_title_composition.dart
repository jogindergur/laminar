import 'package:flutter/material.dart';
import 'package:laminar/laminar.dart';

/// Demo 1: Fade + scale title animation.
///
/// Uses [useCurrentFrame], [interpolate], and [LaminarEasing.easeOutCubic].
class FadeTitleComposition extends StatelessWidget {
  const FadeTitleComposition({super.key});

  @override
  Widget build(BuildContext context) {
    final frame = useCurrentFrame(context);
    final config = useVideoConfig(context);

    // Fade in 0→1 over the first 30 frames
    final opacity = interpolate(
      frame,
      [0, 30],
      [0.0, 1.0],
      easing: LaminarEasing.easeOutCubic,
      extrapolateRight: Extrapolate.clamp,
    );

    // Scale up from 0.7 → 1.0 over first 40 frames
    final scale = interpolate(
      frame,
      [0, 40],
      [0.7, 1.0],
      easing: LaminarEasing.easeOutCubic,
      extrapolateRight: Extrapolate.clamp,
    );

    // Subtitle slides up: y-offset 30→0 between frames 15–50
    final slideY = interpolate(
      frame,
      [15, 50],
      [30.0, 0.0],
      easing: LaminarEasing.easeOutCubic,
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );

    // Fade out gently from frame 70–90
    final fadeOut = interpolate(
      frame,
      [70, 90],
      [1.0, 0.0],
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );

    final finalOpacity = (opacity * fadeOut).clamp(0.0, 1.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background gradient that shifts hue with frame
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                HSLColor.fromAHSL(1, (frame * 1.2) % 360, 0.7, 0.08).toColor(),
                const Color(0xFF0D0D1A),
              ],
            ),
          ),
        ),
        // Subtle grid lines
        CustomPaint(painter: _GridPainter()),
        // Main content
        Center(
          child: Opacity(
            opacity: finalOpacity,
            child: Transform.scale(
              scale: scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Frame counter badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      '${config.id}  •  frame $frame / ${config.durationInFrames}',
                      style: const TextStyle(
                        color: Color(0xFF6C63FF),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  const Text(
                    'Hello, Laminar!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Subtitle slides up
                  Transform.translate(
                    offset: Offset(0, slideY),
                    child: Text(
                      'interpolate() + LaminarEasing.easeOutCubic',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Animated progress bar
                  SizedBox(
                    width: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: frame / config.durationInFrames,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF6C63FF),
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}
