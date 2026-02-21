import 'package:flutter/widgets.dart';

import '../core/composition_provider.dart';

/// Returns the zero-based index of the frame currently being rendered.
///
/// This is the Dart equivalent of Remotion's `useCurrentFrame()` React hook.
///
/// The value changes on every render tick driven by the renderer. In
/// interactive preview mode the value is driven by an animation controller;
/// during offline rendering it is set explicitly per-frame by [FrameRenderer].
///
/// Must be called from within a widget that descends from a [Composition] or
/// [CompositionProvider].
///
/// ```dart
/// class FadeIn extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final frame = useCurrentFrame(context);
///     final opacity = (frame / 30.0).clamp(0.0, 1.0);
///     return Opacity(opacity: opacity, child: child);
///   }
/// }
/// ```
int useCurrentFrame(BuildContext context) =>
    CompositionProvider.frameOf(context);
