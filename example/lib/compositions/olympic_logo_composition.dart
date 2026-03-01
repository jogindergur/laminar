import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:laminar/laminar.dart';

/// Olympic Rings Composition — 5 s @ 30 fps (150 frames, looping).
///
/// Interlocking weave strategy:
///   Each adjacent pair (A, B) has TWO crossing points:
///     • Upper crossing (smaller y): A is in FRONT of B
///     • Lower crossing (larger y):  B is in FRONT of A
///
/// Paint order:
///   1. All 5 rings as full strokes
///   2. White inner fills for all 5 rings (clears visible-through-hole artefacts)
///   3. For each of the 8 crossing points:
///        a. White erase arc of the BACK ring  (slightly wider, covers its stroke)
///        b. Coloured arc of the FRONT ring    (redrawn on top)
///
/// Crossing angles are computed analytically via circle-circle intersection.
///
/// Timeline
///   0 – 20  : Blue draws
///  16 – 36  : Yellow draws
///  32 – 52  : Black draws
///  48 – 68  : Green draws
///  64 – 84  : Red draws
///  84 – 130 : All complete — coloured glow pulse
///  70 – 95  : "OLYMPIC RINGS" tagline slides up
/// 130 – 150 : Fade out before loop
class OlympicLogoComposition extends StatelessWidget {
  const OlympicLogoComposition({super.key});

  @override
  Widget build(BuildContext context) {
    final frame = useCurrentFrame(context);
    final config = useVideoConfig(context);
    final total = config.durationInFrames;

    double prog(int start, int end) => interpolate(
      frame,
      [start, end],
      [0.0, 1.0],
      easing: LaminarEasing.easeOutCubic,
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );

    final blueP = prog(0, 20);
    final yellowP = prog(16, 36);
    final blackP = prog(32, 52);
    final greenP = prog(48, 68);
    final redP = prog(64, 84);

    final fadeIn = prog(0, 8);
    final fadeOut = interpolate(
      frame,
      [130, total],
      [1.0, 0.0],
      easing: LaminarEasing.easeInCubic,
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );
    final opacity = (fadeIn * fadeOut).clamp(0.0, 1.0);

    final glowT = interpolate(
      frame,
      [84, 130],
      [0.0, 1.0],
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );
    final glow = 0.5 + 0.5 * math.sin(glowT * math.pi * 6);

    final tagSlide = interpolate(
      frame,
      [70, 95],
      [20.0, 0.0],
      easing: LaminarEasing.easeOutCubic,
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );
    final tagOpacity = prog(70, 95);

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Colors.white),
        Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 700,
              height: 300,
              child: CustomPaint(
                painter: _OlympicPainter(
                  progresses: [blueP * opacity, yellowP * opacity, blackP * opacity, greenP * opacity, redP * opacity],
                  glow: glow,
                  allDone: redP >= 1.0,
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0, 0.90),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Opacity(
              opacity: tagOpacity * opacity,
              child: Transform.translate(
                offset: Offset(0, tagSlide),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'OLYMPIC RINGS',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 5,
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'frame $frame / $total',
                      style: TextStyle(fontSize: 9, letterSpacing: 1.5, color: Colors.black.withValues(alpha: 0.22)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Geometry helper
// ─────────────────────────────────────────────────────────────────────────────

/// Returns the two angles (rad) on circle A where it intersects circle B.
/// Both circles have the same radius [r].
/// angles[0] will be the UPPER crossing (smaller y on screen).
/// angles[1] will be the LOWER crossing (larger y on screen).
/// Returns null if the circles don't properly intersect.
List<double>? _intersectAngles(Offset ca, Offset cb, double r) {
  final dx = cb.dx - ca.dx;
  final dy = cb.dy - ca.dy;
  final d = math.sqrt(dx * dx + dy * dy);
  if (d >= 2 * r || d <= 0) return null;
  final alpha = math.atan2(dy, dx);
  final beta = math.acos(d / (2 * r));
  // angles[0] has smaller sin → smaller y on screen (upper crossing)
  return [alpha - beta, alpha + beta];
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

class _OlympicPainter extends CustomPainter {

  const _OlympicPainter({required this.progresses, required this.glow, required this.allDone});
  final List<double> progresses; // [blue, yellow, black, green, red]
  final double glow;
  final bool allDone;

  // ── Constants ──────────────────────────────────────────────────────────────

  static const _w = 700.0;
  static const _h = 300.0;
  static const _r = 75.0;
  static const _sw = 13.0;

  // 0=Blue(top)  1=Yellow(btm)  2=Black(top)  3=Green(btm)  4=Red(top)
  static const _cx = [100.0, 218.0, 336.0, 454.0, 572.0];
  static const _cy = [145.0, 191.0, 145.0, 191.0, 145.0];

  static const _colors = [
    Color(0xFF0085C7), // 0 Blue
    Color(0xFFF4C300), // 1 Yellow
    Color(0xFF000000), // 2 Black
    Color(0xFF009F6B), // 3 Green
    Color(0xFFDF0024), // 4 Red
  ];

  // Pairs drawn in index order: right ring (higher index) ends up on top by
  // default, which is exactly correct for the LOWER crossing of each pair.
  // We only need to overdraw the UPPER crossing with the left ring.
  static const _pairs = [
    (0, 1), // Blue   – Yellow : upper → Blue   in front
    (1, 2), // Yellow – Black  : upper → Yellow in front
    (2, 3), // Black  – Green  : upper → Black  in front
    (3, 4), // Green  – Red    : upper → Green  in front
  ];

  // ── Helpers ────────────────────────────────────────────────────────────────

  Offset _c(int i) => Offset(_cx[i], _cy[i]);

  Paint _stroke(Color c) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = _sw
    ..strokeCap = StrokeCap.butt
    ..color = c;

  /// Full circle when complete; growing clockwise arc during animation.
  void _drawRing(Canvas canvas, int i, double p) {
    if (p <= 0) return;
    if (p >= 1.0) {
      canvas.drawCircle(_c(i), _r, _stroke(_colors[i]));
    } else {
      canvas.drawArc(
        Rect.fromCircle(center: _c(i), radius: _r),
        -math.pi / 2,
        p * 2 * math.pi,
        false,
        _stroke(_colors[i]),
      );
    }
  }

  /// Tiny arc of ring [ri] centred at [centerAngle] — used to bring the left
  /// ring in front at the upper crossing without erasing anything.
  void _crossArc(Canvas canvas, int ri, double centerAngle) {
    const halfSpan = 0.22; // ~12.5° — enough to cover the crossing cleanly
    canvas.drawArc(
      Rect.fromCircle(center: _c(ri), radius: _r),
      centerAngle - halfSpan,
      halfSpan * 2,
      false,
      _stroke(_colors[ri]),
    );
  }

  /// Clockwise angular distance from [start] to [end] (both in radians).
  /// All rings draw clockwise from -π/2; this gives how far they must sweep
  /// before their arc geometrically reaches a given angle.
  static double _cwSweep(double start, double end) => (end - start + 2 * math.pi) % (2 * math.pi);

  /// True if a ring with progress [p] (0–1) has drawn its arc past [angle].
  /// Rings start at -π/2 and grow clockwise.
  static bool _arcReached(double p, double angle) {
    if (p >= 1.0) return true;
    return p * 2 * math.pi >= _cwSweep(-math.pi / 2, angle);
  }

  // ── Main paint ─────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / _w, size.height / _h);
    canvas.translate((size.width - _w * scale) / 2, (size.height - _h * scale) / 2);
    canvas.scale(scale);

    // Glow behind everything
    if (allDone) {
      for (int i = 0; i < 5; i++) {
        canvas.drawCircle(
          _c(i),
          _r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = _sw + 8
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
            ..color = _colors[i].withValues(alpha: 0.18 * glow),
        );
      }
    }

    // ── Step 1: Draw ALL rings in order 0 → 4 ───────────────────────────────
    // No white fills, no erasure — every ring remains a complete visible circle.
    // Draw order makes the higher-indexed ring appear on top in the overlap
    // zone, which is exactly right for the LOWER crossing of each pair
    // (right ring should be in front at the lower crossing).
    for (int i = 0; i < 5; i++) {
      _drawRing(canvas, i, progresses[i]);
    }

    // ── Step 2: Correct the UPPER crossings only ────────────────────────────
    // At the upper crossing the LEFT ring (A) must be in front. By draw order
    // B ends up on top. We fix this by repainting A's arc at that crossing.
    //
    // The overdraw is applied as soon as BOTH arcs have physically reached the
    // upper crossing point — not just when the rings are fully complete.
    // This prevents B's growing arc from momentarily covering A during animation.
    for (final (a, b) in _pairs) {
      final pA = progresses[a];
      final pB = progresses[b];
      if (pA <= 0 || pB <= 0) continue; // neither ring visible yet

      final angA = _intersectAngles(_c(a), _c(b), _r);
      final angB = _intersectAngles(_c(b), _c(a), _r);
      if (angA == null || angB == null) continue;

      // angA[0] = upper crossing angle on ring A
      // angB[1] = upper crossing angle on ring B (same geometric point)
      final aAtCrossing = _arcReached(pA, angA[0]);
      final bAtCrossing = _arcReached(pB, angB[1]);

      // Only overdraw once both arcs are present at the crossing — if B's arc
      // hasn't reached the upper crossing yet, it isn't covering A there.
      if (aAtCrossing && bAtCrossing) {
        _crossArc(canvas, a, angA[0]);
      }
    }
  }

  @override
  bool shouldRepaint(_OlympicPainter old) => old.progresses != progresses || old.glow != glow || old.allDone != allDone;
}
