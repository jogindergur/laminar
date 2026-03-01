import 'codec.dart';
import 'frame_range.dart';
import 'video_config.dart';

/// Options passed to the [renderMedia] function.
///
/// Mirrors Remotion's `RenderMediaOptions` TypeScript type, mapped to idiomatic
/// Dart nominal types (no dynamic Zod schema injection).
class RenderMediaOptions {
  /// The [VideoConfig] of the composition to render.
  final VideoConfig composition;

  /// Absolute path where the output file should be written.
  ///
  /// If `null`, the renderer will write to a system temp directory and return
  /// the generated path in [RenderMediaResult.outputPath].
  final String? outputLocation;

  /// Target output codec. Defaults to [Codec.h264] when unset.
  final Codec codec;

  /// Optional subset of frames to render.
  ///
  /// When `null`, all frames (`0 .. durationInFrames - 1`) are rendered.
  final FrameRange? frameRange;

  /// Maximum number of frames to render in parallel (via Isolates).
  ///
  /// Defaults to `null`, which lets the renderer pick a sensible default
  /// based on the host machine's processor count.
  final int? concurrency;

  /// When `true`, prefer lossless encoding where the codec supports it.
  final bool preferLossless;

  /// Defaults to `'yuv420p'` for maximum compatibility.
  final String pixelFormat;

  /// Number of milliseconds a single frame may take before it is recorded as
  /// a [SlowFrame]. Set to `null` to disable slow-frame tracking.
  final int? slowFrameThresholdMs;

  const RenderMediaOptions({
    required this.composition,
    this.outputLocation,
    this.codec = Codec.h264,
    this.frameRange,
    this.concurrency,
    this.preferLossless = false,
    this.pixelFormat = 'yuv420p',
    this.slowFrameThresholdMs = 1000,
  });

  /// The effective [FrameRange] — falls back to the full composition range.
  FrameRange get effectiveFrameRange => frameRange ?? FrameRange(start: 0, end: composition.durationInFrames - 1);

  /// Returns a copy of these options with the given fields overridden.
  RenderMediaOptions copyWith({
    VideoConfig? composition,
    String? outputLocation,
    Codec? codec,
    FrameRange? frameRange,
    int? concurrency,
    bool? preferLossless,
    String? pixelFormat,
    int? slowFrameThresholdMs,
  }) {
    return RenderMediaOptions(
      composition: composition ?? this.composition,
      outputLocation: outputLocation ?? this.outputLocation,
      codec: codec ?? this.codec,
      frameRange: frameRange ?? this.frameRange,
      concurrency: concurrency ?? this.concurrency,
      preferLossless: preferLossless ?? this.preferLossless,
      pixelFormat: pixelFormat ?? this.pixelFormat,
      slowFrameThresholdMs: slowFrameThresholdMs ?? this.slowFrameThresholdMs,
    );
  }
}
