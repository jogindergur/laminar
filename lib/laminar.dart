/// Laminar — A platform-independent Flutter library for programmatic
/// video composition and rendering.
///
/// Inspired by Remotion (React), Laminar brings the same declarative,
/// frame-by-frame compositing model to the Flutter/Dart ecosystem.
///
/// Core concepts:
/// - [Composition] — declares a named scene with dimensions, fps, and duration.
/// - [CompositionProvider] — InheritedWidget that propagates [VideoConfig] down the tree.
/// - [useVideoConfig] / [useCurrentFrame] — accessor helpers for the render context.
/// - [renderMedia] — orchestrates frame-by-frame rendering and FFmpeg piping.
library laminar;

// ── Core models ──────────────────────────────────────────────────────────────
export 'src/models/video_config.dart';
export 'src/models/render_media_options.dart';
export 'src/models/render_media_result.dart';
export 'src/models/render_media_progress.dart';
export 'src/models/codec.dart';
export 'src/models/frame_range.dart';
export 'src/models/slow_frame.dart';

// ── Core widgets ─────────────────────────────────────────────────────────────
export 'src/core/composition.dart';
export 'src/core/composition_provider.dart';
export 'src/core/sequence.dart';
export 'src/core/series.dart';

// ── Hooks / context accessors ─────────────────────────────────────────────────
export 'src/hooks/use_video_config.dart';
export 'src/hooks/use_current_frame.dart';

// ── Interpolation & animation ─────────────────────────────────────────────────
export 'src/interpolate/interpolate.dart';
export 'src/interpolate/easing.dart';

// ── Renderer ─────────────────────────────────────────────────────────────────
export 'src/renderer/media_renderer.dart';
export 'src/renderer/frame_renderer.dart';
