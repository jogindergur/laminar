/// Maps a [frame] value from an input domain to an output range, optionally
/// applying an [easing] curve.
///
/// This is the Dart equivalent of Remotion's `interpolate()` function.
///
/// ### Parameters
/// - [frame]: The current frame number (from [useCurrentFrame]).
/// - [inputRange]: A list of at least 2 monotonically increasing input values.
/// - [outputRange]: A list of output values of the same length as [inputRange].
/// - [easing]: An optional easing function (e.g., from [Easing]). Defaults to
///   linear mapping.
/// - [extrapolateLeft]: Behaviour when [frame] < first input. Defaults to
///   [Extrapolate.extend].
/// - [extrapolateRight]: Behaviour when [frame] > last input. Defaults to
///   [Extrapolate.extend].
///
/// ### Example
/// ```dart
/// // Fade from 0→1 over the first 30 frames, with ease-out.
/// final opacity = interpolate(
///   frame,
///   [0, 30],
///   [0.0, 1.0],
///   easing: LaminarEasing.easeOutCubic,
///   extrapolateRight: Extrapolate.clamp,
/// );
/// ```
double interpolate(
  num frame,
  List<num> inputRange,
  List<double> outputRange, {
  double Function(double)? easing,
  Extrapolate extrapolateLeft = Extrapolate.extend,
  Extrapolate extrapolateRight = Extrapolate.extend,
}) {
  assert(
    inputRange.length == outputRange.length,
    'inputRange and outputRange must have the same length',
  );
  assert(
    inputRange.length >= 2,
    'inputRange and outputRange must have at least 2 elements',
  );

  final double x = frame.toDouble();

  // ── Handle out-of-bounds ─────────────────────────────────────────────────
  if (x <= inputRange.first) {
    return _extrapolate(
      x,
      inputRange[0].toDouble(),
      inputRange[1].toDouble(),
      outputRange[0],
      outputRange[1],
      extrapolateLeft,
    );
  }

  if (x >= inputRange.last) {
    final n = inputRange.length;
    return _extrapolate(
      x,
      inputRange[n - 2].toDouble(),
      inputRange[n - 1].toDouble(),
      outputRange[n - 2],
      outputRange[n - 1],
      extrapolateRight,
    );
  }

  // ── Find the segment ──────────────────────────────────────────────────────
  int i = 0;
  while (i < inputRange.length - 2 && x >= inputRange[i + 1]) {
    i++;
  }

  final double x0 = inputRange[i].toDouble();
  final double x1 = inputRange[i + 1].toDouble();
  final double y0 = outputRange[i];
  final double y1 = outputRange[i + 1];

  // Normalise to [0, 1] within this segment.
  double t = (x - x0) / (x1 - x0);

  // Apply easing.
  if (easing != null) {
    t = easing(t.clamp(0.0, 1.0));
  }

  return y0 + (y1 - y0) * t;
}

double _extrapolate(
  double x,
  double x0,
  double x1,
  double y0,
  double y1,
  Extrapolate mode,
) {
  switch (mode) {
    case Extrapolate.clamp:
      return x <= x0 ? y0 : y1;
    case Extrapolate.identity:
      return x;
    case Extrapolate.extend:
      final slope = (y1 - y0) / (x1 - x0);
      return y0 + slope * (x - x0);
  }
}

/// Controls how [interpolate] behaves when [frame] is outside [inputRange].
enum Extrapolate {
  /// Clamps the output to the nearest boundary value.
  clamp,

  /// Extends the gradient linearly beyond the boundary (default).
  extend,

  /// Returns the raw input value unchanged.
  identity,
}
