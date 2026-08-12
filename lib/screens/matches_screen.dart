import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_table.dart';
import '../widgets/stat_card.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ResponsiveStatRow(
          cards: [
            StatCard(label: 'Total Matches', value: '3,180'),
            StatCard(label: 'New Today', value: '48', accent: AppColors.accentCyan),
            StatCard(label: 'Unmatch Rate', value: '6.2%', deltaPositive: false, delta: 'watch closely'),
          ],
        ),
        const SizedBox(height: 22),
        AdminTable(
          columns: const ['User A', 'User B', 'Matched On', 'Status'],
          columnFlex: const [3, 3, 2, 2],
          rows: [
            for (final m in MockData.matches)
              [
                Text(m.userA, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                Text(m.userB, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                Text(m.matchedOn, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                StatusPill(m.status, color: statusColor(m.status)),
              ],
          ],
        ),
      ],
    );
  }
}
