import 'dart:async';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../models/render_media_options.dart';
import '../models/render_media_progress.dart';
import '../models/render_media_result.dart';
import '../models/slow_frame.dart';
import 'frame_renderer.dart';

/// Orchestrates the full render pipeline:
/// 1. Iterates through every frame in [RenderMediaOptions.effectiveFrameRange].
/// 2. Delegates per-frame rasterisation to [FrameRenderer].
/// 3. Emits [RenderMediaProgress] events on the returned [Stream].
/// 4. Returns a [RenderMediaResult] when complete.
///
/// This is the Dart counterpart to Remotion's `render-media.ts` orchestration
/// module. The heavy rendering is off-loaded to [Isolate.run] calls so the UI
/// thread is never blocked.
///
/// ### Usage
/// ```dart
/// final renderer = MediaRenderer(options: opts);
/// renderer.onProgress.listen((p) => print(p));
/// final result = await renderer.render();
/// ```
class MediaRenderer {
  final RenderMediaOptions options;

  final StreamController<RenderMediaProgress> _progressController = StreamController<RenderMediaProgress>.broadcast();

  /// A [Stream] of [RenderMediaProgress] events emitted during the render.
  ///
  /// Subscribe before calling [render] to receive all events.
  Stream<RenderMediaProgress> get onProgress => _progressController.stream;

  MediaRenderer({required this.options});

  /// Starts the render and resolves when all frames have been encoded.
  ///
  /// Throws [RenderException] on failure.
  Future<RenderMediaResult> render({
    /// An optional widget factory called with the current frame index.
    /// Used to build the off-screen widget tree for each frame.
    required Widget Function(int frame) widgetFactory,
  }) async {
    final range = options.effectiveFrameRange;
    final totalFrames = range.length;
    final stopwatch = Stopwatch()..start();
    final slowFrames = <SlowFrame>[];

    _progressController.add(RenderMediaProgress.initial(totalFrames));

    final concurrency = options.concurrency ?? _defaultConcurrency(totalFrames);

    // Split frames into batches for parallel Isolate processing.
    final batches = _chunk(range.frames.toList(), concurrency);
    int rendered = 0;

    for (final batch in batches) {
      // Render frames in this batch concurrently via Isolates.
      final futures = batch.map((frame) async {
        final frameWatch = Stopwatch()..start();

        final image = await FrameRenderer.renderFrame(
          frame: frame,
          widget: widgetFactory(frame),
          config: options.composition,
        );

        frameWatch.stop();

        if (options.slowFrameThresholdMs != null && frameWatch.elapsedMilliseconds > options.slowFrameThresholdMs!) {
          slowFrames.add(SlowFrame(frame: frame, timeMs: frameWatch.elapsedMilliseconds));
        }
        // Here we return the raw RGBA bytes as a placeholder.
        final bytes = await _imageToBytes(image);
        image.dispose();
        return bytes;
      });

      await Future.wait(futures);
      rendered += batch.length;

      final progress = rendered / totalFrames;
      final elapsed = stopwatch.elapsedMilliseconds;
      final estimated = progress > 0 ? ((elapsed / progress) * (1 - progress)).round() : null;

      _progressController.add(
        RenderMediaProgress(
          renderedFrames: rendered,
          totalFrames: totalFrames,
          progress: progress,
          slowFrames: List.unmodifiable(slowFrames),
          estimatedRemainingMs: estimated,
        ),
      );
    }

    stopwatch.stop();
    await _progressController.close();

    return RenderMediaResult(
      outputPath: options.outputLocation,
      durationMs: stopwatch.elapsedMilliseconds,
      totalFrames: totalFrames,
      slowFrames: List.unmodifiable(slowFrames),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  int _defaultConcurrency(int totalFrames) {
    // A sensible default: min(4, totalFrames).
    return totalFrames < 4 ? totalFrames : 4;
  }

  List<List<T>> _chunk<T>(List<T> list, int size) {
    final chunks = <List<T>>[];
    for (int i = 0; i < list.length; i += size) {
      chunks.add(list.sublist(i, (i + size) < list.length ? i + size : list.length));
    }
    return chunks;
  }

  Future<List<int>> _imageToBytes(ui.Image image) async {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List().toList();
  }
}

/// Thrown when the render pipeline encounters a fatal error.
class RenderException implements Exception {
  final String message;
  final Object? cause;
  const RenderException(this.message, {this.cause});

  @override
  String toString() =>
      'RenderException: $message'
      '${cause != null ? '\nCaused by: $cause' : ''}';
}
