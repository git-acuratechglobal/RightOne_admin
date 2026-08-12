import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A decorative dotted world map with glowing markers, matching the
/// "Top Locations" card look: faint dot-grid continents + pink pulse
/// markers over the highlighted countries.
class WorldDotsMap extends StatelessWidget {
  const WorldDotsMap({super.key, this.height = 130, this.markers = const []});

  final double height;
  final List<Offset> markers; // fractional (0..1, 0..1) positions

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _WorldDotsPainter(markers: markers),
      ),
    );
  }
}

// Approximate continent silhouettes as unions of ellipses, in fractional
// map coordinates (0..1 across width/height). Not geographically precise —
// styled to read as a world map at small size, same as the reference UI.
const List<List<double>> _kContinents = [
  // North America
  [0.10, 0.28, 0.13, 0.16],
  [0.15, 0.42, 0.045, 0.07],
  // South America
  [0.23, 0.62, 0.06, 0.20],
  // Europe
  [0.46, 0.24, 0.05, 0.075],
  // Africa
  [0.49, 0.52, 0.075, 0.22],
  // Russia / North Asia
  [0.63, 0.18, 0.16, 0.065],
  // Asia core
  [0.66, 0.34, 0.15, 0.16],
  // India
  [0.60, 0.46, 0.035, 0.06],
  // SE Asia
  [0.73, 0.52, 0.05, 0.05],
  // Australia
  [0.80, 0.72, 0.065, 0.05],
];

class _WorldDotsPainter extends CustomPainter {
  _WorldDotsPainter({required this.markers});
  final List<Offset> markers;

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 6.5;
    final dotPaint = Paint()..color = AppColors.textMuted.withValues(alpha:0.45);

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        final fx = x / size.width;
        final fy = y / size.height;
        if (_insideAnyContinent(fx, fy)) {
          canvas.drawCircle(Offset(x, y), 1.1, dotPaint);
        }
      }
    }

    for (final m in markers) {
      final center = Offset(m.dx * size.width, m.dy * size.height);
      // outer glow ring
      canvas.drawCircle(
        center,
        7,
        Paint()..color = AppColors.accentMagenta.withValues(alpha:0.18),
      );
      canvas.drawCircle(
        center,
        4,
        Paint()..color = AppColors.accentMagenta.withValues(alpha:0.35),
      );
      canvas.drawCircle(
        center,
        2.2,
        Paint()..color = AppColors.accentMagenta,
      );
    }
  }

  bool _insideAnyContinent(double fx, double fy) {
    for (final c in _kContinents) {
      final cx = c[0], cy = c[1], rx = c[2], ry = c[3];
      final dx = (fx - cx) / rx;
      final dy = (fy - cy) / ry;
      if (dx * dx + dy * dy <= 1.0) return true;
    }
    return false;
  }

  @override
  bool shouldRepaint(covariant _WorldDotsPainter oldDelegate) =>
      oldDelegate.markers != markers;
}
