import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/auth_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'app_logo.dart';
import 'dashed_container.dart';


class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.onMenuTap,
    this.sidebarWidthOverride,
    this.isMobile = false,
  });

  final VoidCallback? onMenuTap;

  final double? sidebarWidthOverride;

  /// When true, renders a compact layout for narrow/mobile viewports: a
  /// fixed small logo slot (the sidebar is an overlay drawer, not an
  /// inline pusher, so this area never needs to grow/shrink with it),
  /// a search icon instead of the full search bar, and a trimmed set of
  /// header actions so nothing overflows the screen width.
  final bool isMobile;

  static const double sidebarWidth = 240;
  static const double mobileLeftWidth = 60;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  void _openMobileSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
        ),
        child: const _SearchField(autofocus: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leftWidth = isMobile ? mobileLeftWidth : (sidebarWidthOverride ?? sidebarWidth);
    return DashedContainer(
      sides: const {DashedSide.bottom},
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 71,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: leftWidth,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: leftWidth < 80
                    ? const AppLogo(iconSize: 32, wordmarkFontSize: 19, showWordmark: false)
                    : const AppLogo(iconSize: 34, wordmarkFontSize: 19),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 24),
                child: Row(
                  children: [
                    _IconGhostButton(icon: Icons.menu_rounded, onTap: onMenuTap ?? () {}),
                    SizedBox(width: isMobile ? 10 : 16),
                    if (isMobile)
                      _IconGhostButton(
                        icon: Icons.search_rounded,
                        onTap: () => _openMobileSearch(context),
                      )
                    else
                      const _SearchField(),
                    const Spacer(),
                    if (!isMobile) ...[
                      _IconGhostButton(icon: Icons.dark_mode_outlined, onTap: () {}),
                      const SizedBox(width: 8),
                    ],
                    const _NotificationsButton(),
                    const SizedBox(width: 12),
                    _AdminMenu(compact: isMobile),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({this.autofocus = false});

  final bool autofocus;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Container(
        height: 40,
                          padding: const EdgeInsets.only(left: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          border: Border.all(color: AppColors.borderStrong),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Search users, ID, email...',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                onSubmitted: (value) {
                  if (value.trim().isEmpty) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Searching for "$value"… (demo — no backend wired up yet)'),
                      backgroundColor: AppColors.surfaceAlt,
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class _IconGhostButton extends StatelessWidget {
  const _IconGhostButton({required this.icon, required this.onTap, this.badge});

  final IconData icon;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          border: Border.all(color: AppColors.borderStrong),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 19, color: AppColors.textSecondary),
            if (badge != null)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: const BoxDecoration(
                    color: AppColors.accentMagenta,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DummyNotification {
  final String title;
  final String subtitle;
  final IconData icon;
  const _DummyNotification(this.title, this.subtitle, this.icon);
}

const _kDummyNotifications = [
  _DummyNotification('New report filed', 'A user reported a profile for spam', Icons.flag_rounded),
  _DummyNotification('6 reports pending', 'Moderation queue needs review', Icons.shield_outlined),
  _DummyNotification('4 verifications pending', 'New ID submissions to review', Icons.badge_outlined),
  _DummyNotification('Revenue milestone', 'Monthly revenue crossed \$12,000', Icons.trending_up_rounded),
  _DummyNotification('New signup spike', '1,256 signups this week', Icons.person_add_alt_1_rounded),
];

class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      color: AppColors.surface,
      offset: const Offset(0, 46),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.borderStrong),
        borderRadius: BorderRadius.circular(12),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem<void>(
          enabled: false,
          child: Text(
            'Notifications',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
        for (final n in _kDummyNotifications)
          PopupMenuItem<void>(
            child: SizedBox(
              width: 260,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(n.icon, size: 16, color: AppColors.accentMagenta),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w600)),
                        Text(n.subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
      child: const _IconGhostButtonStatic(icon: Icons.notifications_none_rounded, badge: 5),
    );
  }
}

class _IconGhostButtonStatic extends StatelessWidget {
  const _IconGhostButtonStatic({required this.icon, this.badge});
  final IconData icon;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        border: Border.all(color: AppColors.borderStrong),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, size: 19, color: AppColors.textSecondary),
          if (badge != null)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: const BoxDecoration(
                  color: AppColors.accentMagenta,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AdminMenu extends StatelessWidget {
  const _AdminMenu({this.compact = false});

  /// When true, shows just the avatar (no name/role/chevron) to save
  /// horizontal space on narrow screens.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: AppColors.surface,
      offset: const Offset(0, 46),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.borderStrong),
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (value) {
        if (value == 'logout') {
          authState.logout();
          context.go('/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile page — coming soon.')),
          );
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'profile',
          child: Text('Profile', style: TextStyle(color: AppColors.textPrimary)),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Text('Logout', style: TextStyle(color: AppColors.danger)),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Text(
              (authState.adminName.isEmpty ? 'A' : authState.adminName[0]).toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  authState.adminName.isEmpty ? 'Admin' : capitalize(authState.adminName),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const Text(
                  'Super Admin',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textSecondary),
          ],
        ],
      ),
    );
  }
}
