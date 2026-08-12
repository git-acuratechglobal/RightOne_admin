import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashed_container.dart';

class AdminTable extends StatelessWidget {
  const AdminTable({
    super.key,
    required this.columns,
    required this.rows,
    this.columnFlex,
    this.columnGap = 12,
    this.minColumnWidth = 92,
  });

  final List<String> columns;
  final List<List<Widget>> rows;
  final List<int>? columnFlex;
  final double columnGap;

  /// Minimum width (px) reserved per flex unit. On a screen too narrow to
  /// fit every column at this minimum, the table switches to horizontal
  /// scrolling instead of squeezing columns down into unreadable slivers
  /// (which is what previously made header/cell text wrap letter-by-letter
  /// on phones).
  final double minColumnWidth;

  @override
  Widget build(BuildContext context) {
    final flex = columnFlex ?? List.filled(columns.length, 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalFlex = flex.fold<int>(0, (a, b) => a + b);
        final gapsWidth = (columns.length - 1) * columnGap;
        final naturalWidth = totalFlex * minColumnWidth + gapsWidth + 36;
        final availableWidth = constraints.maxWidth;
        final needsScroll = availableWidth.isFinite && naturalWidth > availableWidth;

        final content = DashedContainer(
          padding: EdgeInsets.zero,
          child: SizedBox(
            width: needsScroll ? naturalWidth : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TableRow(
                  cells: [
                    for (final label in columns)
                      Text(
                        label.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                  flex: flex,
                  fixedColumnWidth: needsScroll ? minColumnWidth : null,
                  columnGap: columnGap,
                  showBottomBorder: true,
                ),
                for (int r = 0; r < rows.length; r++)
                  _TableRow(
                    cells: rows[r],
                    flex: flex,
                    fixedColumnWidth: needsScroll ? minColumnWidth : null,
                    columnGap: columnGap,
                    showBottomBorder: r != rows.length - 1,
                  ),
              ],
            ),
          ),
        );

        if (!needsScroll) return content;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 6, left: 2),
              child: _SwipeHint(),
            ),
            Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 4),
                child: content,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.swipe_outlined, size: 14, color: AppColors.textSecondary),
        SizedBox(width: 6),
        Text(
          'Swipe left to see more',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.cells,
    required this.flex,
    required this.columnGap,
    required this.showBottomBorder,
    this.fixedColumnWidth,
  });

  final List<Widget> cells;
  final List<int> flex;

  /// When set, each column gets a fixed width (flex[i] * fixedColumnWidth)
  /// instead of flexing to fill the row — used inside the horizontal-scroll
  /// fallback where the row's width is no longer bound to the viewport.
  final double? fixedColumnWidth;
  final double columnGap;
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: showBottomBorder ? AppColors.border : Colors.transparent,
          ),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < cells.length; i++) ...[
            if (i > 0) SizedBox(width: columnGap),
            fixedColumnWidth != null
                ? SizedBox(width: flex[i] * fixedColumnWidth!, child: cells[i])
                : Expanded(flex: flex[i], child: cells[i]),
          ],
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {super.key, this.color = AppColors.success});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.12),
        border: Border.all(color: color.withValues(alpha:  0.6)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class KarmaPill extends StatelessWidget {
  const KarmaPill(this.karma, {super.key});

  final int karma;

  Color get _color {
    if (karma >= 85) return AppColors.gold;
    if (karma >= 60) return AppColors.success;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha:0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _color.withValues(alpha:0.5)),
      ),
      child: Text(
        '$karma',
        style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

Color statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'active':
    case 'chatting':
      return AppColors.success;
    case 'pending':
    case 'new match':
      return AppColors.warning;
    case 'suspended':
    case 'unmatched':
    case 'cancelled':
    case 'past due':
      return AppColors.danger;
    default:
      return AppColors.textSecondary;
  }
}
