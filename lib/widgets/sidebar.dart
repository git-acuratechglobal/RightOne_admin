import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/admin_store.dart';
import '../theme/app_theme.dart';
import 'dashed_container.dart';

class NavItem {
  final String label;
  final IconData icon;
  final String route;
  final int? badge;
  final Color? badgeColor;

  const NavItem(this.label, this.icon, this.route, {this.badge, this.badgeColor});
}

class NavGroup {
  final String? title;
  final List<NavItem> items;

  const NavGroup(this.title, this.items);
}

const List<NavGroup> kNavGroups = [
  NavGroup(null, [
    NavItem('Dashboard', Icons.grid_view_rounded, '/dashboard'),
  ]),
  NavGroup('Users', [
    NavItem('All Users', Icons.people_alt_outlined, '/users'),
    NavItem('Online Users', Icons.wifi_tethering_rounded, '/users/online'),
    NavItem('Premium Users', Icons.star_border_rounded, '/users/premium'),
    NavItem('Blocked Users', Icons.block_rounded, '/users/blocked'),
  ]),
  NavGroup('Verification', [
    NavItem('Pending', Icons.hourglass_empty_rounded, '/verification/pending', badgeColor: AppColors.accentMagenta),
    NavItem('Approved', Icons.check_circle_outline_rounded, '/verification/approved'),
    NavItem('Rejected', Icons.cancel_outlined, '/verification/rejected'),
    NavItem('Documents', Icons.description_outlined, '/verification/documents'),
  ]),
  NavGroup('Moderation', [
    NavItem('Reports', Icons.flag_outlined, '/reports', badgeColor: AppColors.danger),
    NavItem('AI Detection', Icons.psychology_outlined, '/moderation/ai-detection'),
    NavItem('Hidden Profiles', Icons.visibility_off_outlined, '/moderation/hidden-profiles'),
    NavItem('Suspended', Icons.gpp_bad_outlined, '/moderation/suspended'),
  ]),
  NavGroup('Discovery', [
    NavItem('Interests', Icons.interests_outlined, '/discovery/interests'),
    NavItem('Categories', Icons.category_outlined, '/discovery/categories'),
    NavItem('Distance Settings', Icons.social_distance_outlined, '/discovery/distance'),
    NavItem('Preferences', Icons.tune_rounded, '/discovery/preferences'),
  ]),
  NavGroup('Subscriptions', [
    NavItem('Plans', Icons.shopping_cart_outlined, '/plans'),
    NavItem('Purchases', Icons.receipt_long_outlined, '/purchases'),
    NavItem('Coupons', Icons.confirmation_number_outlined, '/coupons'),
  ]),
  NavGroup('Support', [
    NavItem('Tickets', Icons.confirmation_num_outlined, '/support/tickets'),
  ]),
  NavGroup('Insights', [
    NavItem('Internal Ranking', Icons.leaderboard_outlined, '/insights/ranking'),
  ]),
  NavGroup(null, [
    NavItem('Settings', Icons.settings_outlined, '/settings'),
  ]),
];

class Sidebar extends StatelessWidget {
  const Sidebar({super.key, required this.currentRoute, this.onNavigate});

  final String currentRoute;

  /// Called right after a nav item routes somewhere new. Used on mobile to
  /// auto-close the drawer overlay as soon as the admin picks a page.
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: adminStore,
      builder: (context, _) {
        return DashedContainer(
          sides: const {DashedSide.right},
          padding: EdgeInsets.zero,
          child: SizedBox(
            width: 240,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    children: [
                      for (final group in kNavGroups) ...[
                        if (group.title != null) _GroupLabel(group.title!),
                        for (final item in group.items)
                          _SidebarTile(
                            item: item,
                            selected: currentRoute == item.route,
                            onNavigate: onNavigate,
                          ),
                        const SizedBox(height: 6),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: DashedContainer(
                    backgroundColor: AppColors.surfaceAlt,
                    padding: const EdgeInsets.all(14),
                    radius: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Get Started',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.accentMagenta),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '3/6 steps completed',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: const LinearProgressIndicator(
                            value: 0.5,
                            minHeight: 6,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation(AppColors.accentMagenta),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({required this.item, required this.selected, this.onNavigate});

  final NavItem item;
  final bool selected;
  final VoidCallback? onNavigate;

  int? get _resolvedBadge {
    if (item.route == '/verification/pending') {
      final count = adminStore.pendingVerificationsCount;
      return count > 0 ? count : null;
    }
    if (item.route == '/reports') {
      final count = adminStore.pendingReportsCount;
      return count > 0 ? count : null;
    }
    return item.badge;
  }

  @override
  Widget build(BuildContext context) {
    final badgeValue = _resolvedBadge;
    return InkWell(
      onTap: () {
        context.go(item.route);
        onNavigate?.call();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [
                    AppColors.accentMagenta.withValues(alpha:0.22),
                    AppColors.accentMagenta.withValues(alpha:0.02),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          border: Border.all(
            color: selected ? AppColors.accentMagenta.withValues(alpha:0.4) : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 17,
              color: selected ? AppColors.accentMagenta : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (badgeValue != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: (item.badgeColor ?? AppColors.accentMagenta).withValues(alpha:0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$badgeValue',
                  style: TextStyle(
                    color: item.badgeColor ?? AppColors.accentMagenta,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
