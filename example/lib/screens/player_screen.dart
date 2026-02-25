import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:laminar/laminar.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/export_mp4.dart';
import 'gallery_screen.dart';

enum ExportQuality {
  sd('SD (480p)', 854, 480),
  hd('HD (1080p)', 1920, 1080),
  qhd('2K (1440p)', 2560, 1440),
  uhd('4K (2160p)', 3840, 2160);

  final String label;
  final int width;
  final int height;

  const ExportQuality(this.label, this.width, this.height);
}

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

  // Repaint boundary key to capture frames
  final _compositionKey = GlobalKey();

  bool _isExporting = false;
  ExportQuality _selectedQuality = ExportQuality.hd;

  CompositionEntry get e => widget.entry;

  @override
  void initState() {
    super.initState();
    _ctrl = LaminarController();
    _ctrl.addListener(_onFrame);
    _logs.add(
      '✓ Composition "${e.id}" loaded — '
      '${e.durationInFrames} frames @ ${e.fps}fps',
    );
    _logs.add('✓ LaminarController created — waiting for attach...');
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onFrame);
    _ctrl.dispose();
    super.dispose();
  }

  void _onFrame() => setState(() {});

  Future<void> _exportMp4() async {
    if (_isExporting) return;
    _ctrl.stop();
    setState(() {
      _isExporting = true;
      _logs.clear();
      _logs.add('▶ Generating ${e.durationInFrames} frames…');
    });

    final exporter = LaminarMp4Exporter();

    try {
      final watch = Stopwatch()..start();

      await exporter.initialize(
        fps: e.fps,
        width: _selectedQuality.width,
        height: _selectedQuality.height,
        qualityName: _selectedQuality.name.toUpperCase(),
      );

      // 1. Generate frames by seeking and capturing RepaintBoundary
      for (int i = 0; i < e.durationInFrames; i++) {
        _ctrl.seekTo(i);
        // Yield momentarily to let Flutter flush the layout/paint pipeline out of the microtask queue.
        await Future.delayed(Duration.zero);

        final boundary = _compositionKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) throw Exception('RepaintBoundary not found');

        // Capture at selected quality resolution regardless of the UI's display size
        final double pixelRatio = boundary.size.width > 0
            ? _selectedQuality.width.toDouble() / boundary.size.width
            : 1.0;
        final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);

        // Use direct memory access to extract raw RGBA pixel data instead of CPU-expensive PNG compression
        final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        if (byteData == null) throw Exception('Failed to get byte data for frame $i');

        // 2. Send the raw RGBA buffer to the exporter
        // A 16ms yield here gives the Flutter UI engine a full timeslice to breathe and stay interactive.
        await exporter.addFrame(byteData.buffer.asUint8List());
        await Future.delayed(const Duration(milliseconds: 16));

        if (i % 5 == 0 && mounted) {
          setState(() {
            _logs.add('  → Captured & Encoded $i/${e.durationInFrames}');
          });
        }
      }

      watch.stop();
      if (!mounted) return;
      setState(() {
        _logs.add('✓ Frames captured in ${watch.elapsedMilliseconds}ms');
        _logs.add('▶ Formatting MP4 video...');
      });

      // 3. Finalize and assemble using FFmpeg natively
      final outputPath = await exporter.export((progress) {
        if (!mounted) return;
        final pct = (progress * 100).toStringAsFixed(1);
        setState(() => _logs.add('  → Encoding: $pct%'));
      });

      if (!mounted) return;
      setState(() {
        _logs.add('✅ Export complete!');
        if (!kIsWeb) {
          _logs.add('✓ Saved to: $outputPath');
        }
      });

      // 4. Offer to share/save the file natively (if not on web, since web downloads automatically)
      if (!kIsWeb) {
        // ignore: deprecated_member_use
        await Share.shareXFiles([XFile(outputPath)], text: 'Exported Laminar Video');
      }
    } catch (error, stack) {
      if (!mounted) return;
      setState(() {
        _logs.add('❌ Export failed');
        _logs.add(error.toString());
      });
      debugPrint('Export error: $error\n$stack');
    } finally {
      await exporter.dispose();
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
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
                          child: RepaintBoundary(
                            key: _compositionKey,
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
                                    config: VideoConfig(
                                      id: e.id,
                                      width: _selectedQuality.width,
                                      height: _selectedQuality.height,
                                      fps: e.fps,
                                      durationInFrames: e.durationInFrames,
                                      download: e.download,
                                    ),
                                    defaultProps: null,
                                    serialize: (_) => {},
                                    component: (ctx, _) => e.composition,
                                    controller: _ctrl,
                                    loop: false,
                                  ),
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
                            // Download MP4 Support
                            if (e.download) ...[
                              const Spacer(),
                              if (_isExporting)
                                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              else ...[
                                DropdownButtonHideUnderline(
                                  child: DropdownButton<ExportQuality>(
                                    value: _selectedQuality,
                                    dropdownColor: const Color(0xFF1A1A24),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white70,
                                    ),
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 16,
                                      color: Colors.white54,
                                    ),
                                    onChanged: (q) {
                                      if (q != null) setState(() => _selectedQuality = q);
                                    },
                                    items: ExportQuality.values.map((q) {
                                      return DropdownMenuItem(value: q, child: Text(q.label));
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: _exportMp4,
                                  icon: const Icon(Icons.download_rounded, size: 16),
                                  label: const Text('Export MP4'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: e.accent,
                                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ] else ...[
                              const Spacer(),
                              TextButton.icon(
                                onPressed: null,
                                icon: const Icon(Icons.movie_creation_outlined, size: 15),
                                label: const Text('Render (Disabled)'),
                                style: TextButton.styleFrom(
                                  disabledForegroundColor: Colors.white30,
                                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
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
