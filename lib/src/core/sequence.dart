import 'package:flutter/widgets.dart';

import 'composition_provider.dart';

/// A widget that renders its [child] only between [from] and [durationInFrames]
/// relative to the parent composition frame.
///
/// Equivalent to Remotion's `<Sequence>` component.
///
/// Example: start showing "Title" at frame 20, lasting 60 frames:
/// ```dart
/// Sequence(
///   from: 20,
///   durationInFrames: 60,
///   child: TitleWidget(),
/// )
/// ```
class Sequence extends StatelessWidget {

  const Sequence({
    super.key,
    required this.from,
    this.durationInFrames,
    required this.child,
    this.layout = false,
  }) : assert(from >= 0, 'from must be >= 0');
  /// The frame (relative to the parent composition) at which this sequence
  /// becomes visible. Must be >= 0.
  final int from;

  /// The number of frames this sequence is visible.
  ///
  /// When `null`, the sequence is visible from [from] to the end of the
  /// parent composition.
  final int? durationInFrames;

  /// The widget to display during this sequence's active window.
  final Widget child;

  /// When `true`, the child widget is still mounted (but invisible) outside
  /// the active window. Useful to keep widget state alive.
  ///
  /// Defaults to `false` — the child is fully unmounted when inactive.
  final bool layout;

  @override
  Widget build(BuildContext context) {
    final provider = CompositionProvider.of(context);
    final parentFrame = provider.frame;
    final totalFrames = provider.config.durationInFrames;

    // Compute the relative frame within this sequence.
    final relativeFrame = parentFrame - from;

    final activeEnd = durationInFrames != null
        ? from + durationInFrames!
        : totalFrames;

    final isActive = parentFrame >= from && parentFrame < activeEnd;

    if (!isActive) {
      // When layout is false, fully remove the child from the tree.
      return layout ? const SizedBox.shrink() : const SizedBox.shrink();
    }

    return CompositionProvider(
      config: provider.config,
      frame: relativeFrame.clamp(0, activeEnd - from - 1),
      child: child,
    );
  }
}
