import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:laminar/laminar.dart';

/// Apple Logo Composition — 5 s @ 30 fps (150 frames, looping).
class AppleLogoComposition extends StatelessWidget {
  const AppleLogoComposition({super.key});

  @override
  Widget build(BuildContext context) {
    final frame = useCurrentFrame(context);
    final config = useVideoConfig(context);
    final total = config.durationInFrames;

    // Opacity envelope
    final fadeIn = interpolate(
      frame,
      [0, 25],
      [0.0, 1.0],
      easing: LaminarEasing.easeOutCubic,
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );
    final fadeOut = interpolate(
      frame,
      [128, total],
      [1.0, 0.0],
      easing: LaminarEasing.easeInCubic,
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );
    final opacity = (fadeIn * fadeOut).clamp(0.0, 1.0);

    // Scale envelope
    final scaleIn = interpolate(
      frame,
      [0, 38],
      [0.38, 1.0],
      easing: LaminarEasing.easeOutCubic,
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );
    final scaleOut = interpolate(
      frame,
      [128, total],
      [1.0, 0.82],
      easing: LaminarEasing.easeInCubic,
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );
    final scale = scaleIn * scaleOut;

    // Rainbow hue frames 30-120
    final shimmerHue = interpolate(
      frame,
      [30, 120],
      [0.0, 360.0],
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );

    // Glow pulse frames 60-120
    final glowT = interpolate(
      frame,
      [60, 120],
      [0.0, 1.0],
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );
    final glowRadius = 16.0 + 18.0 * math.sin(glowT * 2 * math.pi * 2.5);

    // Text slide-up frames 10-40
    final textSlide = interpolate(
      frame,
      [10, 42],
      [28.0, 0.0],
      easing: LaminarEasing.easeOutCubic,
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );

    final bgHue = (shimmerHue + 210) % 360;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.4,
              colors: [
                HSLColor.fromAHSL(1, bgHue, 0.50, 0.08).toColor(),
                const Color(0xFF000000),
              ],
            ),
          ),
        ),

        // Starfield
        CustomPaint(painter: _StarfieldPainter(frame: frame)),

        // Logo + tagline — FittedBox keeps content inside viewport at any size
        Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo — width:height = 814.1:1000
                      SizedBox(
                        width: 200,
                        height: 246,
                        child: CustomPaint(
                          painter: _AppleLogoPainter(
                            shimmerHue: shimmerHue,
                            glowRadius: glowRadius,
                            opacity: opacity,
                          ),
                        ),
                      ),

                      const SizedBox(height: 44),

                      // Tagline
                      Transform.translate(
                        offset: Offset(0, textSlide),
                        child: Column(
                          children: [
                            Text(
                              'Think Different.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Helvetica Neue',
                                fontFamilyFallback: const [
                                  'Helvetica',
                                  'Arial',
                                  'sans-serif',
                                ],
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 26,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 4.2,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'frame $frame / $total',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Helvetica Neue',
                                fontFamilyFallback: const [
                                  'Helvetica',
                                  'Arial',
                                  'sans-serif',
                                ],
                                color: Colors.white.withValues(alpha: 0.22),
                                fontSize: 11,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AppleLogoPainter extends CustomPainter {
  const _AppleLogoPainter({
    required this.shimmerHue,
    required this.glowRadius,
    required this.opacity,
  });
  final double shimmerHue;
  final double glowRadius;
  final double opacity;

  Path _buildPath(double w, double h) {
    // Original bounding box is roughly 814.1 x 1000
    // We scale points to fit the available widget (w x h)
    double x(double n) => n * (w / 814.10);
    double y(double n) => n * (h / 1000.00);

    final path = Path();

    // Body
    path.moveTo(x(788.10), y(340.90));
    path.cubicTo(
      x(782.30),
      y(345.40),
      x(679.90),
      y(403.10),
      x(679.90),
      y(531.40),
    );
    path.cubicTo(
      x(679.90),
      y(679.80),
      x(810.20),
      y(732.30),
      x(814.10),
      y(733.60),
    );
    path.cubicTo(
      x(813.50),
      y(736.80),
      x(793.40),
      y(805.50),
      x(745.40),
      y(875.50),
    );
    path.cubicTo(
      x(702.60),
      y(937.10),
      x(657.90),
      y(998.60),
      x(589.90),
      y(998.60),
    );
    path.cubicTo(
      x(521.90),
      y(998.60),
      x(504.40),
      y(959.10),
      x(425.90),
      y(959.10),
    );
    path.cubicTo(
      x(349.40),
      y(959.10),
      x(322.20),
      y(999.90),
      x(260.00),
      y(999.90),
    );
    path.cubicTo(
      x(197.80),
      y(999.90),
      x(154.40),
      y(942.90),
      x(104.50),
      y(872.90),
    );
    path.cubicTo(x(46.70), y(790.70), x(0.00), y(663.00), x(0.00), y(541.80));
    path.cubicTo(
      x(0.00),
      y(347.40),
      x(126.40),
      y(244.30),
      x(250.80),
      y(244.30),
    );
    path.cubicTo(
      x(316.90),
      y(244.30),
      x(372.00),
      y(287.70),
      x(413.50),
      y(287.70),
    );
    path.cubicTo(
      x(453.00),
      y(287.70),
      x(514.60),
      y(241.70),
      x(589.80),
      y(241.70),
    );
    path.cubicTo(
      x(618.30),
      y(241.70),
      x(720.70),
      y(244.30),
      x(788.10),
      y(340.90),
    );
    path.close();

    // Leaf
    path.moveTo(x(554.10), y(159.40));
    path.cubicTo(
      x(585.20),
      y(122.50),
      x(607.20),
      y(71.30),
      x(607.20),
      y(20.10),
    );
    path.cubicTo(x(607.20), y(13.00), x(606.60), y(5.80), x(605.30), y(0.00));
    path.cubicTo(x(554.70), y(1.90), x(494.50), y(33.70), x(458.20), y(75.80));
    path.cubicTo(
      x(429.70),
      y(108.20),
      x(403.10),
      y(159.40),
      x(403.10),
      y(211.30),
    );
    path.cubicTo(
      x(403.10),
      y(219.10),
      x(404.40),
      y(226.90),
      x(405.00),
      y(229.40),
    );
    path.cubicTo(
      x(408.20),
      y(230.00),
      x(413.40),
      y(230.70),
      x(418.60),
      y(230.70),
    );
    path.cubicTo(
      x(464.00),
      y(230.70),
      x(521.10),
      y(200.30),
      x(554.10),
      y(159.40),
    );
    path.close();

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = _buildPath(w, h);
    final rect = Offset.zero & size;

    // Rainbow gradient colours
    final h1 = shimmerHue % 360;
    final h2 = (h1 + 72) % 360;
    final h3 = (h1 + 144) % 360;
    final h4 = (h1 + 216) % 360;
    final h5 = (h1 + 288) % 360;

    // Glow
    final glowColor = HSLColor.fromAHSL(
      0.55 * opacity,
      h1,
      1.0,
      0.58,
    ).toColor();
    canvas.drawShadow(path, glowColor, glowRadius, false);

    final bloomPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.14 * opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, glowRadius * 2.4);
    canvas.drawPath(path, bloomPaint);

    // Main rainbow fill
    final gradPaint = Paint()
      ..shader = ui.Gradient.linear(
        rect.topLeft,
        rect.bottomRight,
        [
          HSLColor.fromAHSL(1, h1, 0.92, 0.64).toColor(),
          HSLColor.fromAHSL(1, h2, 0.92, 0.60).toColor(),
          HSLColor.fromAHSL(1, h3, 0.92, 0.60).toColor(),
          HSLColor.fromAHSL(1, h4, 0.92, 0.62).toColor(),
          HSLColor.fromAHSL(1, h5, 0.92, 0.64).toColor(),
        ],
        [0.0, 0.25, 0.5, 0.75, 1.0],
      )
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, gradPaint);

    // Specular highlight (top-left radial)
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.radial(Offset(w * 0.26, h * 0.26), w * 0.52, [
          Colors.white.withValues(alpha: 0.40 * opacity),
          Colors.white.withValues(alpha: 0.0),
        ])
        ..style = PaintingStyle.fill,
    );

    // Secondary sheen at crown of left lobe
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.radial(Offset(w * 0.30, h * 0.22), w * 0.20, [
          Colors.white.withValues(alpha: 0.22 * opacity),
          Colors.white.withValues(alpha: 0.0),
        ])
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_AppleLogoPainter old) =>
      old.shimmerHue != shimmerHue ||
      old.glowRadius != glowRadius ||
      old.opacity != opacity;
}

// ─────────────────────────────────────────────────────────────────────────────
// Twinkling starfield
// ─────────────────────────────────────────────────────────────────────────────
class _StarfieldPainter extends CustomPainter {
  _StarfieldPainter({required this.frame});
  final int frame;

  static final _stars = List.generate(80, (i) {
    final r = math.Random(i * 7919);
    return (
      x: r.nextDouble(),
      y: r.nextDouble(),
      rad: 0.4 + r.nextDouble() * 1.1,
      spd: 0.3 + r.nextDouble() * 0.7,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = frame / 150.0;
    final p = Paint()..style = PaintingStyle.fill;
    for (final s in _stars) {
      final tw =
          0.25 +
          0.75 * ((math.sin(t * s.spd * math.pi * 4 + s.x * 10) + 1) / 2);
      p.color = Colors.white.withValues(alpha: tw * 0.48);
      canvas.drawCircle(Offset(s.x * size.width, s.y * size.height), s.rad, p);
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) => old.frame != frame;
}
