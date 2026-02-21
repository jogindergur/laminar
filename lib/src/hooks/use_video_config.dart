import 'package:flutter/widgets.dart';

import '../core/composition_provider.dart';
import '../models/video_config.dart';

/// Returns the [VideoConfig] for the nearest [CompositionProvider] in the
/// widget tree.
///
/// This is the Dart equivalent of Remotion's `useVideoConfig()` React hook.
///
/// Must be called from within a widget that descends from a [Composition] or
/// [CompositionProvider].
///
/// ```dart
/// class MyWidget extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final config = useVideoConfig(context);
///     return Text('${config.width}x${config.height} @ ${config.fps}fps');
///   }
/// }
/// ```
VideoConfig useVideoConfig(BuildContext context) =>
    CompositionProvider.configOf(context);
