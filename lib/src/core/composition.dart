import 'package:flutter/widgets.dart';

import '../models/video_config.dart';
import 'composition_provider.dart';

/// A widget that registers a named composition (scene) in the Laminar render
/// tree.
///
/// [Composition] is the top-level entry point for defining a renderable scene.
/// It wraps its [child] widget with a [CompositionProvider] so that all
/// descendants can access the active [VideoConfig] via [useVideoConfig].
///
/// ```dart
/// Composition<MyProps>(
///   id: 'intro',
///   width: 1920,
///   height: 1080,
///   fps: 30,
///   durationInFrames: 150,
///   defaultProps: MyProps(title: 'Hello, Laminar!'),
///   serialize: (p) => p.toJson(),
///   component: (context, props) => MyScene(props: props),
/// )
/// ```
///
/// The generic type [T] represents the props type for this composition. Pass
/// a typed props object and a [serialize] function so the renderer can
/// round-trip props through JSON.
class Composition<T> extends StatelessWidget {
  /// Unique human-readable identifier for this composition.
  final String id;

  /// Output width in pixels.
  final int width;

  /// Output height in pixels.
  final int height;

  /// Frames per second.
  final int fps;

  /// Total number of frames.
  final int durationInFrames;

  /// Default props for this composition.
  final T defaultProps;

  /// Converts [defaultProps] to a JSON-compatible map.
  ///
  /// Since Dart lacks Zod-style runtime schema introspection, callers must
  /// provide an explicit serializer.
  final Map<String, dynamic> Function(T props) serialize;

  /// Builder function that receives [BuildContext] and the resolved [T] props
  /// and returns the root widget of this composition.
  final Widget Function(BuildContext context, T props) component;

  const Composition({
    super.key,
    required this.id,
    required this.width,
    required this.height,
    required this.fps,
    required this.durationInFrames,
    required this.defaultProps,
    required this.serialize,
    required this.component,
  });

  @override
  Widget build(BuildContext context) {
    final config = VideoConfig(
      id: id,
      width: width,
      height: height,
      fps: fps,
      durationInFrames: durationInFrames,
      defaultProps: serialize(defaultProps),
    );

    return CompositionProvider(
      config: config,
      frame: 0,
      child: Builder(
        builder: (ctx) => component(ctx, defaultProps),
      ),
    );
  }
}
