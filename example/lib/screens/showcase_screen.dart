import 'package:flutter/material.dart';
import 'package:laminar/laminar.dart';

import '../compositions/apple_logo_composition.dart';
import '../compositions/counter_composition.dart';
import '../compositions/fade_title_composition.dart';
import '../compositions/series_demo_composition.dart';
import '../compositions/starbucks_logo_composition.dart';
import '../compositions/wave_composition.dart';
import '../screens/gallery_screen.dart';

/// The main showcase screen — demonstrates compositions embedded as regular
/// Flutter widgets, with no player screen required.
///
/// Each [Composition] below is just a widget. It drives itself.
class ShowcaseScreen extends StatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  // External controllers — you own them, just like AnimationController.
  late final LaminarController _heroCtrl;
  late final LaminarController _counterCtrl;
  late final LaminarController _waveCtrl;
  late final LaminarController _seriesCtrl;
  late final LaminarController _appleCtrl;
  late final LaminarController _starbucksCtrl;

  @override
  void initState() {
    super.initState();
    _heroCtrl = LaminarController(durationInFrames: 90, fps: 30, loop: true)..play();
    _counterCtrl = LaminarController(durationInFrames: 120, fps: 30, loop: true)..play();
    _waveCtrl = LaminarController(durationInFrames: 90, fps: 30, loop: true)..play();
    _seriesCtrl = LaminarController(durationInFrames: 150, fps: 30, loop: true)..play();
    _appleCtrl = LaminarController(durationInFrames: 150, fps: 30, loop: true)..play();
    _starbucksCtrl = LaminarController(durationInFrames: 150, fps: 30, loop: true)..play();
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _counterCtrl.dispose();
    _waveCtrl.dispose();
    _seriesCtrl.dispose();
    _appleCtrl.dispose();
    _starbucksCtrl.dispose();
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
            const Text('Laminar as Flutter Widgets'),
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
        padding: const EdgeInsets.all(24),
        children: [
          // ── Section header ─────────────────────────────────────────────────
          _SectionHeader(
            label: 'Drop-in anywhere',
            sub: 'Each Composition<T> is a regular widget. No player, no scaffold.',
          ),
          const SizedBox(height: 16),

          // ── Hero: full-width banner ────────────────────────────────────────
          _CompositionCard(
            title: 'Hero Banner',
            subtitle: 'Full-width, 16:9, looping — inside a plain Card',
            accent: const Color(0xFF6C63FF),
            ctrl: _heroCtrl,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Composition<void>(
                id: 'hero-banner',
                width: 1920,
                height: 1080,
                fps: 30,
                durationInFrames: 90,
                defaultProps: null,
                serialize: (_) => {},
                component: (ctx, _) => const FadeTitleComposition(),
                controller: _heroCtrl,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Side-by-side smaller compositions ─────────────────────────────
          _SectionHeader(
            label: 'Compose alongside other widgets',
            sub: 'Two compositions as peers in a Row — just like any widget.',
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _CompositionCard(
                  title: 'Counter',
                  subtitle: 'LaminarController shared externally',
                  accent: const Color(0xFF00C9A7),
                  ctrl: _counterCtrl,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Composition<void>(
                      id: 'counter',
                      width: 600,
                      height: 600,
                      fps: 30,
                      durationInFrames: 120,
                      defaultProps: null,
                      serialize: (_) => {},
                      component: (ctx, _) => const CounterComposition(),
                      controller: _counterCtrl,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _CompositionCard(
                  title: 'Wave',
                  subtitle: 'autoPlay: true, no controller needed',
                  accent: const Color(0xFFFF6584),
                  ctrl: _waveCtrl,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Composition<void>(
                      id: 'wave',
                      width: 600,
                      height: 600,
                      fps: 30,
                      durationInFrames: 90,
                      defaultProps: null,
                      serialize: (_) => {},
                      component: (ctx, _) => const WaveComposition(),
                      controller: _waveCtrl,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Series demo with explicit controller ───────────────────────────
          _SectionHeader(
            label: 'Series — temporal scene chaining',
            sub: 'Composition<T> uses Series/Sequence internally. External controller drives all scenes.',
          ),
          const SizedBox(height: 16),

          _CompositionCard(
            title: 'Series Demo',
            subtitle: 'Intro → API List → Outro — driven by one LaminarController',
            accent: const Color(0xFFFFBE0B),
            ctrl: _seriesCtrl,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Composition<void>(
                id: 'series-demo',
                width: 1920,
                height: 1080,
                fps: 30,
                durationInFrames: 150,
                defaultProps: null,
                serialize: (_) => {},
                component: (ctx, _) => const SeriesDemoComposition(),
                controller: _seriesCtrl,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Apple Logo — 5 s looping showcase ─────────────────────────────
          _SectionHeader(
            label: '🍎 Apple Logo — 5 s',
            sub: 'Faithful silhouette with bite • rainbow shimmer • pulsing glow',
          ),
          const SizedBox(height: 16),
          _CompositionCard(
            title: 'Apple Logo',
            subtitle: 'Rainbow shimmer + glow pulse — 150 frames @ 30 fps',
            accent: const Color(0xFFE0E0E0),
            ctrl: _appleCtrl,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Composition<void>(
                id: 'apple-logo',
                width: 1920,
                height: 1080,
                fps: 30,
                durationInFrames: 150,
                defaultProps: null,
                serialize: (_) => {},
                component: (ctx, _) => const AppleLogoComposition(),
                controller: _appleCtrl,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Starbucks Logo — 5 s ──────────────────────────────────
          _SectionHeader(label: '☕ Starbucks Logo — 5 s', sub: 'Exact SVG path • slow rotation • green glow pulse'),
          const SizedBox(height: 16),
          _CompositionCard(
            title: 'Starbucks Logo',
            subtitle: 'Official SVG paths — 150 frames @ 30 fps',
            accent: const Color(0xFF1E3932),
            ctrl: _starbucksCtrl,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Composition<void>(
                id: 'starbucks-logo',
                width: 1920,
                height: 1080,
                fps: 30,
                durationInFrames: 150,
                defaultProps: null,
                serialize: (_) => {},
                component: (ctx, _) => const StarbucksLogoComposition(),
                controller: _starbucksCtrl,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Mini-embed: composition inside a profile card ─────────────────
          _SectionHeader(
            label: 'Inside existing UI',
            sub: 'A composition embedded inside a profile card — just a widget.',
          ),
          const SizedBox(height: 16),
          _ProfileCardDemo(waveCtrl: _waveCtrl),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final String sub;
  const _SectionHeader({required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.4),
        ),
        const SizedBox(height: 3),
        Text(sub, style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 13)),
      ],
    );
  }
}

/// A card wrapper that adds a title, subtitle, and playback micro-controls.
class _CompositionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color accent;
  final LaminarController ctrl;
  final Widget child;

  const _CompositionCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.ctrl,
    required this.child,
  });

  @override
  State<_CompositionCard> createState() => _CompositionCardState();
}

class _CompositionCardState extends State<_CompositionCard> {
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

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF17172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Composition viewport
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: widget.child,
          ),
          // Control bar
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + status
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            widget.subtitle,
                            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    _StatusBadge(status: ctrl.status, accent: widget.accent),
                  ],
                ),
                const SizedBox(height: 10),
                // Progress bar (tap-to-seek)
                _SeekBar(ctrl: ctrl, accent: widget.accent),
                const SizedBox(height: 8),
                // Transport row
                Row(
                  children: [
                    _TransportBtn(icon: Icons.skip_previous_rounded, onTap: ctrl.stop, color: Colors.white30),
                    const SizedBox(width: 6),
                    _TransportBtn(icon: Icons.navigate_before_rounded, onTap: ctrl.stepBack, color: Colors.white30),
                    const SizedBox(width: 6),
                    // Play / Pause
                    GestureDetector(
                      onTap: ctrl.toggle,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(color: widget.accent, borderRadius: BorderRadius.circular(17)),
                        child: Icon(
                          ctrl.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _TransportBtn(icon: Icons.navigate_next_rounded, onTap: ctrl.stepForward, color: Colors.white30),
                    const Spacer(),
                    // Frame counter
                    Text(
                      'F${ctrl.frame.toString().padLeft(4, '0')} / ${ctrl.durationInFrames}',
                      style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'monospace'),
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

class _StatusBadge extends StatelessWidget {
  final PlaybackStatus status;
  final Color accent;
  const _StatusBadge({required this.status, required this.accent});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      PlaybackStatus.playing => ('● PLAYING', accent),
      PlaybackStatus.paused => ('⏸ PAUSED', Colors.white38),
      PlaybackStatus.finished => ('■ DONE', Colors.white38),
      PlaybackStatus.idle => ('○ IDLE', Colors.white24),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.8),
      ),
    );
  }
}

class _SeekBar extends StatelessWidget {
  final LaminarController ctrl;
  final Color accent;
  const _SeekBar({required this.ctrl, required this.accent});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
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
            height: 4,
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

class _TransportBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  const _TransportBtn({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(15)),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}

/// A mock profile card that contains a live composition as its avatar.
class _ProfileCardDemo extends StatelessWidget {
  final LaminarController waveCtrl;
  const _ProfileCardDemo({required this.waveCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF17172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Composition as the "avatar"
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: SizedBox(
              width: 80,
              height: 80,
              child: Composition<void>(
                id: 'avatar-wave',
                width: 400,
                height: 400,
                fps: 30,
                durationInFrames: 90,
                defaultProps: null,
                serialize: (_) => {},
                component: (ctx, _) => const WaveComposition(),
                // Share a controller — same playback state as the wave card above
                controller: waveCtrl,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Normal Flutter widgets alongside
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Laminar Widget',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Composition embedded inside a Row, no player needed.',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6584).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFF6584).withOpacity(0.4)),
                      ),
                      child: const Text(
                        '✦ flutter widget',
                        style: TextStyle(color: Color(0xFFFF6584), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.4)),
                      ),
                      child: const Text(
                        '✦ self-animating',
                        style: TextStyle(color: Color(0xFF6C63FF), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
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
