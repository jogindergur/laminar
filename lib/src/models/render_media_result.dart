import 'slow_frame.dart';

/// The result returned by [renderMedia] upon successful completion.
class RenderMediaResult {
  /// Absolute path to the rendered output file.
  ///
  /// `null` if [RenderMediaOptions.outputLocation] was not set and the
  /// renderer wrote to a temp file.
  final String? outputPath;

  /// Total wall-clock time taken for the entire render, in milliseconds.
  final int durationMs;

  /// Frames that exceeded the slow-frame threshold during the render.
  final List<SlowFrame> slowFrames;

  /// Total number of frames that were rendered.
  final int totalFrames;

  const RenderMediaResult({
    this.outputPath,
    required this.durationMs,
    required this.totalFrames,
    this.slowFrames = const [],
  });

  @override
  String toString() =>
      'RenderMediaResult(output: $outputPath, '
      '${totalFrames}f in ${durationMs}ms)';
}
