import 'package:flutter/widgets.dart';

import '../models/video_config.dart';

/// An [InheritedWidget] that propagates the active [VideoConfig] and the
/// current render [frame] index down the widget tree.
///
/// This is the Dart equivalent of Remotion's React context that backs
/// `useVideoConfig()` and `useCurrentFrame()`.
///
/// Consumer widgets should call [CompositionProvider.of] or use the
/// [useVideoConfig] / [useCurrentFrame] helpers instead of accessing this
/// widget directly.
class CompositionProvider extends InheritedWidget {

  const CompositionProvider({
    super.key,
    required this.config,
    required this.frame,
    required super.child,
  });
  /// The active [VideoConfig] for this composition.
  final VideoConfig config;

  /// Zero-based index of the frame currently being rendered.
  final int frame;

  // ── Static accessors ──────────────────────────────────────────────────────

  /// Looks up the nearest [CompositionProvider] in the widget tree.
  ///
  /// Throws a [FlutterError] if no provider is found, giving a clear
  /// actionable error message — similar to what Remotion does if you call
  /// `useVideoConfig()` outside a `<Composition>`.
  static CompositionProvider of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<CompositionProvider>();
    if (provider == null) {
      throw FlutterError.fromParts([
        ErrorSummary('No CompositionProvider found in widget tree.'),
        ErrorDescription(
          'useVideoConfig() and useCurrentFrame() must be called from within '
          'a widget that is a descendant of a Composition or CompositionProvider.',
        ),
        ErrorHint(
          'Make sure your widget is wrapped with a Composition<T> or '
          'CompositionProvider widget at the top of the render tree.',
        ),
      ]);
    }
    return provider;
  }

  /// Returns the active [VideoConfig] from the nearest [CompositionProvider].
  static VideoConfig configOf(BuildContext context) => of(context).config;

  /// Returns the current frame index from the nearest [CompositionProvider].
  static int frameOf(BuildContext context) => of(context).frame;

  // ── InheritedWidget ───────────────────────────────────────────────────────

  @override
  bool updateShouldNotify(CompositionProvider oldWidget) =>
      oldWidget.config != config || oldWidget.frame != frame;

  /// Returns a new [CompositionProvider] with the [frame] updated, keeping the
  /// same [config] and [child].
  ///
  /// Used internally by the renderer to advance the frame counter.
  CompositionProvider withFrame(int newFrame) => CompositionProvider(
        config: config,
        frame: newFrame,
        child: child,
      );
}
