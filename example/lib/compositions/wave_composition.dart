import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:laminar/laminar.dart';

/// Demo 3: Procedural audio wave visualiser.
///
/// Pure [CustomPaint] driven entirely by [useCurrentFrame()].
/// No external data — demonstrates how complex visuals emerge from
/// simple math on the frame index.
class WaveComposition extends StatelessWidget {
  const WaveComposition({super.key});

  @override
  Widget build(BuildContext context) {
    final frame = useCurrentFrame(context);
    final config = useVideoConfig(context);

    // Animate amplitude envelope: grow in, sustain, shrink out
    final amplitude = interpolate(
      frame,
      [0, 15, 70, 90],
      [0.0, 1.0, 1.0, 0.0],
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0D030E), Color(0xFF0D0D12)],
            ),
          ),
        ),
        // Wave canvas
        CustomPaint(
          painter: _WavePainter(
            frame: frame,
            amplitude: amplitude,
            totalFrames: config.durationInFrames,
          ),
        ),
        // Overlay text
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                'LAMINAR WAVE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFFF6584).withOpacity(amplitude),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'frame $frame / ${config.durationInFrames}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  final int frame;
  final double amplitude;
  final int totalFrames;

  _WavePainter({
    required this.frame,
    required this.amplitude,
    required this.totalFrames,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final t = frame / totalFrames;

    // Draw 5 layered waves with different frequencies and colours
    final waves = [
      (freq: 2.0, amp: 0.20, phase: 0.0,  color: const Color(0xFFFF6584)),
      (freq: 3.0, amp: 0.14, phase: 0.5,  color: const Color(0xFF6C63FF)),
      (freq: 5.0, amp: 0.09, phase: 1.2,  color: const Color(0xFF00C9A7)),
      (freq: 7.0, amp: 0.06, phase: 2.1,  color: const Color(0xFFFFBE0B)),
      (freq: 1.5, amp: 0.25, phase: 0.8,  color: Colors.white),
    ];

    for (final w in waves) {
      final path = Path();
      final paint = Paint()
        ..color = w.color.withOpacity(0.55 * amplitude)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i <= size.width.toInt(); i++) {
        final x = i.toDouble();
        final nx = x / size.width;
        final y = cy +
            math.sin(nx * w.freq * 2 * math.pi + w.phase + t * 2 * math.pi) *
                size.height *
                w.amp *
                amplitude;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }

    // Bar visualiser across the bottom
    final barCount = 48;
    final barWidth = size.width / barCount;
    for (int i = 0; i < barCount; i++) {
      final barT = i / barCount;
      final height = math.sin(barT * math.pi * 3 + t * math.pi * 4).abs() *
          size.height *
          0.28 *
          amplitude;

      final barPaint = Paint()
        ..color = const Color(0xFFFF6584).withOpacity(0.45 * amplitude)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            i * barWidth + 1,
            size.height - height - 12,
            barWidth - 2,
            height,
          ),
          const Radius.circular(2),
        ),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.frame != frame || old.amplitude != amplitude;
}
