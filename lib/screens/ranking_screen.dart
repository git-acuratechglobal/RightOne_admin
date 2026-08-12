import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_table.dart';
import '../widgets/dashed_container.dart';

/// Internal user ranking screen (spec section 20.C) — overall karma-based
/// ranking plus separate Men / Women rankings.
class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final sorted = [...MockData.users]..sort((a, b) => b.karma.compareTo(a.karma));
    List<AppUser> list;
    switch (_tab) {
      case 1:
        list = sorted.where((u) => u.gender == 'Male').toList();
        break;
      case 2:
        list = sorted.where((u) => u.gender == 'Female').toList();
        break;
      default:
        list = sorted;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashedContainer(
          padding: const EdgeInsets.all(6),
          radius: 12,
          child: Row(
            children: [
              for (int i = 0; i < 3; i++)
                Expanded(
                  child: _TabButton(
                    label: ['Overall', 'Men', 'Women'][i],
                    selected: _tab == i,
                    onTap: () => setState(() => _tab = i),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AdminTable(
          columns: const ['Rank', 'Name', 'Gender', 'Mode', 'Karma', 'Likes'],
          columnFlex: const [1, 3, 2, 2, 2, 2],
          rows: [
            for (int i = 0; i < list.length; i++)
              [
                Row(
                  children: [
                    if (i < 3)
                      Icon(Icons.emoji_events_rounded, size: 16, color: [AppColors.gold, const Color(0xFFC0C0C0), const Color(0xFFCD7F32)][i]),
                    if (i >= 3) const SizedBox(width: 16),
                    const SizedBox(width: 6),
                    Text('#${i + 1}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
                Text(list[i].name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(list[i].gender, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                Text(list[i].mode, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                KarmaPill(list[i].karma),
                Row(
                  children: [
                    const Icon(Icons.favorite_rounded, size: 13, color: AppColors.accentMagenta),
                    const SizedBox(width: 5),
                    Text('${list[i].likes}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                  ],
                ),
              ],
          ],
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentMagenta.withValues(alpha:0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.accentMagenta.withValues(alpha:0.5) : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
