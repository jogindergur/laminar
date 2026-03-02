import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:laminar/laminar.dart';

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║                        DATA   MODEL                                     ║
// ╚══════════════════════════════════════════════════════════════════════════╝

/// A single labelled data point on the x-axis.
class ChartDataPoint {
  const ChartDataPoint({required this.label, required this.value});

  /// Human-readable x-axis label (e.g. "Jan", "Week 3", "Q1").
  final String label;

  /// Numeric y value.
  final double value;
}

/// One named series with its own colour and list of data points.
///
/// All series in a [ChartDataset] must have the **same number of data points**
/// and the same labels (the labels are taken from the first series).
class ChartSeries {
  const ChartSeries({
    required this.name,
    required this.color,
    required this.dataPoints,
    this.glowColor,
  });
  final String name;
  final Color color;

  /// Optional distinct glow colour; defaults to [color].
  final Color? glowColor;

  final List<ChartDataPoint> dataPoints;

  Color get effectiveGlowColor => glowColor ?? color;
}

/// Top-level dataset handed to [TrendChartComposition].
class ChartDataset {
  const ChartDataset({
    required this.title,
    required this.series,
    this.unit = '',
    this.prefix = '',
  });

  /// Chart title shown in the top-left corner.
  final String title;

  /// Optional unit suffix appended to y-axis tick labels (e.g. "k", "%", "M").
  final String unit;

  /// Symbol prepended to y-axis tick labels (e.g. "\$", "€").
  final String prefix;

  final List<ChartSeries> series;

  /// X-axis labels derived from the first series.
  List<String> get labels => series.isEmpty
      ? []
      : series.first.dataPoints.map((p) => p.label).toList();
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║                    DEFAULT STATIC DATASET                               ║
// ╚══════════════════════════════════════════════════════════════════════════╝

/// Drop-in example dataset — replace with your own [ChartDataset] instance.
const ChartDataset _kDefaultDataset = ChartDataset(
  title: 'MONTHLY PERFORMANCE',
  prefix: '\$',
  unit: 'k',
  series: [
    ChartSeries(
      name: 'Revenue',
      color: Color(0xFF6C63FF),
      dataPoints: [
        ChartDataPoint(label: 'Jan', value: 42),
        ChartDataPoint(label: 'Feb', value: 58),
        ChartDataPoint(label: 'Mar', value: 51),
        ChartDataPoint(label: 'Apr', value: 73),
        ChartDataPoint(label: 'May', value: 68),
        ChartDataPoint(label: 'Jun', value: 89),
        ChartDataPoint(label: 'Jul', value: 95),
      ],
    ),
    ChartSeries(
      name: 'Profit',
      color: Color(0xFF00C9A7),
      dataPoints: [
        ChartDataPoint(label: 'Jan', value: 18),
        ChartDataPoint(label: 'Feb', value: 22),
        ChartDataPoint(label: 'Mar', value: 19),
        ChartDataPoint(label: 'Apr', value: 31),
        ChartDataPoint(label: 'May', value: 27),
        ChartDataPoint(label: 'Jun', value: 41),
        ChartDataPoint(label: 'Jul', value: 48),
      ],
    ),
    ChartSeries(
      name: 'Expenses',
      color: Color(0xFFFF6584),
      dataPoints: [
        ChartDataPoint(label: 'Jan', value: 24),
        ChartDataPoint(label: 'Feb', value: 36),
        ChartDataPoint(label: 'Mar', value: 32),
        ChartDataPoint(label: 'Apr', value: 42),
        ChartDataPoint(label: 'May', value: 41),
        ChartDataPoint(label: 'Jun', value: 48),
        ChartDataPoint(label: 'Jul', value: 47),
      ],
    ),
  ],
);

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║                     COMPOSITION  WIDGET                                 ║
// ╚══════════════════════════════════════════════════════════════════════════╝

/// Animated multi-series line chart driven by a [ChartDataset].
///
/// Swap the [dataset] parameter to visualise any data — the animation,
/// axis scaling, and legend update automatically.
///
/// **Animation phases (150 frames @ 30 fps):**
/// | Frames   | Effect                                      |
/// |----------|---------------------------------------------|
/// | 0–20     | Grid + axis labels fade in                  |
/// | 15–140   | Lines draw themselves left → right          |
/// | 20–145   | Gradient area fills fade in beneath lines   |
/// | all      | Pulsing glowing dot at each line's head     |
class TrendChartComposition extends StatelessWidget {
  const TrendChartComposition({super.key, this.dataset = _kDefaultDataset});

  /// The dataset to visualise. Defaults to [_kDefaultDataset].
  final ChartDataset dataset;

  @override
  Widget build(BuildContext context) {
    final frame = useCurrentFrame(context);
    final config = useVideoConfig(context);
    final total = config.durationInFrames;

    // ── Animation values ──────────────────────────────────────────────────

    final gridOpacity = interpolate(
      frame,
      [0, 20],
      [0.0, 1.0],
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );

    final lineProgress = interpolate(
      frame,
      [15, total - 10],
      [0.0, 1.0],
      easing: LaminarEasing.easeInOutCubic,
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );

    final fillOpacity = interpolate(
      frame,
      [20, total - 5],
      [0.0, 0.18],
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );

    final dotGlow = 0.6 + 0.4 * math.sin(frame / total * math.pi * 6);

    final legendOpacity = interpolate(
      frame,
      [25, 45],
      [0.0, 1.0],
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );

    final titleOffset = interpolate(
      frame,
      [0, 18],
      [-16.0, 0.0],
      easing: LaminarEasing.easeOutCubic,
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );

    final titleOpacity = interpolate(
      frame,
      [0, 18],
      [0.0, 1.0],
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );

    // ── Layout ────────────────────────────────────────────────────────────

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D0D1F), Color(0xFF0D0D12)],
            ),
          ),
        ),

        // Ambient radial glow
        Positioned.fill(
          child: Opacity(
            opacity: gridOpacity * 0.5,
            child: CustomPaint(painter: _AmbientGlowPainter()),
          ),
        ),

        // Chart area
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final padding = isMobile
                ? const EdgeInsets.fromLTRB(36, 24, 16, 24)
                : const EdgeInsets.fromLTRB(56, 52, 32, 52);
            return Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + legend row
                  Transform.translate(
                    offset: Offset(0, titleOffset),
                    child: Opacity(
                      opacity: titleOpacity,
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: 12,
                        children: [
                          Text(
                            dataset.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.5,
                            ),
                          ),
                          Opacity(
                            opacity: legendOpacity,
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: dataset.series
                                  .map((s) => _LegendDot(series: s))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Chart canvas
                  Expanded(
                    child: Opacity(
                      opacity: gridOpacity,
                      child: CustomPaint(
                        painter: _TrendChartPainter(
                          dataset: dataset,
                          lineProgress: lineProgress,
                          fillOpacity: fillOpacity,
                          dotGlow: dotGlow,
                          isMobile: isMobile,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Frame watermark
        Positioned(
          bottom: 14,
          right: 18,
          child: Opacity(
            opacity: gridOpacity * 0.4,
            child: Text(
              'frame $frame · interpolate() + CustomPaint',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 9,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║                         LEGEND DOT                                      ║
// ╚══════════════════════════════════════════════════════════════════════════╝

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.series});
  final ChartSeries series;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: series.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: series.color.withValues(alpha: 0.6),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          series.name,
          style: TextStyle(
            color: series.color.withValues(alpha: 0.85),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║                    AMBIENT GLOW PAINTER                                 ║
// ╚══════════════════════════════════════════════════════════════════════════╝

class _AmbientGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.4, -0.2),
          radius: 0.8,
          colors: [
            const Color(0xFF6C63FF).withValues(alpha: 0.06),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(_AmbientGlowPainter _) => false;
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║                       CHART   PAINTER                                   ║
// ╚══════════════════════════════════════════════════════════════════════════╝

class _TrendChartPainter extends CustomPainter {
  _TrendChartPainter({
    required this.dataset,
    required this.lineProgress,
    required this.fillOpacity,
    required this.dotGlow,
    this.isMobile = false,
  });
  final ChartDataset dataset;
  final double lineProgress;
  final double fillOpacity;
  final double dotGlow;
  final bool isMobile;

  // ── Drawing entry point ─────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    if (dataset.series.isEmpty) return;

    const leftPad = 0.0;
    final rightPad = isMobile ? 0.0 : 8.0;
    final topPad = isMobile ? 8.0 : 12.0;
    final bottomPad = isMobile ? 20.0 : 32.0;

    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;
    final labels = dataset.labels;
    final count = labels.length;
    if (count < 2) return;

    // ── Derive value range across all series ──────────────────────────────
    double minV = double.infinity;
    double maxV = double.negativeInfinity;
    for (final s in dataset.series) {
      for (final p in s.dataPoints) {
        if (p.value < minV) minV = p.value;
        if (p.value > maxV) maxV = p.value;
      }
    }
    // Add 10 % padding to the range so lines don't touch the edges
    final padding = (maxV - minV) * 0.12;
    minV = (minV - padding).floorToDouble();
    maxV = (maxV + padding).ceilToDouble();
    final valueRange = maxV - minV;
    if (valueRange == 0) return;

    // Helper: map (index, value) → canvas Offset
    Offset pt(int i, double v) {
      final x = leftPad + (i / (count - 1)) * chartW;
      final y = topPad + chartH - ((v - minV) / valueRange) * chartH;
      return Offset(x, y);
    }

    // ── Grid + axes ───────────────────────────────────────────────────────
    _drawGrid(
      canvas,
      size,
      leftPad,
      chartW,
      topPad,
      chartH,
      bottomPad,
      minV,
      maxV,
      isMobile,
    );
    _drawXLabels(canvas, labels, leftPad, chartW, topPad, chartH, isMobile);

    // ── Area fills (drawn below lines) ────────────────────────────────────
    if (fillOpacity > 0) {
      for (final s in dataset.series) {
        _drawFill(canvas, s, pt, count, leftPad, topPad, chartW, chartH);
      }
    }

    // ── Lines + dots ──────────────────────────────────────────────────────
    for (final s in dataset.series) {
      _drawSeries(canvas, s, pt, count);
    }

    // Baseline
    canvas.drawLine(
      Offset(leftPad, topPad + chartH),
      Offset(leftPad + chartW, topPad + chartH),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..strokeWidth = 1,
    );
  }

  // ── Grid & axis helpers ─────────────────────────────────────────────────

  void _drawGrid(
    Canvas canvas,
    Size size,
    double leftPad,
    double chartW,
    double topPad,
    double chartH,
    double bottomPad,
    double minV,
    double maxV,
    bool isMobile,
  ) {
    const gridCount = 5;
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    for (int g = 0; g <= gridCount; g++) {
      final y = topPad + (g / gridCount) * chartH;
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(leftPad + chartW, y),
        gridPaint,
      );

      final val = maxV - (g / gridCount) * (maxV - minV);
      final label = '${dataset.prefix}${val.toStringAsFixed(0)}${dataset.unit}';

      final labelOffset = isMobile ? -32.0 : -48.0;
      final labelWidth = isMobile ? 28.0 : 44.0;

      _drawText(
        canvas,
        label,
        Offset(labelOffset, y - 6),
        TextStyle(
          color: const Color(0xFF5A5A7A),
          fontSize: isMobile ? 8 : 10,
          fontWeight: FontWeight.w500,
        ),
        width: labelWidth,
        align: TextAlign.right,
      );
    }
  }

  void _drawXLabels(
    Canvas canvas,
    List<String> labels,
    double leftPad,
    double chartW,
    double topPad,
    double chartH,
    bool isMobile,
  ) {
    for (int i = 0; i < labels.length; i++) {
      final x = leftPad + (i / (labels.length - 1)) * chartW;
      _drawText(
        canvas,
        labels[i],
        Offset(x - 20, topPad + chartH + (isMobile ? 4 : 8)),
        TextStyle(
          color: const Color(0xFF5A5A7A),
          fontSize: isMobile ? 8 : 10,
          fontWeight: FontWeight.w500,
        ),
        width: 40,
        align: TextAlign.center,
      );
    }
  }

  // ── Per-series drawing ──────────────────────────────────────────────────

  /// Clips series data to [lineProgress] and computes the list of visible
  /// canvas points, including a fractionally interpolated trailing point.
  List<Offset> _visiblePoints(
    ChartSeries s,
    Offset Function(int, double) pt,
    int count,
  ) {
    final visibleFrac = lineProgress * (count - 1);
    final fullPts = visibleFrac.floor().clamp(0, count - 1);
    final partialFrac = visibleFrac - fullPts;

    final pts = <Offset>[];
    for (int i = 0; i <= fullPts; i++) {
      pts.add(pt(i, s.dataPoints[i].value));
    }
    if (fullPts < count - 1) {
      final a = pt(fullPts, s.dataPoints[fullPts].value);
      final b = pt(fullPts + 1, s.dataPoints[fullPts + 1].value);
      pts.add(Offset.lerp(a, b, partialFrac)!);
    }
    return pts;
  }

  void _drawFill(
    Canvas canvas,
    ChartSeries s,
    Offset Function(int, double) pt,
    int count,
    double leftPad,
    double topPad,
    double chartW,
    double chartH,
  ) {
    final pts = _visiblePoints(s, pt, count);
    if (pts.length < 2) return;

    final fillPath = Path()
      ..moveTo(pts.first.dx, topPad + chartH)
      ..lineTo(pts.first.dx, pts.first.dy);
    _appendSmooth(fillPath, pts, moveTo: false);
    fillPath
      ..lineTo(pts.last.dx, topPad + chartH)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            s.color.withValues(alpha: fillOpacity),
            s.color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(leftPad, topPad, chartW, chartH)),
    );
  }

  void _drawSeries(
    Canvas canvas,
    ChartSeries s,
    Offset Function(int, double) pt,
    int count,
  ) {
    final pts = _visiblePoints(s, pt, count);
    if (pts.length < 2) return;

    // Glow layer
    final glowPath = Path();
    _appendSmooth(glowPath, pts);
    canvas.drawPath(
      glowPath,
      Paint()
        ..color = s.effectiveGlowColor.withValues(alpha: 0.25)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Main line
    final linePath = Path();
    _appendSmooth(linePath, pts);
    canvas.drawPath(
      linePath,
      Paint()
        ..color = s.color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Data point markers (all except the animated leading dot)
    final visibleFrac = lineProgress * (count - 1);
    for (int i = 0; i < pts.length - 1; i++) {
      final dotFrac = (visibleFrac - i).clamp(0.0, 1.0);
      final r = 3.5 * dotFrac;
      if (r <= 0) continue;

      final actualPt = pt(i, s.dataPoints[i].value);

      // Halo
      canvas.drawCircle(
        actualPt,
        r + 2,
        Paint()
          ..color = s.color.withValues(alpha: 0.18 * dotFrac)
          ..style = PaintingStyle.fill,
      );
      // Core
      canvas.drawCircle(actualPt, r, Paint()..color = s.color);
    }

    // Pulsing leading dot at the draw head
    final lead = pts.last;
    canvas.drawCircle(
      lead,
      10.0 * dotGlow,
      Paint()
        ..color = s.effectiveGlowColor.withValues(alpha: 0.12 * dotGlow)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(lead, 4.5, Paint()..color = Colors.white);
    canvas.drawCircle(lead, 3.0, Paint()..color = s.color);
  }

  // ── Catmull-Rom → cubic bezier helper ──────────────────────────────────

  void _appendSmooth(Path path, List<Offset> pts, {bool moveTo = true}) {
    if (pts.isEmpty) return;
    if (moveTo) path.moveTo(pts.first.dx, pts.first.dy);
    if (pts.length == 1) return;

    for (int i = 0; i < pts.length - 1; i++) {
      final p0 = i > 0 ? pts[i - 1] : pts[i];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i + 2 < pts.length ? pts[i + 2] : p2;

      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
  }

  // ── Text helper ─────────────────────────────────────────────────────────

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style, {
    double width = 100,
    TextAlign align = TextAlign.left,
  }) {
    (TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: width)).paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_TrendChartPainter old) =>
      old.lineProgress != lineProgress ||
      old.fillOpacity != fillOpacity ||
      old.dotGlow != dotGlow ||
      old.dataset != dataset;
}
