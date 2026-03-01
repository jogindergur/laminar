import 'package:flutter/material.dart';
import 'package:laminar/laminar.dart';

/// Demo 4: Three scenes chained with [Series].
///
/// Scene 1 (frames  0–49):  Intro card
/// Scene 2 (frames 50–109):  Main content
/// Scene 3 (frames 110–149): Outro card
///
/// All scenes wrap their content in [FittedBox] so fixed-pixel children scale
/// down cleanly when the composition is rendered at small sizes.
class SeriesDemoComposition extends StatelessWidget {
  const SeriesDemoComposition({super.key});

  @override
  Widget build(BuildContext context) {
    return const Series(
      sequences: [
        SeriesSequence(durationInFrames: 50, child: _IntroScene()),
        SeriesSequence(durationInFrames: 60, child: _MainScene()),
        SeriesSequence(durationInFrames: 40, child: _OutroScene()),
      ],
    );
  }
}

// ── Scene 1: Intro ─────────────────────────────────────────────────────────────

class _IntroScene extends StatelessWidget {
  const _IntroScene();

  @override
  Widget build(BuildContext context) {
    final frame = useCurrentFrame(context);

    final slide = interpolate(
      frame,
      [0, 25],
      [-60.0, 0.0],
      easing: LaminarEasing.easeOutCubic,
      extrapolateRight: Extrapolate.clamp,
    );

    final opacity = interpolate(
      frame,
      [0, 20],
      [0.0, 1.0],
      easing: LaminarEasing.easeOutCubic,
      extrapolateRight: Extrapolate.clamp,
    );

    return Container(
      color: const Color(0xFF0E0519),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, slide),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFBE0B).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFBE0B).withValues(alpha: 0.5), width: 2),
                      ),
                      child: const Icon(Icons.movie_filter_outlined, color: Color(0xFFFFBE0B), size: 28),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'SERIES DEMO',
                      style: TextStyle(
                        color: Color(0xFFFFBE0B),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Introduction',
                      style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'frame $frame / 50  •  Scene 1 of 3',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Scene 2: Main ──────────────────────────────────────────────────────────────

class _MainScene extends StatelessWidget {
  const _MainScene();

  static const _bullets = [
    ('Composition<T>', 'Declarative scene registration'),
    ('CompositionProvider', 'InheritedWidget context — no React!'),
    ('Series + Sequence', 'Temporal composition primitives'),
    ('interpolate()', 'Frame → value mapping with easing'),
    ('MediaRenderer', 'Isolate-based parallel rendering'),
  ];

  @override
  Widget build(BuildContext context) {
    final frame = useCurrentFrame(context);

    return Container(
      color: const Color(0xFF0D0D12),
      // FittedBox lets the fixed-size content shrink when the viewport is small
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 520,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Laminar API',
                  style: TextStyle(
                    color: Color(0xFF00C9A7),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Core Primitives',
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 20),
                ..._bullets.asMap().entries.map((entry) {
                  final i = entry.key;
                  final (api, desc) = entry.value;

                  final delay = i * 8;
                  final itemOpacity = interpolate(
                    frame,
                    [delay, delay + 15],
                    [0.0, 1.0],
                    easing: LaminarEasing.easeOutCubic,
                    extrapolateLeft: Extrapolate.clamp,
                    extrapolateRight: Extrapolate.clamp,
                  );
                  final itemSlide = interpolate(
                    frame,
                    [delay, delay + 15],
                    [20.0, 0.0],
                    easing: LaminarEasing.easeOutCubic,
                    extrapolateLeft: Extrapolate.clamp,
                    extrapolateRight: Extrapolate.clamp,
                  );

                  return Opacity(
                    opacity: itemOpacity,
                    child: Transform.translate(
                      offset: Offset(itemSlide, 0),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(color: Color(0xFF00C9A7), shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              api,
                              style: const TextStyle(
                                color: Color(0xFF00C9A7),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '— $desc',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Text(
                  'frame $frame / 60  •  Scene 2 of 3',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Scene 3: Outro ─────────────────────────────────────────────────────────────

class _OutroScene extends StatelessWidget {
  const _OutroScene();

  @override
  Widget build(BuildContext context) {
    final frame = useCurrentFrame(context);

    final scale = interpolate(
      frame,
      [0, 20],
      [1.15, 1.0],
      easing: LaminarEasing.easeOutCubic,
      extrapolateRight: Extrapolate.clamp,
    );

    final opacity = interpolate(
      frame,
      [0, 15, 30, 40],
      [0.0, 1.0, 1.0, 0.0],
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D0520), Color(0xFF050D1A)],
        ),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) =>
                          const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF6584)]).createShader(bounds),
                      child: const Text(
                        'laminar',
                        style: TextStyle(fontSize: 52, fontWeight: FontWeight.w900, letterSpacing: -2),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Programmatic video. Pure Flutter.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 15, letterSpacing: 0.3),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'frame $frame / 40  •  Scene 3 of 3',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
