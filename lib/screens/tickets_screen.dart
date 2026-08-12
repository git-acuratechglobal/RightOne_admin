import 'package:flutter/material.dart';
import '../data/admin_store.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_table.dart';
import '../widgets/stat_card.dart';

const _kTicketStatuses = ['Open', 'In Progress', 'Resolved'];

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: adminStore,
      builder: (context, _) {
        const tickets = MockData.tickets;
        final open = tickets.where((t) => adminStore.ticketStatus(t) == 'Open').length;
        final inProgress = tickets.where((t) => adminStore.ticketStatus(t) == 'In Progress').length;
        final resolved = tickets.where((t) => adminStore.ticketStatus(t) == 'Resolved').length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveStatRow(
              cards: [
                StatCard(label: 'Open', value: '$open', accent: AppColors.danger),
                StatCard(label: 'In Progress', value: '$inProgress', accent: AppColors.warning),
                StatCard(label: 'Resolved', value: '$resolved', accent: AppColors.success),
              ],
            ),
            const SizedBox(height: 22),
            AdminTable(
              columns: const ['Subject', 'User', 'Category', 'Priority', 'Status'],
              columnFlex: const [3, 2, 2, 1, 2],
              rows: [
                for (final t in tickets)
                  [
                    Text(t.subject, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(t.user, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                        Text(t.updatedAgo, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ),
                    Text(t.category, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                    _PriorityPill(t.priority),
                    _StatusDropdown(ticket: t),
                  ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class _PriorityPill extends StatelessWidget {
  const _PriorityPill(this.priority);
  final String priority;

  Color get _color {
    switch (priority) {
      case 'High':
        return AppColors.danger;
      case 'Medium':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(priority, style: TextStyle(color: _color, fontSize: 12.5, fontWeight: FontWeight.w600));
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.ticket});
  final TicketRecord ticket;

  Color _colorFor(String s) {
    switch (s) {
      case 'Open':
        return AppColors.danger;
      case 'In Progress':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = adminStore.ticketStatus(ticket);
    final color = _colorFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.12),
        border: Border.all(color: color.withValues(alpha:0.6)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: status,
          isDense: true,
          dropdownColor: AppColors.surfaceAlt,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
          icon: Icon(Icons.expand_more_rounded, size: 16, color: color),
          items: [
            for (final s in _kTicketStatuses) DropdownMenuItem(value: s, child: Text(s)),
          ],
          onChanged: (value) {
            if (value != null) adminStore.setTicketStatus(ticket, value);
          },
        ),
      ),
    );
  }
}
