import 'package:flutter/material.dart';
import '../data/admin_store.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_table.dart';
import '../widgets/dashed_container.dart';
import '../widgets/mini_charts.dart';
import '../widgets/stat_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _modeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: adminStore,
      builder: (context, _) {
        const all = MockData.reports;
        final open = all.where((r) => adminStore.reportStatus(r) == 'Open').length;
        final resolved = all.length - open;
        final filtered = all.where((r) => _modeFilter == 'All' || r.mode == _modeFilter).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        ResponsiveStatRow(
              cards: [
                StatCard(label: 'Open Reports', value: '$open', accent: AppColors.danger),
                StatCard(label: 'Resolved', value: '$resolved'),
                const StatCard(label: 'Avg. Response', value: '4.2h', accent: AppColors.accentCyan),
              ],
            ),
            const SizedBox(height: 22),
            const DashedContainer(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('REPORTS BY CATEGORY', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1)),
                  SizedBox(height: 16),
                  BarChartWidget(data: MockData.reportCategories),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('QUEUE', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1)),
                for (final mode in const ['All', 'Dating', 'Friends'])
                  ChoiceChip(
                    label: Text(mode),
                    selected: _modeFilter == mode,
                    onSelected: (_) => setState(() => _modeFilter = mode),
                    selectedColor: AppColors.accentMagenta.withValues(alpha:0.22),
                    backgroundColor: AppColors.surfaceAlt,
                    labelStyle: TextStyle(
                      color: _modeFilter == mode ? AppColors.textPrimary : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    side: BorderSide(color: _modeFilter == mode ? AppColors.accentMagenta.withValues(alpha:0.5) : AppColors.border),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            AdminTable(
              columns: const ['Reported User', 'Category', 'Mode', 'Reporter', 'Submitted', 'Status', ''],
              columnFlex: const [3, 2, 1, 2, 2, 2, 3],
              rows: [
                for (final r in filtered)
                  [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(r.reported, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(r.detail, style: const TextStyle(color: AppColors.textMuted, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    Text(r.category, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                    _ModeTag(r.mode),
                    Text(r.reporter, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                    Text(r.submittedAgo, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    StatusPill(adminStore.reportStatus(r), color: _statusColor(adminStore.reportStatus(r))),
                    _ReportActions(report: r),
                  ],
              ],
            ),
          ],
        );
      },
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Warned':
        return AppColors.warning;
      case 'Banned':
        return AppColors.danger;
      case 'Dismissed':
        return AppColors.textSecondary;
      default:
        return AppColors.accentCyan;
    }
  }
}

class _ModeTag extends StatelessWidget {
  const _ModeTag(this.mode);
  final String mode;

  @override
  Widget build(BuildContext context) {
    final color = mode == 'Dating' ? AppColors.accentMagenta : AppColors.accentCyan;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha:0.5)),
      ),
      child: Text(mode, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w600)),
    );
  }
}

class _ReportActions extends StatelessWidget {
  const _ReportActions({required this.report});
  final ReportRecord report;

  @override
  Widget build(BuildContext context) {
    final resolved = adminStore.reportStatus(report) != 'Open';
    if (resolved) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 6,
      children: [
        _actionButton(context, 'Warn', AppColors.warning, () => adminStore.warnFromReport(report)),
        _actionButton(context, 'Ban', AppColors.danger, () => adminStore.banFromReport(report)),
        _actionButton(context, 'Dismiss', AppColors.textSecondary, () => adminStore.dismissReport(report)),
      ],
    );
  }

  Widget _actionButton(BuildContext context, String label, Color color, VoidCallback onTap) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha:0.5)),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () {
        onTap();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label applied to ${report.reported}.'), backgroundColor: AppColors.surfaceAlt),
        );
      },
      child: Text(label, style: const TextStyle(fontSize: 11.5)),
    );
  }
}
