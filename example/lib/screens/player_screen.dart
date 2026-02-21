import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laminar/laminar.dart';

import 'gallery_screen.dart';

/// An interactive deep-dive player for a single composition.
///
/// Uses [LaminarController] to drive a [Composition] widget — demonstrating
/// that the same controller attached to a widget can also be driven from
/// outside the widget tree (e.g. from this screen's own UI controls).
class PlayerScreen extends StatefulWidget {
  final CompositionEntry entry;
  const PlayerScreen({super.key, required this.entry});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final LaminarController _ctrl;
  final List<String> _logs = [];

  CompositionEntry get e => widget.entry;

  @override
  void initState() {
    super.initState();
    _ctrl = LaminarController(durationInFrames: e.durationInFrames, fps: e.fps, loop: false);
    _ctrl.addListener(_onFrame);
    _logs.add(
      '✓ Composition "${e.id}" loaded — '
      '${e.durationInFrames} frames @ ${e.fps}fps',
    );
    _logs.add('✓ LaminarController created — durationInFrames: ${e.durationInFrames}');
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onFrame);
    _ctrl.dispose();
    super.dispose();
  }

  void _onFrame() => setState(() {});

  void _simulateRender() {
    _ctrl.stop();
    setState(() {
      _logs.clear();
      _logs.add('▶ renderMedia() started…');
    });
    int rendered = 0;
    Timer.periodic(const Duration(milliseconds: 60), (t) {
      rendered += 4;
      if (rendered >= e.durationInFrames) {
        rendered = e.durationInFrames;
        t.cancel();
        if (!mounted) return;
        setState(() {
          _logs.add('  ✓ ${e.durationInFrames}/${e.durationInFrames} frames — 100%');
          _logs.add('  ✓ Piped to FFmpeg → output_${e.id}.mp4');
          _logs.add('✅ Render complete in ${e.durationInFrames * 33}ms');
        });
      } else {
        final pct = (rendered / e.durationInFrames * 100).toStringAsFixed(0);
        if (!mounted) return;
        setState(() => _logs.add('  → $rendered/${e.durationInFrames} — $pct%'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeSec = _ctrl.frame / e.fps;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: e.accent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Text(e.title),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Row(
              children: [
                // ── Composition canvas ─────────────────────────────────────
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // The composition IS the widget — controller drives it.
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white12, width: 1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Composition<void>(
                                  id: e.id,
                                  width: 1920,
                                  height: 1080,
                                  fps: e.fps,
                                  durationInFrames: e.durationInFrames,
                                  defaultProps: null,
                                  serialize: (_) => {},
                                  component: (ctx, _) => e.composition,
                                  controller: _ctrl,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Scrubber — seeks via LaminarController
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: e.accent,
                            inactiveTrackColor: Colors.white12,
                            thumbColor: Colors.white,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                            trackHeight: 3,
                          ),
                          child: Slider(
                            value: _ctrl.frame.toDouble(),
                            min: 0,
                            max: (e.durationInFrames - 1).toDouble(),
                            onChanged: (v) => _ctrl.seekTo(v.round()),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Transport
                        Row(
                          children: [
                            _IconBtn(icon: Icons.stop_rounded, onTap: _ctrl.stop, color: Colors.white38),
                            const SizedBox(width: 6),
                            _IconBtn(icon: Icons.skip_previous_rounded, onTap: _ctrl.stepBack, color: Colors.white38),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: _ctrl.toggle,
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(color: e.accent, borderRadius: BorderRadius.circular(21)),
                                child: Icon(
                                  _ctrl.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            _IconBtn(icon: Icons.skip_next_rounded, onTap: _ctrl.stepForward, color: Colors.white38),
                            const SizedBox(width: 12),
                            Text(
                              '${timeSec.toStringAsFixed(2)}s  •  '
                              'F${_ctrl.frame.toString().padLeft(4, '0')}  •  '
                              '${_ctrl.status.name.toUpperCase()}',
                              style: const TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'monospace'),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: _simulateRender,
                              icon: const Icon(Icons.movie_creation_outlined, size: 15),
                              label: const Text('Simulate render'),
                              style: TextButton.styleFrom(
                                foregroundColor: e.accent,
                                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // ── Render log panel ─────────────────────────────────────
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
                            Icon(Icons.terminal, size: 13, color: e.accent),
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
          // ── Stats bar ───────────────────────────────────────────────────
          Container(
            color: const Color(0xFF0A0A12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 0,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _stat('frame', '${_ctrl.frame} / ${e.durationInFrames - 1}'),
                _div(),
                _stat('status', _ctrl.status.name),
                _div(),
                _stat('progress', '${(_ctrl.progress * 100).toStringAsFixed(1)}%'),
                _div(),
                _stat('fps', e.fps.toString()),
                _div(),
                SizedBox(
                  width: 100,
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: _ctrl.progress,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(e.accent),
                    ),
                  ),
                ),
              ],
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
            style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _div() =>
      Container(width: 1, height: 14, color: Colors.white12, margin: const EdgeInsets.symmetric(horizontal: 12));
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  const _IconBtn({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(17)),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

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
            style: TextStyle(color: color, fontSize: 10.5, fontFamily: 'monospace', height: 1.6),
          ),
        );
      },
    );
  }
}
