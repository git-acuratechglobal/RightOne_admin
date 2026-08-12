import 'package:flutter/material.dart';
import '../data/admin_store.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_table.dart';
import '../widgets/dashed_container.dart';

/// A filtered view of the user list — used for Online / Premium / Blocked.
class UserSegmentScreen extends StatelessWidget {
  const UserSegmentScreen({super.key, required this.filter, required this.emptyLabel});

  final bool Function(AppUser) filter;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final users = MockData.users.where(filter).toList();
    if (users.isEmpty) {
      return _EmptyState(label: emptyLabel);
    }
    return AdminTable(
      columns: const ['Name', 'Gender', 'Age', 'Likes', 'Karma', 'Status', 'Joined'],
      columnFlex: const [3, 2, 1, 2, 2, 2, 2],
      rows: [
        for (final user in users)
          [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(user.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(user.email, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
            Text(user.gender, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            Text('${user.age}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            Row(
              children: [
                const Icon(Icons.favorite_rounded, size: 13, color: AppColors.accentMagenta),
                const SizedBox(width: 5),
                Text('${user.likes}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
            KarmaPill(user.karma),
            StatusPill(user.status, color: statusColor(user.status)),
            Text(user.joined, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
      ],
    );
  }
}

/// Verification queue screen — reused for Pending / Approved / Rejected.
/// Backed by [AdminStore] so Approve/Reject decisions made from the
/// selfie-vs-profile-photo comparison dialog actually move applicants
/// between the three queues.
class VerificationQueueScreen extends StatelessWidget {
  const VerificationQueueScreen({super.key, required this.status, required this.statusColorValue});

  final String status;
  final Color statusColorValue;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: adminStore,
      builder: (context, _) {
        final items = MockData.verifications.where((v) => adminStore.verificationStatus(v) == status).toList();
        if (items.isEmpty) {
          return const _EmptyState(label: 'No applicants in this queue right now.');
        }
        return AdminTable(
          columns: const ['Applicant', 'Profile ID', 'Submitted', 'Status', ''],
          columnFlex: const [3, 2, 2, 2, 2],
          rows: [
            for (final v in items)
              [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: AppColors.surfaceAlt,
                      child: Text(v.name.substring(0, 1), style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                    ),
                    const SizedBox(width: 10),
                    Text(v.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
                Text(v.profileIdLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Text(v.submittedAgo, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                StatusPill(adminStore.verificationStatus(v), color: statusColorValue),
                TextButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => _VerificationCompareDialog(record: v),
                  ),
                  child: const Text('Review', style: TextStyle(color: AppColors.accentMagenta, fontSize: 12.5, fontWeight: FontWeight.w600)),
                ),
              ],
          ],
        );
      },
    );
  }
}

/// Selfie-vs-profile-photo comparison dialog with functional
/// Approve / Reject buttons wired to [AdminStore].
class _VerificationCompareDialog extends StatelessWidget {
  const _VerificationCompareDialog({required this.record});
  final VerificationRecord record;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.borderStrong)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(record.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
              Text('${record.profileIdLabel} · submitted ${record.submittedAgo}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: _photoBox('Profile Photo', Icons.account_circle_rounded)),
                  const SizedBox(width: 12),
                  Expanded(child: _photoBox('Live Selfie', Icons.camera_alt_rounded)),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Compare the live selfie against the profile photo for a facial match before approving.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.danger),
                        foregroundColor: AppColors.danger,
                      ),
                      onPressed: () {
                        adminStore.rejectVerification(record);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.black),
                      onPressed: () {
                        adminStore.approveVerification(record);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoBox(String label, IconData icon) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, size: 40, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
      ],
    );
  }
}

/// A generic on-brand feature panel for sections without dedicated mock
/// tables yet (AI Detection, Discovery settings, Coupons, etc). Shows an
/// icon header, description, and a few illustrative rows so the screen
/// still feels complete rather than empty.
class FeaturePanelScreen extends StatelessWidget {
  const FeaturePanelScreen({
    super.key,
    required this.icon,
    required this.heading,
    required this.description,
    required this.rows,
  });

  final IconData icon;
  final String heading;
  final String description;
  final List<FeatureRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashedContainer(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accentMagenta.withValues(alpha:0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.accentMagenta, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(heading, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        DashedContainer(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < rows.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: i == rows.length - 1 ? Colors.transparent : AppColors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(rows[i].icon, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(rows[i].title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                      ),
                      Text(rows[i].value, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class FeatureRow {
  final IconData icon;
  final String title;
  final String value;
  const FeatureRow(this.icon, this.title, this.value);
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return DashedContainer(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, size: 34, color: AppColors.textMuted),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
