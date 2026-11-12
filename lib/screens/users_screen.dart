import 'package:flutter/material.dart';
import '../data/admin_store.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_table.dart';
import '../widgets/dashed_container.dart';
import '../widgets/mini_charts.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: adminStore,
      builder: (context, _) {
        final q = _query.trim().toLowerCase();
        final users = adminStore.visibleUsers.where((u) {
          if (q.isEmpty) return true;
          return u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q) ||
              u.profileId.toLowerCase().contains(q) ||
              u.phone.toLowerCase().contains(q);
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                   width: MediaQuery.of(context).size.width * 1/3,
                  child: DashedContainer(
                    padding: const EdgeInsets.only(left: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 16, color: AppColors.textMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() => _query = v),
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                            decoration: const InputDecoration(
                              isDense: true,
                              filled: false,
                              border: InputBorder.none,
                              hintText: 'Search users by name, email, Profile ID, or phone…',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text('+ Add User'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            AdminTable(
              columns: const ['Name', 'Profile ID / Phone', 'Gender', 'Mode', 'Karma', 'Status', 'Joined', ''],
              columnFlex: const [3, 3, 2, 2, 2, 2, 2, 1],
              rows: [
                for (final user in users)
                  [
                    InkWell(
                      onTap: () => _showProfileDialog(context, user),
                      child: Row(
                        children: [
                          ClipOval(
                            child: Container(
                              width: 30,
                              height: 30,
                              color: AppColors.surfaceAlt,
                              child: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                                  ? Image.network(
                                      user.avatarUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Center(
                                        child: Text(user.name.substring(0, 1), style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                                      ),
                                    )
                                  : Center(
                                      child: Text(user.name.substring(0, 1), style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(user.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                                Text(user.email, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(user.profileId, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                        Text(user.phone, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ),
                    Text(user.gender, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    _ModePill(user.mode),
                    KarmaPill(user.karma),
                    StatusPill(adminStore.statusFor(user), color: statusColor(adminStore.statusFor(user))),
                    Text(user.joined, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    _UserActionsMenu(user: user, onOpenProfile: () => _showProfileDialog(context, user)),
                  ],
              ],
            ),
          ],
        );
      },
    );
  }

  void _showProfileDialog(BuildContext context, AppUser user) {
    showDialog(
      context: context,
      builder: (_) => _UserProfileDialog(user: user),
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill(this.mode);
  final String mode;

  Color get _color {
    switch (mode) {
      case 'Dating':
        return AppColors.accentMagenta;
      case 'Friends':
        return AppColors.accentCyan;
      default:
        return AppColors.gold;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha:0.12),
        border: Border.all(color: _color.withValues(alpha:0.5)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(mode, style: TextStyle(color: _color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _UserActionsMenu extends StatelessWidget {
  const _UserActionsMenu({required this.user, required this.onOpenProfile});

  final AppUser user;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final status = adminStore.statusFor(user);
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textSecondary),
      color: AppColors.surfaceAlt,
      onSelected: (value) {
        switch (value) {
          case 'view':
            onOpenProfile();
            break;
          case 'ban':
            adminStore.banUser(user);
            _toast(context, '${user.name} has been banned.');
            break;
          case 'unban':
            adminStore.unbanUser(user);
            _toast(context, '${user.name} has been unbanned.');
            break;
          case 'shadowban':
            adminStore.shadowbanUser(user);
            _toast(context, '${user.name} has been shadowbanned.');
            break;
          case 'delete':
            adminStore.deleteUser(user);
            _toast(context, '${user.name} has been deleted.');
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'view', child: Text('View Profile')),
        if (status != 'Suspended')
          const PopupMenuItem(value: 'ban', child: Text('Ban'))
        else
          const PopupMenuItem(value: 'unban', child: Text('Unban')),
        const PopupMenuItem(value: 'shadowban', child: Text('Shadowban')),
        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.danger))),
      ],
    );
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.surfaceAlt),
    );
  }
}

class _UserProfileDialog extends StatelessWidget {
  const _UserProfileDialog({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final reportHistory = MockData.reports.where((r) => r.reported == user.name).toList();

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.borderStrong)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Container(
                      width: 48,
                      height: 48,
                      color: AppColors.surfaceAlt,
                      child: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                          ? Image.network(
                              user.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(user.name.substring(0, 1), style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                              ),
                            )
                          : Center(
                              child: Text(user.name.substring(0, 1), style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                        Text('${user.profileId} · ${user.email}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: _infoTile('Phone', user.phone)),
                  const SizedBox(width: 10),
                  Expanded(child: _infoTile('Mode', user.mode)),
                  const SizedBox(width: 10),
                  Expanded(child: _infoTile('Age', '${user.age}')),
                ],
              ),
              const SizedBox(height: 18),
              const Text('KARMA TREND (LAST 7)', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1)),
              const SizedBox(height: 10),
              SparklineWidget(
                values: user.karmaHistory.map((e) => e.toDouble()).toList(),
                color: AppColors.accentMagenta,
                height: 44,
              ),
              const SizedBox(height: 18),
              const Text('REPORT HISTORY', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1)),
              const SizedBox(height: 8),
              if (reportHistory.isEmpty)
                const Text('No reports filed against this user.', style: TextStyle(color: AppColors.textMuted, fontSize: 12.5))
              else
                for (final r in reportHistory)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.flag_outlined, size: 14, color: AppColors.danger),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${r.category} · reported by ${r.reporter} · ${r.submittedAgo}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return DashedContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      backgroundColor: AppColors.surfaceAlt,
      radius: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 0.6)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
