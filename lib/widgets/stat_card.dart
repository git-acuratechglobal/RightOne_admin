import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashed_container.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.deltaPositive = true,
    this.accent = AppColors.accentMagenta,
  });

  final String label;
  final String value;
  final String? delta;
  final bool deltaPositive;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DashedContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (delta != null) ...[
            const SizedBox(height: 8),
            Text(
              delta!,
              style: TextStyle(
                color: deltaPositive ? AppColors.success : AppColors.danger,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Lays out a row of [StatCard]s (or similar) side by side on wide screens,
/// and stacks them vertically on narrow ones instead of letting them get
/// squeezed down to unreadable widths.
class ResponsiveStatRow extends StatelessWidget {
  const ResponsiveStatRow({
    super.key,
    required this.cards,
    this.spacing = 16,
    this.narrowBreakpoint = 560,
  });

  final List<Widget> cards;
  final double spacing;
  final double narrowBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < narrowBreakpoint;
        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i != cards.length - 1) SizedBox(height: spacing),
              ],
            ],
          );
        }
        return Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              if (i > 0) SizedBox(width: spacing),
              Expanded(child: cards[i]),
            ],
          ],
        );
      },
    );
  }
}
