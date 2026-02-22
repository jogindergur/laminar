import 'package:flutter/material.dart';

import '../compositions/apple_logo_composition.dart';
import '../compositions/counter_composition.dart';
import '../compositions/fade_title_composition.dart';
import '../compositions/olympic_logo_composition.dart';
import '../compositions/series_demo_composition.dart';
import '../compositions/starbucks_logo_composition.dart';
import '../compositions/wave_composition.dart';
import 'player_screen.dart';

/// A composition entry shown in the gallery.
class CompositionEntry {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final Widget composition;
  final int durationInFrames;
  final int fps;

  const CompositionEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.composition,
    required this.durationInFrames,
    required this.fps,
  });
}

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  static final _compositions = <CompositionEntry>[
    CompositionEntry(
      id: 'fade-title',
      title: 'Fade Title',
      description: 'Uses interpolate() + LaminarEasing.easeOutCubic to animate opacity and scale.',
      icon: Icons.title,
      accent: const Color(0xFF6C63FF),
      composition: const FadeTitleComposition(),
      durationInFrames: 90,
      fps: 30,
    ),
    CompositionEntry(
      id: 'counter',
      title: 'Animated Counter',
      description: 'Counts from 0–100 over 120 frames with a spring-like ease-out.',
      icon: Icons.pin,
      accent: const Color(0xFF00C9A7),
      composition: const CounterComposition(),
      durationInFrames: 120,
      fps: 30,
    ),
    CompositionEntry(
      id: 'wave',
      title: 'Audio Wave',
      description: 'A procedural wave visualiser driven entirely by useCurrentFrame().',
      icon: Icons.graphic_eq,
      accent: const Color(0xFFFF6584),
      composition: const WaveComposition(),
      durationInFrames: 90,
      fps: 30,
    ),
    CompositionEntry(
      id: 'series-demo',
      title: 'Series Scenes',
      description: 'Three scenes chained with Series — Intro → Main → Outro.',
      icon: Icons.movie_filter,
      accent: const Color(0xFFFFBE0B),
      composition: const SeriesDemoComposition(),
      durationInFrames: 150,
      fps: 30,
    ),
    CompositionEntry(
      id: 'apple-logo',
      title: '🍎 Apple Logo',
      description: 'The iconic Apple logo drawn with a custom SVG path, animated with a pulsing glow.',
      icon: Icons.apple,
      accent: const Color(0xFFE0E0E0),
      composition: const AppleLogoComposition(),
      durationInFrames: 150,
      fps: 30,
    ),
    CompositionEntry(
      id: 'starbucks-logo',
      title: '☕ Starbucks Logo',
      description: 'Starbucks siren silhouette traced from the official SVG with rotation and glow animation.',
      icon: Icons.local_cafe,
      accent: const Color(0xFF00A862),
      composition: const StarbucksLogoComposition(),
      durationInFrames: 150,
      fps: 30,
    ),
    CompositionEntry(
      id: 'olympic-rings',
      title: '🏅 Olympic Rings',
      description: '5 rings draw themselves in sequence with authentic over/under interlocking weave.',
      icon: Icons.sports_gymnastics,
      accent: const Color(0xFF0085C7),
      composition: const OlympicLogoComposition(),
      durationInFrames: 150,
      fps: 30,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF6584)]),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            const Text('Laminar Demo Gallery'),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.white10),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header blurb
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Text(
              'Select a composition to preview it frame-by-frame.',
              style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13, letterSpacing: 0.2),
            ),
          ),
          const SizedBox(height: 8),
          // Grid of composition cards
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 360,
                mainAxisExtent: 200,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: _compositions.length,
              itemBuilder: (context, i) => _CompositionCard(entry: _compositions[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompositionCard extends StatefulWidget {
  final CompositionEntry entry;
  const _CompositionCard({required this.entry});

  @override
  State<_CompositionCard> createState() => _CompositionCardState();
}

class _CompositionCardState extends State<_CompositionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlayerScreen(entry: e))),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..translate(0.0, _hovered ? -4.0 : 0.0),
          decoration: BoxDecoration(
            color: const Color(0xFF17172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _hovered ? e.accent.withOpacity(0.7) : Colors.white10, width: 1.5),
            boxShadow: _hovered
                ? [BoxShadow(color: e.accent.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 10))]
                : [],
          ),
          child: ClipRect(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon badge
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: e.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(e.icon, color: e.accent, size: 22),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    e.title,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Flexible(
                    child: Text(
                      e.description,
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, height: 1.5),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _Pill(label: '${(e.durationInFrames / e.fps).toStringAsFixed(1)}s'),
                      _Pill(label: '${e.fps}fps'),
                      _Pill(label: '${e.durationInFrames}f'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}
