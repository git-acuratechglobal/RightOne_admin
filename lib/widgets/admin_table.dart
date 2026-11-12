import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashed_container.dart';

class AdminTable extends StatefulWidget {
  const AdminTable({
    super.key,
    required this.columns,
    required this.rows,
    this.columnFlex,
    this.columnGap = 12,
    this.minColumnWidth = 84,
  });

  final List<String> columns;
  final List<List<Widget>> rows;
  final List<int>? columnFlex;
  final double columnGap;

  /// Minimum width (px) reserved per flex unit. On a screen too narrow to
  /// fit every column at this minimum, the table switches to horizontal
  /// scrolling with drag, trackpad, and scrollbar support.
  final double minColumnWidth;

  @override
  State<AdminTable> createState() => _AdminTableState();
}

class _AdminTableState extends State<AdminTable> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flex = widget.columnFlex ?? List.filled(widget.columns.length, 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalFlex = flex.fold<int>(0, (a, b) => a + b);
        final gapsWidth = (widget.columns.length - 1) * widget.columnGap;
        final naturalWidth = totalFlex * widget.minColumnWidth + gapsWidth + 36;
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
                    for (final label in widget.columns)
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
                  fixedColumnWidth: needsScroll ? widget.minColumnWidth : null,
                  columnGap: widget.columnGap,
                  showBottomBorder: true,
                ),
                for (int r = 0; r < widget.rows.length; r++)
                  _TableRow(
                    cells: widget.rows[r],
                    flex: flex,
                    fixedColumnWidth: needsScroll ? widget.minColumnWidth : null,
                    columnGap: widget.columnGap,
                    showBottomBorder: r != widget.rows.length - 1,
                  ),
              ],
            ),
          ),
        );

        if (!needsScroll) return content;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 2, right: 2),
              child: Row(
                children: [
                  const _SwipeHint(),
                  const Spacer(),
                  _ScrollArrowButton(
                    icon: Icons.chevron_left_rounded,
                    tooltip: 'Scroll left',
                    onPressed: () {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          (_scrollController.offset - 260).clamp(0.0, _scrollController.position.maxScrollExtent),
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 6),
                  _ScrollArrowButton(
                    icon: Icons.chevron_right_rounded,
                    tooltip: 'Scroll right',
                    onPressed: () {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          (_scrollController.offset + 260).clamp(0.0, _scrollController.position.maxScrollExtent),
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Theme(
              data: Theme.of(context).copyWith(
                scrollbarTheme: ScrollbarThemeData(
                  thumbColor: WidgetStateProperty.all(AppColors.accentMagenta.withValues(alpha: 0.6)),
                  trackColor: WidgetStateProperty.all(AppColors.surfaceAlt),
                  radius: const Radius.circular(8),
                  thickness: WidgetStateProperty.all(8),
                ),
              ),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                interactive: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: content,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScrollArrowButton extends StatelessWidget {
  const _ScrollArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.swipe_outlined, size: 14, color: AppColors.textSecondary),
        SizedBox(width: 6),
        Text(
          'Scroll, drag, or use arrows to see all columns',
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
