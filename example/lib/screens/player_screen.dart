import 'dart:async';
import 'package:flutter/material.dart';
import 'package:laminar/laminar.dart';
import 'gallery_screen.dart';

/// An interactive composition player — drives [CompositionProvider] with an
/// [AnimationController] to preview any composition frame-by-frame.
class PlayerScreen extends StatefulWidget {
  final CompositionEntry entry;
  const PlayerScreen({super.key, required this.entry});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  int _frame = 0;
  bool _playing = false;
  Timer? _timer;

  CompositionEntry get e => widget.entry;

  // Simulated progress stream events
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _logs.add('✓ Composition "${e.id}" loaded — '
        '${e.durationInFrames} frames @ ${e.fps}fps');
    _logs.add('✓ VideoConfig: ${e.durationInFrames ~/ e.fps}.'
        '${((e.durationInFrames % e.fps) * 1000 ~/ e.fps).toString().padLeft(3, '0')}s duration');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _play() {
    if (_playing) return;
    setState(() => _playing = true);
    // Advance one frame per (1000/fps) ms — real-time playback.
    final msPerFrame = (1000 / e.fps).round();
    _timer = Timer.periodic(Duration(milliseconds: msPerFrame), (_) {
      if (_frame >= e.durationInFrames - 1) {
        _pause();
        setState(() => _frame = e.durationInFrames - 1);
      } else {
        setState(() => _frame++);
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _playing = false);
  }

  void _stop() {
    _timer?.cancel();
    setState(() {
      _playing = false;
      _frame = 0;
    });
  }

  void _seekTo(int frame) {
    setState(() => _frame = frame.clamp(0, e.durationInFrames - 1));
  }

  void _simulateRender() {
    _stop();
    setState(() {
      _logs.clear();
      _logs.add('▶ renderMedia() started…');
    });
    // Simulate frame progress events
    int rendered = 0;
    Timer.periodic(const Duration(milliseconds: 60), (t) {
      rendered += 4;
      if (rendered >= e.durationInFrames) {
        rendered = e.durationInFrames;
        t.cancel();
        setState(() {
          _logs.add(
              '  ✓ ${e.durationInFrames}/${e.durationInFrames} frames — 100%');
          _logs.add('  ✓ Piped to FFmpeg → output_${e.id}.mp4');
          _logs.add('✅ Render complete in ${(e.durationInFrames * 33)}ms');
        });
      } else {
        final pct = (rendered / e.durationInFrames * 100).toStringAsFixed(0);
        setState(() {
          _logs.add('  → $rendered/${e.durationInFrames} frames — $pct%');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double progress = e.durationInFrames > 1
        ? _frame / (e.durationInFrames - 1)
        : 0.0;
    final double timeSec = _frame / e.fps;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: e.accent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(e.title),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Preview canvas ────────────────────────────────────────────────
          Expanded(
            flex: 6,
            child: Row(
              children: [
                // Composition preview (16:9)
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Canvas
                        Expanded(
                          child: _CompositionCanvas(
                            entry: e,
                            frame: _frame,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Playhead scrubber
                        _Scrubber(
                          frame: _frame,
                          totalFrames: e.durationInFrames,
                          accent: e.accent,
                          onChanged: _seekTo,
                        ),
                        const SizedBox(height: 8),
                        // Transport controls
                        _TransportBar(
                          playing: _playing,
                          accent: e.accent,
                          frame: _frame,
                          totalFrames: e.durationInFrames,
                          timeSec: timeSec,
                          fps: e.fps,
                          onPlay: _play,
                          onPause: _pause,
                          onStop: _stop,
                          onRender: _simulateRender,
                        ),
                      ],
                    ),
                  ),
                ),
                // ── Render log panel ───────────────────────────────────────
                Container(
                  width: 260,
                  margin: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                        child: Row(
                          children: [
                            Icon(Icons.terminal,
                                size: 13, color: e.accent),
                            const SizedBox(width: 6),
                            const Text(
                              'Render Console',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 1, color: Colors.white10),
                      Expanded(
                        child: _RenderLog(logs: _logs, accent: e.accent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Stats bar ─────────────────────────────────────────────────────
          _StatsBar(
            frame: _frame,
            totalFrames: e.durationInFrames,
            fps: e.fps,
            progress: progress,
            accent: e.accent,
          ),
        ],
      ),
    );
  }
}

// ── Canvas ────────────────────────────────────────────────────────────────────

class _CompositionCanvas extends StatelessWidget {
  final CompositionEntry entry;
  final int frame;

  const _CompositionCanvas({required this.entry, required this.frame});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white12, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: CompositionProvider(
            config: VideoConfig(
              id: entry.id,
              width: 1920,
              height: 1080,
              fps: entry.fps,
              durationInFrames: entry.durationInFrames,
            ),
            frame: frame,
            child: entry.composition,
          ),
        ),
      ),
    );
  }
}

// ── Scrubber ─────────────────────────────────────────────────────────────────

class _Scrubber extends StatelessWidget {
  final int frame;
  final int totalFrames;
  final Color accent;
  final ValueChanged<int> onChanged;

  const _Scrubber({
    required this.frame,
    required this.totalFrames,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: accent,
        inactiveTrackColor: Colors.white12,
        thumbColor: Colors.white,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        trackHeight: 3,
      ),
      child: Slider(
        value: frame.toDouble(),
        min: 0,
        max: (totalFrames - 1).toDouble(),
        onChanged: (v) => onChanged(v.round()),
      ),
    );
  }
}

// ── Transport bar ─────────────────────────────────────────────────────────────

class _TransportBar extends StatelessWidget {
  final bool playing;
  final Color accent;
  final int frame;
  final int totalFrames;
  final double timeSec;
  final int fps;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStop;
  final VoidCallback onRender;

  const _TransportBar({
    required this.playing,
    required this.accent,
    required this.frame,
    required this.totalFrames,
    required this.timeSec,
    required this.fps,
    required this.onPlay,
    required this.onPause,
    required this.onStop,
    required this.onRender,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Stop
        _IconBtn(
          icon: Icons.stop_rounded,
          onTap: onStop,
          color: Colors.white38,
        ),
        const SizedBox(width: 6),
        // Play / Pause
        GestureDetector(
          onTap: playing ? onPause : onPlay,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(21),
            ),
            child: Icon(
              playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Timecode
        Text(
          '${timeSec.toStringAsFixed(2)}s  •  F${frame.toString().padLeft(4, '0')}',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
        const Spacer(),
        // Render button
        TextButton.icon(
          onPressed: onRender,
          icon: const Icon(Icons.movie_creation_outlined, size: 15),
          label: const Text('Simulate render'),
          style: TextButton.styleFrom(
            foregroundColor: accent,
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _IconBtn(
      {required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

// ── Stats bar ─────────────────────────────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  final int frame;
  final int totalFrames;
  final int fps;
  final double progress;
  final Color accent;

  const _StatsBar({
    required this.frame,
    required this.totalFrames,
    required this.fps,
    required this.progress,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      color: const Color(0xFF0A0A12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _stat('Frame', '$frame / ${totalFrames - 1}'),
          _div(),
          _stat('FPS', fps.toString()),
          _div(),
          _stat('Progress', '${(progress * 100).toStringAsFixed(1)}%'),
          _div(),
          _stat('useCurrentFrame()', 'returns $frame'),
          _div(),
          _stat('CompositionProvider', 'InheritedWidget ✓'),
          const Spacer(),
          Container(
            width: 100,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              widthFactor: progress,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(color: Colors.white30, fontSize: 11),
          ),
          TextSpan(
            text: value,
            style:
                const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _div() => Container(
        width: 1,
        height: 14,
        color: Colors.white12,
        margin: const EdgeInsets.symmetric(horizontal: 12),
      );
}

// ── Render log ────────────────────────────────────────────────────────────────

class _RenderLog extends StatefulWidget {
  final List<String> logs;
  final Color accent;

  const _RenderLog({required this.logs, required this.accent});

  @override
  State<_RenderLog> createState() => _RenderLogState();
}

class _RenderLogState extends State<_RenderLog> {
  final _scroll = ScrollController();

  @override
  void didUpdateWidget(_RenderLog old) {
    super.didUpdateWidget(old);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.all(10),
      itemCount: widget.logs.length,
      itemBuilder: (_, i) {
        final line = widget.logs[i];
        Color color = Colors.white38;
        if (line.startsWith('✅')) color = Colors.greenAccent;
        if (line.startsWith('▶')) color = widget.accent;
        if (line.startsWith('✓')) color = Colors.white70;
        return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(
            line,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontFamily: 'monospace',
              height: 1.6,
            ),
          ),
        );
      },
    );
  }
}
