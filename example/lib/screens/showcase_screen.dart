import 'package:flutter/material.dart';
import 'package:laminar/laminar.dart';

import '../compositions/apple_logo_composition.dart';
import '../compositions/counter_composition.dart';
import '../compositions/fade_title_composition.dart';
import '../compositions/olympic_logo_composition.dart';
import '../compositions/starbucks_logo_composition.dart';
import '../compositions/trend_chart_composition.dart';
import '../compositions/wave_composition.dart';
import '../screens/gallery_screen.dart';

/// ShowcaseScreen — each composition is shown twice, side-by-side:
///   LEFT  → bare widget (no player, no chrome)
///   RIGHT → same widget wrapped in a player card (seek, play/pause, transport)
///
/// Both sides share one [LaminarController], so they're always in sync.
class ShowcaseScreen extends StatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  late final LaminarController _heroCtrl;
  late final LaminarController _counterCtrl;
  late final LaminarController _waveCtrl;
  late final LaminarController _seriesCtrl;
  late final LaminarController _appleCtrl;
  late final LaminarController _starbucksCtrl;
  late final LaminarController _olympicCtrl;
  late final LaminarController _trendCtrl;

  @override
  void initState() {
    super.initState();
    _heroCtrl = LaminarController()..play();
    _counterCtrl = LaminarController()..play();
    _waveCtrl = LaminarController()..play();
    _seriesCtrl = LaminarController()..play();
    _appleCtrl = LaminarController()..play();
    _starbucksCtrl = LaminarController()..play();
    _olympicCtrl = LaminarController()..play();
    _trendCtrl = LaminarController()..play();
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _counterCtrl.dispose();
    _waveCtrl.dispose();
    _seriesCtrl.dispose();
    _appleCtrl.dispose();
    _starbucksCtrl.dispose();
    _olympicCtrl.dispose();
    _trendCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D12),
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF6584)]),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.widgets_rounded, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 10),
            const Text('Showcase'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GalleryScreen())),
            icon: const Icon(Icons.grid_view_rounded, size: 15),
            label: const Text('Gallery'),
            style: TextButton.styleFrom(foregroundColor: Colors.white54),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.white10),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // ── Column headers ─────────────────────────────────────────────────
          _ColumnHeaders(),
          const SizedBox(height: 20),

          // ── Hero Banner ────────────────────────────────────────────────────
          _DualRow(
            label: 'Hero Banner',
            sub: 'FadeTitleComposition · 16:9 · 90f @ 30fps',
            accent: const Color(0xFF6C63FF),
            aspectRatio: 16 / 9,
            ctrl: _heroCtrl,
            config: const VideoConfig(id: 'hero-banner', width: 1920, height: 1080, fps: 30, durationInFrames: 90),
            child: const FadeTitleComposition(),
          ),

          const SizedBox(height: 28),

          // ── Audio Wave ─────────────────────────────────────────────────────
          _DualRow(
            label: 'Audio Wave',
            sub: 'WaveComposition · 1:1 · 90f @ 30fps',
            accent: const Color(0xFFFF6584),
            aspectRatio: 1,
            ctrl: _waveCtrl,
            config: const VideoConfig(id: 'wave', width: 600, height: 600, fps: 30, durationInFrames: 90),
            child: const WaveComposition(),
          ),

          const SizedBox(height: 28),

          // ── Apple Logo ─────────────────────────────────────────────────────
          _DualRow(
            label: '🍎 Apple Logo',
            sub: 'AppleLogoComposition · 16:9 · 150f @ 30fps',
            accent: const Color(0xFFE0E0E0),
            aspectRatio: 16 / 9,
            ctrl: _appleCtrl,
            config: const VideoConfig(id: 'apple-logo', width: 1920, height: 1080, fps: 30, durationInFrames: 150),
            child: const AppleLogoComposition(),
          ),

          const SizedBox(height: 28),

          // ── Series Demo ────────────────────────────────────────────────────
          // _DualRow(
          //   label: 'Series Demo',
          //   sub: 'SeriesDemoComposition · 16:9 · 150f @ 30fps',
          //   accent: const Color(0xFFFFBE0B),
          //   aspectRatio: 16 / 9,
          //   ctrl: _seriesCtrl,
          //   config: const VideoConfig(id: 'series-demo', width: 1920, height: 1080, fps: 30, durationInFrames: 150),
          //   child: const SeriesDemoComposition(),
          // ),

          // const SizedBox(height: 28),

          // ── Starbucks Logo ─────────────────────────────────────────────────
          _DualRow(
            label: '☕ Starbucks Logo',
            sub: 'StarbucksLogoComposition · 16:9 · 150f @ 30fps',
            accent: const Color(0xFF00A862),
            aspectRatio: 16 / 9,
            ctrl: _starbucksCtrl,
            config: const VideoConfig(id: 'starbucks-logo', width: 1920, height: 1080, fps: 30, durationInFrames: 150),
            child: const StarbucksLogoComposition(),
          ),

          // ── Olympic Rings ──────────────────────────────────────────────────
          _DualRow(
            label: '🏅 Olympic Rings',
            sub: 'OlympicLogoComposition · 16:9 · 150f @ 30fps — rings draw themselves',
            accent: const Color(0xFF0085C7),
            aspectRatio: 16 / 9,
            ctrl: _olympicCtrl,
            config: const VideoConfig(id: 'olympic-rings', width: 1920, height: 1080, fps: 30, durationInFrames: 150),
            child: const OlympicLogoComposition(),
          ),

          const SizedBox(height: 28),

          // ── Trend Line Chart ───────────────────────────────────────────────
          _DualRow(
            label: '📈 Trend Line Chart',
            sub: 'TrendChartComposition · 16:9 · 150f @ 30fps — multi-series animated chart',
            accent: const Color(0xFF6C63FF),
            aspectRatio: 16 / 9,
            ctrl: _trendCtrl,
            config: const VideoConfig(id: 'trend-chart', width: 1920, height: 1080, fps: 30, durationInFrames: 150),
            child: const TrendChartComposition(),
          ),

          const SizedBox(height: 40),

          // ── Animated Counter ───────────────────────────────────────────────
          _DualRow(
            label: 'Animated Counter',
            sub: 'CounterComposition · 1:1 · 120f @ 30fps',
            accent: const Color(0xFF00C9A7),
            aspectRatio: 1,
            ctrl: _counterCtrl,
            config: const VideoConfig(id: 'counter', width: 600, height: 600, fps: 30, durationInFrames: 120),
            child: const CounterComposition(),
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ── Column headers ─────────────────────────────────────────────────────────────

class _ColumnHeaders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _HeaderChip('Without Player', Colors.white24, Icons.block)),
        const SizedBox(width: 14),
        Expanded(child: _HeaderChip('With Player', const Color(0xFF6C63FF), Icons.play_circle_outline_rounded)),
      ],
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _HeaderChip(this.label, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Dual row ───────────────────────────────────────────────────────────────────

/// Shows one composition in two columns — bare left, player card right.
/// Both share [ctrl] so they stay perfectly in sync.
class _DualRow extends StatelessWidget {
  final String label;
  final String sub;
  final Color accent;
  final double aspectRatio;
  final LaminarController ctrl;
  final VideoConfig config;
  final Widget child;

  const _DualRow({
    required this.label,
    required this.sub,
    required this.accent,
    required this.aspectRatio,
    required this.ctrl,
    required this.config,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final comp = Composition<void>(
      config: config,
      defaultProps: null,
      serialize: (_) => {},
      component: (ctx, _) => child,
      controller: ctrl,
      loop: true,
    );

    // The "with-player" version uses a separate id to avoid key collisions
    final playerConfig = config.copyWith(id: '${config.id}-player');
    final compPlayer = Composition<void>(
      config: playerConfig,
      defaultProps: null,
      serialize: (_) => {},
      component: (ctx, _) => child,
      controller: ctrl,
      loop: true,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.3),
        ),
        const SizedBox(height: 2),
        Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        const SizedBox(height: 10),

        // Two-column layout
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT — bare widget, no chrome
            Expanded(
              child: _BarePane(aspectRatio: aspectRatio, composition: comp),
            ),

            const SizedBox(width: 14),

            // RIGHT — player card with controls
            Expanded(
              child: _PlayerPane(accent: accent, aspectRatio: aspectRatio, ctrl: ctrl, composition: compPlayer),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Bare pane (left) ──────────────────────────────────────────────────────────

class _BarePane extends StatelessWidget {
  final double aspectRatio;
  final Widget composition;
  const _BarePane({required this.aspectRatio, required this.composition});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(aspectRatio: aspectRatio, child: composition),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.block, size: 10, color: Colors.white24),
            const SizedBox(width: 5),
            const Text(
              'Without Player, working as standalone widget.',
              style: TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.4),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Player pane (right) ───────────────────────────────────────────────────────

class _PlayerPane extends StatefulWidget {
  final double aspectRatio;
  final Color accent;
  final LaminarController ctrl;
  final Widget composition;
  const _PlayerPane({required this.aspectRatio, required this.accent, required this.ctrl, required this.composition});

  @override
  State<_PlayerPane> createState() => _PlayerPaneState();
}

class _PlayerPaneState extends State<_PlayerPane> {
  @override
  void initState() {
    super.initState();
    widget.ctrl.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.ctrl.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;
    final accent = widget.accent;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF17172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Composition viewport
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            child: AspectRatio(aspectRatio: widget.aspectRatio, child: widget.composition),
          ),

          // Controls
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Column(
              children: [
                // Seek bar
                _SeekBar(ctrl: ctrl, accent: accent),
                const SizedBox(height: 8),

                // Transport row
                Row(
                  children: [
                    // Rewind to start
                    _TBtn(icon: Icons.skip_previous_rounded, onTap: ctrl.stop, color: Colors.white30),
                    const SizedBox(width: 4),
                    // Step back
                    _TBtn(icon: Icons.navigate_before_rounded, onTap: ctrl.stepBack, color: Colors.white30),
                    const SizedBox(width: 4),
                    // Play / Pause
                    GestureDetector(
                      onTap: ctrl.toggle,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(15)),
                        child: Icon(
                          ctrl.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Step forward
                    _TBtn(icon: Icons.navigate_next_rounded, onTap: ctrl.stepForward, color: Colors.white30),
                    const Spacer(),
                    // Frame counter
                    Text(
                      'F${ctrl.frame.toString().padLeft(3, '0')}/${ctrl.durationInFrames}',
                      style: const TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Micro-widgets ─────────────────────────────────────────────────────────────

class _SeekBar extends StatelessWidget {
  final LaminarController ctrl;
  final Color accent;
  const _SeekBar({required this.ctrl, required this.accent});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return GestureDetector(
          onTapDown: (d) {
            final frac = d.localPosition.dx / constraints.maxWidth;
            ctrl.seekTo((frac * (ctrl.durationInFrames - 1)).round().clamp(0, ctrl.durationInFrames - 1));
          },
          onHorizontalDragUpdate: (d) {
            final frac = d.localPosition.dx / constraints.maxWidth;
            ctrl.seekTo((frac * (ctrl.durationInFrames - 1)).round().clamp(0, ctrl.durationInFrames - 1));
          },
          child: Container(
            height: 3,
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)),
            child: FractionallySizedBox(
              widthFactor: ctrl.progress,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2)),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  const _TBtn({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(13)),
        child: Icon(icon, color: color, size: 14),
      ),
    );
  }
}
