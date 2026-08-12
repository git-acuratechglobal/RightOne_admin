import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/auth_state.dart';
import '../screens/chats_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/generic_screens.dart';
import '../screens/login_screen.dart';
import '../screens/matches_screen.dart';
import '../screens/ranking_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/subscriptions_screen.dart';
import '../screens/tickets_screen.dart';
import '../screens/two_factor_screen.dart';
import '../screens/users_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_scaffold.dart';
import '../data/admin_store.dart';

GoRoute _page(
  String path,
  String title,
  Widget child, {
  String? subtitle,
  Widget? trailing,
}) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) => NoTransitionPage(
      child: AdminPageContent(
        key: ValueKey(path),
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        child: child,
      ),
    ),
  );
}

final appRouter = GoRouter(
  initialLocation: '/login',
  refreshListenable: authState,
  redirect: (context, state) {
    final loggedIn = authState.isLoggedIn;
    final goingToLogin = state.matchedLocation == '/login';
    final goingToVerify = state.matchedLocation == '/verify';

    if (!loggedIn && !goingToLogin) return '/login';
    if (loggedIn && goingToLogin) return '/dashboard';
    if (loggedIn && adminStore.twoFactorRequired && !authState.twoFactorPassed && !goingToVerify) {
      return '/verify';
    }
    if (loggedIn && goingToVerify && (!adminStore.twoFactorRequired || authState.twoFactorPassed)) {
      return '/dashboard';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/verify', builder: (context, state) => const TwoFactorScreen()),

    ShellRoute(
      builder: (context, state, child) {
        return AdminScaffold(
          currentRoute: state.matchedLocation,
          child: child,
        );
      },
      routes: [
        _page(
          '/dashboard',
          'Dashboard',
          const DashboardScreen(),
          subtitle: "Welcome back, Admin! Here's what's happening on RightONE.",
          trailing: const DashboardDateRangeButton(),
        ),

        _page('/users', 'All Users', const UsersScreen()),
        _page(
          '/users/online',
          'Online Users',
          UserSegmentScreen(filter: (u) => u.status == 'Active', emptyLabel: 'No users online right now.'),
        ),
        _page(
          '/users/premium',
          'Premium Users',
          UserSegmentScreen(filter: (u) => u.karma >= 85, emptyLabel: 'No premium users yet.'),
        ),
        _page(
          '/users/blocked',
          'Blocked Users',
          UserSegmentScreen(filter: (u) => u.status == 'Suspended', emptyLabel: 'No blocked users.'),
        ),

        _page(
          '/verification/pending',
          'Pending Verification',
          const VerificationQueueScreen(status: 'Pending', statusColorValue: AppColors.warning),
        ),
        _page(
          '/verification/approved',
          'Approved Verifications',
          const VerificationQueueScreen(status: 'Approved', statusColorValue: AppColors.success),
        ),
        _page(
          '/verification/rejected',
          'Rejected Verifications',
          const VerificationQueueScreen(status: 'Rejected', statusColorValue: AppColors.danger),
        ),
        _page(
          '/verification/documents',
          'Verification Documents',
          const FeaturePanelScreen(
            icon: Icons.description_outlined,
            heading: 'Submitted Documents',
            description: 'ID cards, selfies, and supporting documents submitted for identity verification.',
            rows: [
              FeatureRow(Icons.face_retouching_natural_outlined, 'Selfie verification photos', '398 files'),
              FeatureRow(Icons.description_outlined, 'Proof of address', '76 files'),
            ],
          ),
        ),

        _page('/reports', 'Reports', const ReportsScreen()),
        _page(
          '/moderation/ai-detection',
          'AI Detection',
          const FeaturePanelScreen(
            icon: Icons.psychology_outlined,
            heading: 'AI Content Detection',
            description: 'Automated flags for AI-generated photos, bot behavior, and suspicious messaging patterns.',
            rows: [
            ],
          ),
        ),
        _page(
          '/moderation/hidden-profiles',
          'Hidden Profiles',
          const FeaturePanelScreen(
            icon: Icons.visibility_off_outlined,
            heading: 'Hidden Profiles',
            description: 'Profiles temporarily hidden from discovery pending manual review.',
            rows: [
              FeatureRow(Icons.visibility_off_outlined, 'Self-hidden by user', '24 profiles'),
              FeatureRow(Icons.gpp_maybe_outlined, 'Hidden pending review', '9 profiles'),
            ],
          ),
        ),
        _page(
          '/moderation/suspended',
          'Suspended Accounts',
          UserSegmentScreen(filter: (u) => u.status == 'Suspended', emptyLabel: 'No suspended accounts.'),
        ),

        _page(
          '/discovery/interests',
          'Interests',
          const FeaturePanelScreen(
            icon: Icons.interests_outlined,
            heading: 'Interest Tags',
            description: 'Tags users can add to their profile to improve match relevance.',
            rows: [
              FeatureRow(Icons.local_cafe_outlined, 'Coffee & Cafes', '12.4k users'),
              FeatureRow(Icons.hiking_outlined, 'Hiking & Outdoors', '9.8k users'),
              FeatureRow(Icons.music_note_outlined, 'Live Music', '8.1k users'),
              FeatureRow(Icons.movie_outlined, 'Movies & TV', '15.2k users'),
            ],
          ),
        ),
        _page(
          '/discovery/categories',
          'Categories',
          const FeaturePanelScreen(
            icon: Icons.category_outlined,
            heading: 'Discovery Categories',
            description: 'Top-level categories used to organize discovery and search.',
            rows: [
              FeatureRow(Icons.favorite_border_rounded, 'Dating', '62% of users'),
              FeatureRow(Icons.groups_outlined, 'Friendship', '24% of users'),
            ],
          ),
        ),
        _page(
          '/discovery/distance',
          'Distance Settings',
          const FeaturePanelScreen(
            icon: Icons.social_distance_outlined,
            heading: 'Distance & Location',
            description: 'Global defaults for maximum match distance and location precision.',
            rows: [
              FeatureRow(Icons.social_distance_outlined, 'Default max distance', '50 km'),
              FeatureRow(Icons.location_on_outlined, 'Location precision', 'City-level'),
              FeatureRow(Icons.public_outlined, 'Cross-country matching', 'Disabled'),
            ],
          ),
        ),
        _page(
          '/discovery/preferences',
          'Preferences',
          const FeaturePanelScreen(
            icon: Icons.tune_rounded,
            heading: 'Default Match Preferences',
            description: 'Baseline discovery preferences applied to new accounts.',
            rows: [
              FeatureRow(Icons.cake_outlined, 'Default age range', '21 – 35'),
              FeatureRow(Icons.wc_rounded, 'Show me', 'Everyone'),
              FeatureRow(Icons.verified_outlined, 'Verified profiles only', 'Off'),
            ],
          ),
        ),

        _page('/matches', 'Matches', const MatchesScreen()),
        _page('/chats', 'Chats', const ChatsScreen()),

        _page('/plans', 'Plans', const SubscriptionsScreen()),
        _page(
          '/purchases',
          'Purchases',
          const FeaturePanelScreen(
            icon: Icons.receipt_long_outlined,
            heading: 'Recent Purchases',
            description: 'One-off purchases such as boosts, super likes, and profile highlights.',
            rows: [
              FeatureRow(Icons.flash_on_outlined, 'Boosts purchased', '318 this month'),
              FeatureRow(Icons.star_outline_rounded, 'Super Likes purchased', '742 this month'),
              FeatureRow(Icons.workspace_premium_outlined, 'Premium upgrades', '96 this month'),
            ],
          ),
        ),
        _page(
          '/coupons',
          'Coupons',
          const FeaturePanelScreen(
            icon: Icons.confirmation_number_outlined,
            heading: 'Active Coupons',
            description: 'Promotional codes currently redeemable by users.',
            rows: [
            ],
          ),
        ),

        _page('/support/tickets', 'Support Tickets', const TicketsScreen()),
        _page('/insights/ranking', 'Internal Ranking', const RankingScreen()),

        _page('/settings', 'Settings', const SettingsScreen()),
      ],
    ),
  ],
  errorBuilder: (context, state) => const Scaffold(
    body: Center(child: Text('Page not found', style: TextStyle(color: Colors.white))),
  ),
);
