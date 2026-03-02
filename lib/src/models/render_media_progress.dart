import 'slow_frame.dart';

/// A progress event emitted during a [renderMedia] call.
///
/// Equivalent to Remotion's `onProgress` callback payload, but surfaced as a
/// Dart [Stream] for idiomatic usage.
class RenderMediaProgress {
  const RenderMediaProgress({
    required this.renderedFrames,
    required this.totalFrames,
    required this.progress,
    this.slowFrames = const [],
    this.estimatedRemainingMs,
  });

  /// Convenience factory for an initial (0%) progress event.
  factory RenderMediaProgress.initial(int totalFrames) {
    return RenderMediaProgress(
      renderedFrames: 0,
      totalFrames: totalFrames,
      progress: 0.0,
    );
  }

  /// Number of frames rendered so far.
  final int renderedFrames;

  /// Total number of frames to render.
  final int totalFrames;

  /// Completion ratio in the range [0.0, 1.0].
  final double progress;

  /// Frames that exceeded the slow-frame warning threshold (if any).
  final List<SlowFrame> slowFrames;

  /// Estimated milliseconds remaining, or `null` if not yet computable.
  final int? estimatedRemainingMs;

  /// Returns `true` if all frames have been rendered.
  bool get isComplete => renderedFrames >= totalFrames;

  @override
  String toString() =>
      'RenderMediaProgress(${(progress * 100).toStringAsFixed(1)}% – '
      '$renderedFrames/$totalFrames frames)';
}
