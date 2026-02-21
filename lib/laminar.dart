/// Laminar — A platform-independent Flutter library for programmatic
/// video composition and rendering.
///
/// Compositions are **regular Flutter widgets** — embed them anywhere:
/// ```dart
/// SizedBox(
///   width: 400, height: 225,
///   child: Composition<void>(
///     id: 'intro', width: 1920, height: 1080, fps: 30,
///     durationInFrames: 90,
///     defaultProps: null, serialize: (_) => {},
///     component: (ctx, _) => const MyScene(),
///     autoPlay: true, loop: true,
///   ),
/// )
/// ```
library;

// ── Core widgets ─────────────────────────────────────────────────────────────
export 'src/core/composition.dart';
export 'src/core/composition_provider.dart';
// ── Playback controller ───────────────────────────────────────────────────────
export 'src/core/laminar_controller.dart';
export 'src/core/sequence.dart';
export 'src/core/series.dart';
export 'src/hooks/use_current_frame.dart';
// ── Hooks / context accessors ─────────────────────────────────────────────────
export 'src/hooks/use_video_config.dart';
export 'src/interpolate/easing.dart';
// ── Interpolation & animation ─────────────────────────────────────────────────
export 'src/interpolate/interpolate.dart';
export 'src/models/codec.dart';
export 'src/models/frame_range.dart';
export 'src/models/render_media_options.dart';
export 'src/models/render_media_progress.dart';
export 'src/models/render_media_result.dart';
export 'src/models/slow_frame.dart';
// ── Core models ──────────────────────────────────────────────────────────────
export 'src/models/video_config.dart';
export 'src/renderer/frame_renderer.dart';
// ── Renderer ─────────────────────────────────────────────────────────────────
export 'src/renderer/media_renderer.dart';
