import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_table.dart';
import '../widgets/stat_card.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ResponsiveStatRow(
          cards: [
            StatCard(label: 'Active Subscribers', value: '2,014'),
            StatCard(label: 'MRR', value: '\$24,500', accent: AppColors.accentCyan),
            StatCard(label: 'Churn', value: '2.1%', deltaPositive: false, delta: 'up from 1.8%'),
          ],
        ),
        const SizedBox(height: 22),
        AdminTable(
          columns: const ['User', 'Plan', 'Renews', 'Amount', 'Status'],
          columnFlex: const [3, 2, 2, 2, 2],
          rows: [
            for (final s in MockData.subscriptions)
              [
                Text(s.user, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                Text(s.plan, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                Text(s.renews, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                Text(s.amount, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                StatusPill(s.status, color: statusColor(s.status)),
              ],
          ],
        ),
      ],
    );
  }
}
