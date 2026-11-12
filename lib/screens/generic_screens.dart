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
                    ClipOval(
                      child: Container(
                        width: 32,
                        height: 32,
                        color: AppColors.surfaceAlt,
                        child: (v.profilePhotoUrl != null && v.profilePhotoUrl!.isNotEmpty)
                            ? _buildAdaptiveImage(
                                v.profilePhotoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(
                                    v.name.substring(0, 1),
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  v.name.substring(0, 1),
                                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                      ),
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

Widget _buildAdaptiveImage(
  String path, {
  BoxFit fit = BoxFit.cover,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder,
}) {
  if (path.startsWith('assets/')) {
    return Image.asset(
      path,
      fit: fit,
      errorBuilder: errorBuilder != null ? (c, e, s) => errorBuilder(c, e, s) : null,
    );
  }
  return Image.network(
    path,
    fit: fit,
    loadingBuilder: loadingBuilder,
    errorBuilder: errorBuilder,
  );
}

/// Selfie-vs-profile-photo comparison dialog with functional
/// Approve / Reject buttons wired to [AdminStore].
class _VerificationCompareDialog extends StatelessWidget {
  const _VerificationCompareDialog({required this.record});
  final VerificationRecord record;

  @override
  Widget build(BuildContext context) {
    final isMatch = record.id <= 2;
    final matchConfidence = isMatch ? (record.id == 1 ? '98.6%' : '99.2%') : (record.id == 3 ? '24.8%' : '18.3%');
    final matchColor = isMatch ? AppColors.success : AppColors.danger;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.borderStrong)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(record.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: matchColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: matchColor.withValues(alpha: 0.5), width: 0.8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(isMatch ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 11, color: matchColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    isMatch ? 'Match ($matchConfidence)' : 'Mismatch ($matchConfidence)',
                                    style: TextStyle(color: matchColor, fontSize: 10.5, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('${record.profileIdLabel} · submitted ${record.submittedAgo}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _photoBox(
                      context: context,
                      label: 'Profile Photo',
                      subtitle: 'Primary Photo',
                      imageUrl: record.profilePhotoUrl,
                      icon: Icons.account_circle_rounded,
                      badgeColor: AppColors.accentCyan,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _photoBox(
                      context: context,
                      label: 'Live Selfie',
                      subtitle: isMatch ? 'Verified Facial Match' : 'Possible Face Mismatch',
                      imageUrl: record.selfieUrl,
                      icon: Icons.camera_alt_rounded,
                      badgeColor: matchColor,
                      isSelfie: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isMatch ? AppColors.success.withValues(alpha: 0.08) : AppColors.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: matchColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(isMatch ? Icons.verified_user_rounded : Icons.warning_amber_rounded, size: 16, color: matchColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isMatch
                            ? 'AI Face Match: $matchConfidence match. Live selfie accurately matches profile photo.'
                            : 'AI Face Match: $matchConfidence similarity (Mismatch). Live selfie does not appear to match profile photo.',
                        style: TextStyle(
                          color: isMatch ? AppColors.textPrimary : AppColors.danger,
                          fontSize: 12,
                          fontWeight: isMatch ? FontWeight.w500 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.danger),
                        foregroundColor: AppColors.danger,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        adminStore.rejectVerification(record);
                        Navigator.of(context).pop();
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Reject', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        adminStore.approveVerification(record);
                        Navigator.of(context).pop();
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Approve', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
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

  Widget _photoBox({
    required BuildContext context,
    required String label,
    required String subtitle,
    required String? imageUrl,
    required IconData icon,
    required Color badgeColor,
    bool isSelfie = false,
  }) {
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          cursor: hasImage ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: hasImage ? () => _showImagePreview(context, '$label - ${record.name}', imageUrl) : null,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelfie ? badgeColor.withValues(alpha: 0.45) : AppColors.borderStrong,
                    width: isSelfie ? 1.5 : 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasImage)
                      _buildAdaptiveImage(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: AppColors.surfaceAlt,
                            child: const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.accentMagenta,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(icon, size: 42, color: AppColors.textMuted),
                          );
                        },
                      )
                    else
                      Center(
                        child: Icon(icon, size: 42, color: AppColors.textMuted),
                      ),
                    // Badge on top-left
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: badgeColor.withValues(alpha: 0.6), width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 10, color: badgeColor),
                            const SizedBox(width: 4),
                            Text(
                              label,
                              style: TextStyle(
                                color: badgeColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Fullscreen preview hint on bottom-right
                    if (hasImage)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.fullscreen_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
        Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }

  void _showImagePreview(BuildContext context, String title, String imageUrl) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 620),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderStrong),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
                Flexible(
                  child: Container(
                    color: Colors.black,
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    child: _buildAdaptiveImage(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.accentMagenta),
                        );
                      },
                      errorBuilder: (ctx, err, stack) => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Icon(Icons.broken_image_rounded, size: 48, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
