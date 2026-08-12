import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A themed card/hairline container used throughout the admin panel.
/// When [sides] covers all four edges it renders as a rounded card
/// (matching the app's card style: dark fill + soft border + radius).
/// When only some sides are set (e.g. sidebar/topbar), it renders a
/// plain hairline border on just those edges.
class DashedContainer extends StatelessWidget {
  const DashedContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.border,
    this.strokeWidth = 1,
    this.dashWidth = 5,
    this.gapWidth = 4,
    this.sides = const {
      DashedSide.top,
      DashedSide.bottom,
      DashedSide.left,
      DashedSide.right,
    },
    this.backgroundColor,
    this.radius = 16,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double gapWidth;
  final Set<DashedSide> sides;
  final Color? backgroundColor;
  final double radius;

  bool get _isFullCard => sides.length == 4;

  @override
  Widget build(BuildContext context) {
    if (_isFullCard) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: AppColors.borderStrong, width: 1),
        ),
        child: child,
      );
    }

    return Container(
      padding: padding,
      color: backgroundColor,
      decoration: BoxDecoration(
        border: Border(
          top: sides.contains(DashedSide.top)
              ? BorderSide(color: color)
              : BorderSide.none,
          bottom: sides.contains(DashedSide.bottom)
              ? BorderSide(color: color)
              : BorderSide.none,
          left: sides.contains(DashedSide.left)
              ? BorderSide(color: color)
              : BorderSide.none,
          right: sides.contains(DashedSide.right)
              ? BorderSide(color: color)
              : BorderSide.none,
        ),
      ),
      child: child,
    );
  }
}

enum DashedSide { top, bottom, left, right }
