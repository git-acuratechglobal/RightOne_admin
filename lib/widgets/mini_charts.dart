import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

/// One series (line) in a [LineChartWidget].
class LineSeries {
  final List<double> values; // in "K" units, e.g. 98.4 means 98,400
  final Color color;
  final String Function(double lastValue)? badgeLabel;

  const LineSeries({required this.values, required this.color, this.badgeLabel});
}

/// A minimal multi-series line chart drawn with CustomPainter — no chart
/// package dependency needed for this static build. Draws Y axis labels
/// (in K), X axis labels, and a floating value badge at the end of each
/// series, matching the reference dashboard design.
class LineChartWidget extends StatelessWidget {
  const LineChartWidget({
    super.key,
    required this.series,
    required this.xLabels,
    this.height = 220,
    this.yMax,
    this.yStepCount = 6,
  });

  final List<LineSeries> series;
  final List<String> xLabels;
  final double height;
  final double? yMax;
  final int yStepCount;

  @override
  Widget build(BuildContext context) {
    final maxV = yMax ??
        series
            .expand((s) => s.values)
            .fold<double>(0, (m, v) => v > m ? v : m);
    // Round up to a "nice" step so the Y axis reads like 0,20K,40K...
    final niceMax = _niceMax(maxV, yStepCount);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 44, right: 4, bottom: 22),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _LineChartPainter(
                    series: series,
                    maxV: niceMax,
                    yStepCount: yStepCount,
                  ),
                ),
              ),
              // Y axis labels
              Positioned(
                left: 0,
                top: 0,
                bottom: 22,
                width: 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (int i = yStepCount; i >= 0; i--)
                      Text(
                        formatCompactK(niceMax * i / yStepCount),
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                  ],
                ),
              ),
              // X axis labels
              Positioned(
                left: 44,
                right: 4,
                bottom: 0,
                height: 18,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final label in xLabels)
                      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              // End-of-line value badges
              for (final s in series)
                if (s.values.isNotEmpty)
                  _badgePositioned(
                    constraints: constraints,
                    s: s,
                    maxV: niceMax,
                  ),
            ],
          );
        },
      ),
    );
  }

  Widget _badgePositioned({
    required BoxConstraints constraints,
    required LineSeries s,
    required double maxV,
  }) {
    final chartHeight = height - 22;
    final normalized = maxV == 0 ? 0.0 : (s.values.last / maxV).clamp(0.0, 1.0);
    final y = chartHeight - (normalized * (chartHeight - 20)) - 10;
    final label = s.badgeLabel != null ? s.badgeLabel!(s.values.last) : formatCompactK(s.values.last);
    return Positioned(
      right: 4,
      top: (y - 12).clamp(0.0, chartHeight),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: s.color,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [BoxShadow(color: s.color.withValues(alpha:0.5), blurRadius: 10)],
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static double _niceMax(double value, int steps) {
    if (value <= 0) return steps.toDouble();
    final rawStep = value / steps;
    final magnitude = _pow10(rawStep.toString().split('.').first.length - 1);
    final niceStep = (rawStep / magnitude).ceil() * magnitude;
    return niceStep * steps;
  }

  static double _pow10(int exp) {
    double r = 1;
    for (int i = 0; i < exp; i++) {
      r *= 10;
    }
    return r;
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.series, required this.maxV, required this.yStepCount});

  final List<LineSeries> series;
  final double maxV;
  final int yStepCount;

  @override
  void paint(Canvas canvas, Size size) {
    // Gridlines
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha:0.5)
      ..strokeWidth = 1;
    for (int i = 0; i <= yStepCount; i++) {
      final y = size.height / yStepCount * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (final s in series) {
      _drawSeries(canvas, size, s);
    }
  }

  void _drawSeries(Canvas canvas, Size size, LineSeries s) {
    final values = s.values;
    if (values.isEmpty) return;
    final color = s.color;
    final range = maxV <= 0 ? 1 : maxV;

    final path = Path();
    final fillPath = Path();
    final stepX = values.length > 1 ? size.width / (values.length - 1) : 0.0;

    for (int i = 0; i < values.length; i++) {
      final x = stepX * i;
      final normalized = (values[i] / range).clamp(0.0, 1.0);
      final y = size.height - (normalized * (size.height - 20)) - 10;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha:0.28), color.withValues(alpha:0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => false;
}

/// A tiny sparkline used inside stat cards — same visual language as
/// [LineChartWidget] but compact and without gridlines.
class SparklineWidget extends StatelessWidget {
  const SparklineWidget({
    super.key,
    required this.values,
    this.color = AppColors.accentMagenta,
    this.height = 44,
  });

  final List<double> values;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(values: values, color: color),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < 0.0001 ? 1 : (maxV - minV);

    final path = Path();
    final fillPath = Path();
    final stepX = size.width / (values.length - 1);

    for (int i = 0; i < values.length; i++) {
      final x = stepX * i;
      final normalized = (values[i] - minV) / range;
      final y = size.height - (normalized * (size.height - 6)) - 3;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha:0.25), color.withValues(alpha:0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => false;
}

/// A donut/ring chart segment definition.
class DonutSegment {
  final double value;
  final Color color;

  const DonutSegment(this.value, this.color);
}

/// A neon donut chart with a centered label — used for the Gender Ratio card.
class DonutChartWidget extends StatelessWidget {
  const DonutChartWidget({
    super.key,
    required this.segments,
    required this.centerValue,
    required this.centerLabel,
    this.size = 200,
    this.strokeWidth = 26,
  });

  final List<DonutSegment> segments;
  final String centerValue;
  final String centerLabel;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutPainter(segments: segments, strokeWidth: strokeWidth),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerValue,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                centerLabel,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.segments, required this.strokeWidth});

  final List<DonutSegment> segments;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<double>(0, (sum, s) => sum + s.value);
    if (total <= 0) return;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    double start = -90 * (3.14159265 / 180);
    for (final seg in segments) {
      final sweep = (seg.value / total) * 2 * 3.14159265;
      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: start,
          endAngle: start + sweep,
          colors: [seg.color.withValues(alpha:0.55), seg.color],
        ).createShader(rect);
      canvas.drawArc(rect, start, sweep * 0.985, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => true;
}

/// A compact vertical bar chart (e.g. hourly activity) with sparse X axis
/// labels — matches the "Online Users" card in the reference dashboard.
class VerticalBarChartWidget extends StatelessWidget {
  const VerticalBarChartWidget({
    super.key,
    required this.data,
    this.color = AppColors.accentMagenta,
    this.height = 90,
    this.labelEvery = 3,
  });

  final Map<String, int> data;
  final Color color;
  final double height;
  final int labelEvery; // show 1 out of every N labels

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    final maxV = entries.isEmpty
        ? 1
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: height + 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final e in entries)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Tooltip(
                        message: '${e.key}: ${e.value}',
                        child: FractionallySizedBox(
                          heightFactor: maxV == 0 ? 0.02 : (e.value / maxV).clamp(0.03, 1.0),
                          alignment: Alignment.bottomCenter,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [color, color.withValues(alpha:0.35)],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (int i = 0; i < entries.length; i++)
                Expanded(
                  child: (i % labelEvery == 0 || i == entries.length - 1)
                      ? Text(
                          entries[i].key,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                        )
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A minimal horizontal bar chart for category breakdowns.
class BarChartWidget extends StatelessWidget {
  const BarChartWidget({
    super.key,
    required this.data,
    this.color = AppColors.accentCyan,
  });

  final Map<String, int> data;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final maxV = data.values.isEmpty
        ? 1
        : data.values.reduce((a, b) => a > b ? a : b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map((e) {
        final ratio = maxV == 0 ? 0.0 : e.value / maxV;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 140,
                child: Text(
                  e.key,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        border: Border.all(color: AppColors.border),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: ratio.clamp(0.02, 1.0),
                      child: Container(height: 10, color: color),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 24,
                child: Text(
                  '${e.value}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
