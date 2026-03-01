import 'package:flutter/material.dart';
import 'package:laminar/laminar.dart';

/// Demo 2: Animated counter 0 → 100.
///
/// Demonstrates [interpolate] with [LaminarEasing.easeOutCubic] for a snappy number
/// count-up, plus a circular progress ring built with [CustomPaint].
class CounterComposition extends StatelessWidget {
  const CounterComposition({super.key});

  @override
  Widget build(BuildContext context) {
    final frame = useCurrentFrame(context);
    final config = useVideoConfig(context);

    // Count from 0 → 100 over 100 frames with ease-out feel
    final count = interpolate(
      frame,
      [0, 100],
      [0.0, 100.0],
      easing: LaminarEasing.easeOutCubic,
      extrapolateRight: Extrapolate.clamp,
    );

    // Ring progress 0→1 over full duration
    final ringProgress = interpolate(
      frame,
      [0, config.durationInFrames - 1],
      [0.0, 1.0],
      extrapolateRight: Extrapolate.clamp,
    );

    // Pulse scale at multiples of 10
    final nearTen = (count % 10 < 1.5) ? (1 - (count % 10) / 1.5) : 0.0;
    final pulseScale = 1.0 + nearTen * 0.06;

    // Colour morphs teal → green as count climbs
    final hue = interpolate(count, [0, 100], [180.0, 130.0]);
    final accent = HSLColor.fromAHSL(1, hue, 0.7, 0.55).toColor();

    return Stack(
      fit: StackFit.expand,
      children: [
        // Dark bg
        Container(color: const Color(0xFF0D0D12)),
        // Radial glow
        Center(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [accent.withValues(alpha: 0.15), Colors.transparent]),
            ),
          ),
        ),
        // Progress ring + counter
        Center(
          child: Transform.scale(
            scale: pulseScale,
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: _RingPainter(progress: ringProgress, color: accent),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          count.toInt().toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 72,
                            fontWeight: FontWeight.w800,
                            height: 1,
                            shadows: [Shadow(color: accent.withValues(alpha: 0.6), blurRadius: 30)],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '%',
                          style: TextStyle(color: accent, fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Bottom label
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Text(
            'frame $frame  •  useCurrentFrame() + interpolate()',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12, letterSpacing: 0.4),
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {

  _RingPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white10
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // start at top
      2 * 3.14159 * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress || old.color != color;
}
