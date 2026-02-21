import 'dart:math' as math;

/// A collection of easing functions compatible with Laminar's [interpolate]
/// helper.
///
/// Each function maps a progress value _t_ in `[0.0, 1.0]` to an eased output.
/// These mirror Remotion's `Easing` export (which itself mirrors the React
/// Native / CSS easing functions).
abstract final class LaminarEasing {
  LaminarEasing._();

  // ── Linear ────────────────────────────────────────────────────────────────

  /// No easing — linear mapping.
  static double linear(double t) => t;

  // ── Quad ─────────────────────────────────────────────────────────────────

  static double easeIn(double t) => t * t;
  static double easeOut(double t) => t * (2 - t);
  static double easeInOut(double t) =>
      t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;

  // ── Cubic ─────────────────────────────────────────────────────────────────

  static double easeInCubic(double t) => t * t * t;
  static double easeOutCubic(double t) {
    final u = t - 1;
    return u * u * u + 1;
  }

  static double easeInOutCubic(double t) => t < 0.5
      ? 4 * t * t * t
      : (t - 1) * (2 * t - 2) * (2 * t - 2) + 1;

  // ── Quart ─────────────────────────────────────────────────────────────────

  static double easeInQuart(double t) => t * t * t * t;
  static double easeOutQuart(double t) {
    final u = t - 1;
    return 1 - u * u * u * u;
  }

  static double easeInOutQuart(double t) => t < 0.5
      ? 8 * t * t * t * t
      : 1 - 8 * (--t) * t * t * t;

  // ── Sine ──────────────────────────────────────────────────────────────────

  static double easeInSine(double t) =>
      1 - math.cos((t * math.pi) / 2);
  static double easeOutSine(double t) =>
      math.sin((t * math.pi) / 2);
  static double easeInOutSine(double t) =>
      -(math.cos(math.pi * t) - 1) / 2;

  // ── Expo ──────────────────────────────────────────────────────────────────

  static double easeInExpo(double t) =>
      t == 0 ? 0 : math.pow(2, 10 * t - 10).toDouble();
  static double easeOutExpo(double t) =>
      t == 1 ? 1 : 1 - math.pow(2, -10 * t).toDouble();
  static double easeInOutExpo(double t) {
    if (t == 0) return 0;
    if (t == 1) return 1;
    if (t < 0.5) return math.pow(2, 20 * t - 10).toDouble() / 2;
    return (2 - math.pow(2, -20 * t + 10).toDouble()) / 2;
  }

  // ── Bezier (cubic-bezier approximation) ───────────────────────────────────

  /// Returns an easing function modelled on the CSS cubic-bezier curve
  /// `cubic-bezier(x1, y1, x2, y2)`.
  ///
  /// This is a Newton-Raphson numeric approximation — accuracy is ±0.001.
  static double Function(double) bezier(
    double x1,
    double y1,
    double x2,
    double y2,
  ) {
    return (double t) => _cubicBezier(t, x1, y1, x2, y2);
  }

  static double _cubicBezierP(double t, double a, double b) =>
      3 * a * t * (1 - t) * (1 - t) + 3 * b * t * t * (1 - t) + t * t * t;

  static double _cubicBezier(
      double t, double x1, double y1, double x2, double y2) {
    // Newton-Raphson to find the parameter for x, then evaluate y.
    double s = t;
    for (int i = 0; i < 8; i++) {
      final x = _cubicBezierP(s, x1, x2) - t;
      final dx = 3 * x1 * (1 - s) * (1 - s) +
          6 * x2 * s * (1 - s) * (-1 + 2 * s / (1 - s)) +
          0;
      if (dx.abs() < 1e-6) break;
      s -= x / (dx == 0 ? 1 : dx);
    }
    return _cubicBezierP(s, y1, y2);
  }

  // Convenience presets matching CSS named easings ─────────────────────────

  /// `ease` — CSS default.
  static double Function(double) get ease =>
      bezier(0.25, 0.1, 0.25, 1.0);

  /// `ease-in` — CSS cubic-bezier(0.42, 0, 1.0, 1.0).
  static double Function(double) get cssEaseIn =>
      bezier(0.42, 0, 1.0, 1.0);

  /// `ease-out` — CSS cubic-bezier(0, 0, 0.58, 1.0).
  static double Function(double) get cssEaseOut =>
      bezier(0.0, 0.0, 0.58, 1.0);

  /// `ease-in-out` — CSS cubic-bezier(0.42, 0, 0.58, 1.0).
  static double Function(double) get cssEaseInOut =>
      bezier(0.42, 0, 0.58, 1.0);
}
