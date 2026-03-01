/// Tracks a single frame that exceeded the render-time warning threshold.
///
/// Equivalent to Remotion's `SlowFrame` TypeScript interface.
class SlowFrame {

  const SlowFrame({required this.frame, required this.timeMs});
  /// Zero-based frame index.
  final int frame;

  /// Wall-clock time taken to render this frame, in milliseconds.
  final int timeMs;

  @override
  String toString() => 'SlowFrame(frame: $frame, timeMs: $timeMs)';
}
