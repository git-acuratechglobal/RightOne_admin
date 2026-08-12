import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/dashed_container.dart';
import '../widgets/mini_charts.dart';
import '../widgets/world_dots_map.dart';

/// Growth-chart time ranges the "This Month" dropdown can switch between.
/// Purely a UI demo for now — each range maps to a differently-scaled
/// slice of the same dummy dataset, no backend involved.
enum GrowthRange { week, month, quarter, year }

extension on GrowthRange {
  String get label => switch (this) {
        GrowthRange.week => 'This Week',
        GrowthRange.month => 'This Month',
        GrowthRange.quarter => 'This Quarter',
        GrowthRange.year => 'This Year',
      };
}

/// The top-right date-range control on the Dashboard header. Purely a UI
/// demo — selecting a preset just updates the displayed label for now.
class DashboardDateRangeButton extends StatefulWidget {
  const DashboardDateRangeButton({super.key});

  @override
  State<DashboardDateRangeButton> createState() => _DashboardDateRangeButtonState();
}

class _DashboardDateRangeButtonState extends State<DashboardDateRangeButton> {
  static const _presets = [
    'May 25 – Jun 25, 2026',
    'Last 7 days',
    'Last 30 days',
    'This month',
    'This year',
  ];
  String _selected = _presets.first;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: AppColors.surface,
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.borderStrong),
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (value) => setState(() => _selected = value),
      itemBuilder: (context) => [
        for (final p in _presets)
          PopupMenuItem(value: p, child: Text(p, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          border: Border.all(color: AppColors.borderStrong),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(_selected, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  GrowthRange _growthRange = GrowthRange.month;

  /// Dummy scaling per range so the chart visibly "reacts" to the picker
  /// even though it's all still mock data.
  List<double> _scaled(List<double> base) {
    switch (_growthRange) {
      case GrowthRange.week:
        return base.sublist(base.length - 6);
      case GrowthRange.month:
        return base;
      case GrowthRange.quarter:
        return [for (final v in base) v * 1.6];
      case GrowthRange.year:
        return [for (final v in base) v * 3.2];
    }
  }

  void _showDummyAction(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.surfaceAlt),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final isNarrow = w < 760;
        final isMid = w < 1180;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row of 5 stat cards
            _StatRow(isNarrow: isNarrow),
            const SizedBox(height: 20),

            // Dating vs Friends split + Token purchases + Premium subscribers
            isNarrow
                ? Column(
                    children: [
                      _datingFriendsCard(),
                      const SizedBox(height: 16),
                      _tokenPurchasesCard(),
                      const SizedBox(height: 16),
                      _premiumSubscribersCard(),
                    ],
                  )
                : IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _datingFriendsCard()),
                        const SizedBox(width: 16),
                        Expanded(child: _tokenPurchasesCard()),
                        const SizedBox(width: 16),
                        Expanded(child: _premiumSubscribersCard()),
                      ],
                    ),
                  ),
            const SizedBox(height: 20),

            // User Growth (big) + Gender Ratio + Live Activity
            isMid
                ? Column(
                    children: [
                      _userGrowthCard(),
                      const SizedBox(height: 16),
                      _genderRatioCard(),
                      const SizedBox(height: 16),
                      _liveActivityCard(),
                    ],
                  )
                : IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 5, child: _userGrowthCard()),
                        const SizedBox(width: 16),
                        Expanded(flex: 3, child: _genderRatioCard()),
                        const SizedBox(width: 16),
                        Expanded(flex: 3, child: _liveActivityCard()),
                      ],
                    ),
                  ),
            const SizedBox(height: 20),

            // New Users, Pending Verification, Online Users, Top Locations
            isNarrow
                ? Column(
                    children: [
                      _newUsersCard(),
                      const SizedBox(height: 16),
                      _pendingVerificationCard(),
                      const SizedBox(height: 16),
                      _onlineUsersCard(),
                      const SizedBox(height: 16),
                      _topLocationsCard(),
                    ],
                  )
                : isMid
                    ? Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _newUsersCard()),
                              const SizedBox(width: 16),
                              Expanded(child: _pendingVerificationCard()),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _onlineUsersCard()),
                              const SizedBox(width: 16),
                              Expanded(child: _topLocationsCard()),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _newUsersCard()),
                          const SizedBox(width: 16),
                          Expanded(child: _pendingVerificationCard()),
                          const SizedBox(width: 16),
                          Expanded(child: _onlineUsersCard()),
                          const SizedBox(width: 16),
                          Expanded(child: _topLocationsCard()),
                        ],
                      ),
          ],
        );
      },
    );
  }

  // ---- User Growth -----------------------------------------------------
  Widget _userGrowthCard() {
    final totalSeries = _scaled(MockData.userGrowthTotal);
    final newSeries = _scaled(MockData.userGrowthNew);
    final xLabels = switch (_growthRange) {
      GrowthRange.week => const ['Jun 20', 'Jun 21', 'Jun 22', 'Jun 23', 'Jun 24', 'Jun 25'],
      GrowthRange.month => const ['May 25', 'Jun 01', 'Jun 08', 'Jun 15', 'Jun 22', 'Jun 25'],
      GrowthRange.quarter => const ['Apr', 'May', 'Jun'],
      GrowthRange.year => const ['Q1', 'Q2', 'Q3', 'Q4'],
    };

    return DashedContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'User Growth',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
              ),
              PopupMenuButton<GrowthRange>(
                color: AppColors.surface,
                offset: const Offset(0, 40),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: AppColors.borderStrong),
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (range) => setState(() => _growthRange = range),
                itemBuilder: (context) => [
                  for (final r in GrowthRange.values)
                    PopupMenuItem(value: r, child: Text(r.label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    border: Border.all(color: AppColors.borderStrong),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_growthRange.label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Row(
            children: [
              _LegendDot(color: AppColors.accentMagenta, label: 'Total Users'),
              SizedBox(width: 18),
              _LegendDot(color: AppColors.accentCyan, label: 'New Users'),
            ],
          ),
          const SizedBox(height: 14),
          LineChartWidget(
            height: 200,
            xLabels: xLabels,
            series: [
              LineSeries(
                values: totalSeries,
                color: AppColors.accentMagenta,
                badgeLabel: (v) => formatInt(v * 1000),
              ),
              LineSeries(
                values: newSeries,
                color: AppColors.accentCyan,
                badgeLabel: (v) => formatInt(v * 1000),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Gender Ratio ------------------------------------------------------
  Widget _genderRatioCard() {
    return DashedContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gender Ratio',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          Center(
            child: DonutChartWidget(
              segments:  [
                DonutSegment(MockData.genderMale.toDouble(), AppColors.accentMagenta),
                DonutSegment(MockData.genderFemale.toDouble(), AppColors.accentCyan),
                DonutSegment(MockData.genderOther.toDouble(), const Color(0xFF8A6CFF)),
              ],
              centerValue: '${MockData.genderMale}%',
              centerLabel: 'Male',
              size: 176,
              strokeWidth: 22,
            ),
          ),
          const SizedBox(height: 20),
          const _GenderLegendRow(
            color: AppColors.accentMagenta,
            percent: '${MockData.genderMale}%',
            label: 'Male Users',
            count: '${MockData.maleUsers}',
          ),
          const SizedBox(height: 12),
          const _GenderLegendRow(
            color: AppColors.accentCyan,
            percent: '${MockData.genderFemale}%',
            label: 'Female Users',
            count: '2m ago',
          ),
          const SizedBox(height: 12),
          const _GenderLegendRow(
            color: Color(0xFF8A6CFF),
            percent: '${MockData.genderOther}%',
            label: 'Other',
            count: '${MockData.otherUsers}',
          ),
        ],
      ),
    );
  }

  // ---- Live Activity -------------------------------------------------
  Widget _liveActivityCard() {
    return DashedContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Activity',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 8, color: AppColors.danger),
                  SizedBox(width: 6),
                  Text('Live', style: TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final event in MockData.liveActivity)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.surfaceAlt,
                    child: Text(
                      event.name.substring(0, 1),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.name,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          event.action,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _activityColor(event.icon).withValues(alpha:0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_activityIcon(event.icon), size: 14, color: _activityColor(event.icon)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static IconData _activityIcon(IconIdentifier id) {
    switch (id) {
      case IconIdentifier.like:
        return Icons.favorite_rounded;
      case IconIdentifier.match:
        return Icons.autorenew_rounded;
      case IconIdentifier.message:
        return Icons.chat_bubble_rounded;
      case IconIdentifier.join:
        return Icons.person_add_alt_1_rounded;
      case IconIdentifier.upload:
        return Icons.upload_rounded;
    }
  }

  static Color _activityColor(IconIdentifier id) {
    switch (id) {
      case IconIdentifier.like:
        return AppColors.accentMagenta;
      case IconIdentifier.match:
        return AppColors.accentCyan;
      case IconIdentifier.message:
        return AppColors.accentCyan2;
      case IconIdentifier.join:
        return AppColors.accentMagenta;
      case IconIdentifier.upload:
        return AppColors.accentCyan;
    }
  }

  // ---- New Users -----------------------------------------------------
  Widget _newUsersCard() {
    return DashedContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader('New Users', viewAllRoute: '/users'),
          const SizedBox(height: 12),
          for (final s in MockData.newSignupsRecent)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.surfaceAlt,
                        child: Text(s.name.substring(0, 1), style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.surface, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(s.email, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                      ],
                    ),
                  ),
                  Text(s.timeAgo, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ---- Pending Verification -------------------------------------------
  Widget _pendingVerificationCard() {
    return DashedContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader('Pending Verification', viewAllRoute: '/verification/pending'),
          const SizedBox(height: 12),
          for (final v in MockData.pendingVerifications)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.surfaceAlt,
                    child: Text(v.name.substring(0, 1), style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(v.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                        Text('Submitted ${v.submittedAgo}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderStrong),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.badge_outlined, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('${v.documentCount}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ---- Online Users -----------------------------------------------------
  Widget _onlineUsersCard() {
    return DashedContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader('Online Users', viewAllRoute: '/users/online'),
          const SizedBox(height: 10),
          const Text(
            '${MockData.onlineNow}',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 30, fontWeight: FontWeight.w800),
          ),
          const Text('Users online now', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(height: 16),
          SizedBox(
            height: 34,
            child: Stack(
              children: [
                for (int i = 0; i < 5; i++)
                  Positioned(
                    left: i * 22.0,
                    child: CircleAvatar(
                      radius: 17,
                      backgroundColor: AppColors.surface,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: i == 4 ? AppColors.surfaceAlt : AppColors.accentMagenta.withValues(alpha:0.25),
                        child: i == 4
                            ? const Text('+156', style: TextStyle(color: AppColors.textSecondary, fontSize: 9, fontWeight: FontWeight.w700))
                            : Text('${i + 1}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 11)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const VerticalBarChartWidget(
            height: 80,
            labelEvery: 2,
            data: {
              '12AM': 40, '3AM': 22, '6AM': 30, '9AM': 55, '12PM': 68, '3PM': 74, '6PM': 90, '9PM': 60, '11PM': 45,
            },
          ),
        ],
      ),
    );
  }

  // ---- Top Locations -----------------------------------------------------
  Widget _topLocationsCard() {
    return DashedContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader('Top Locations', viewAllRoute: '/users'),
          const SizedBox(height: 10),
          const WorldDotsMap(
            height: 100,
            markers: [
              Offset(0.16, 0.34), // United States
              Offset(0.60, 0.46), // India
              Offset(0.46, 0.24), // United Kingdom
              Offset(0.14, 0.24), // Canada
            ],
          ),
          const SizedBox(height: 10),
          for (final loc in MockData.topLocations)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(loc.country, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12.5)),
                      Row(
                        children: [
                          Text('${loc.users}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          Text('${loc.percent}%', style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: loc.percent / 25,
                      minHeight: 5,
                      backgroundColor: AppColors.surfaceAlt,
                      valueColor: const AlwaysStoppedAnimation(AppColors.accentMagenta),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _datingFriendsCard() {
    const data = MockData.datingVsFriends;
    final total = data.values.fold<int>(0, (a, b) => a + b);
    final colors = {
      'Dating': AppColors.accentMagenta,
      'Friends': AppColors.accentCyan,
      'Both': AppColors.gold,
    };
    return DashedContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader('Dating vs Friends'),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in data.entries)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: _LegendDot(color: colors[entry.key]!, label: '${entry.key} · ${entry.value}%'),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              DonutChartWidget(
                segments: [
                  for (final entry in data.entries) DonutSegment(entry.value.toDouble(), colors[entry.key]!),
                ],
                centerValue: '$total%',
                centerLabel: 'Mode split',
                size: 140,
                strokeWidth: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tokenPurchasesCard() {
    return DashedContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader('Token Purchases', viewAllRoute: '/purchases'),
          const SizedBox(height: 4),
          Text(
            formatInt(MockData.tokenPurchases7d.last.round()),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const Text('tokens purchased today', style: TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
          const Spacer(),
          const SizedBox(height: 14),
          const SparklineWidget(values: MockData.tokenPurchases7d, color: AppColors.gold, height: 60),
        ],
      ),
    );
  }

  Widget _premiumSubscribersCard() {
    return DashedContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader('Premium Subscribers', viewAllRoute: '/plans'),
          const SizedBox(height: 4),
          Text(
            formatInt(MockData.premiumSubscribersTotal),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(MockData.premiumSubscribersDelta, style: TextStyle(color: AppColors.success, fontSize: 12)),
          const Spacer(),
          const SizedBox(height: 14),
          const SparklineWidget(values: MockData.matchesPerDay, color: AppColors.accentMagenta, height: 60),
        ],
      ),
    );
  }

  Widget _cardHeader(String title, {String? viewAllRoute}) {
    return Builder(builder: (context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
          InkWell(
            onTap: () {
              if (viewAllRoute != null) {
                context.go(viewAllRoute);
              } else {
                _showDummyAction(context, '$title — view all coming soon.');
              }
            },
            child: const Text('View All', style: TextStyle(color: AppColors.accentMagenta, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      );
    });
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.isNarrow});
  final bool isNarrow;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _MiniStatCard(
        icon: Icons.people_alt_rounded,
        iconColor: AppColors.accentMagenta,
        label: 'Total Users',
        value: formatInt(MockData.totalUsers),
        delta: '↑ 8.4% from last month',
        deltaPositive: true,
        sparkColor: AppColors.accentMagenta,
        sparkValues: MockData.userGrowthTotal,
      ),
      _MiniStatCard(
        icon: Icons.bolt_rounded,
        iconColor: AppColors.accentCyan,
        label: 'Active Today',
        value: formatInt(MockData.activeToday),
        delta: '↑ 12.6% from last week',
        deltaPositive: true,
        sparkColor: AppColors.accentCyan,
        sparkValues: const [4, 5, 4.5, 6, 6.5, 6.2, 7, 7.4],
      ),
      _MiniStatCard(
        icon: Icons.person_add_alt_1_rounded,
        iconColor: AppColors.accentMagenta,
        label: 'New registrations',
        value: formatInt(MockData.newSignups),
        delta: '↑ 14.2% from last week',
        deltaPositive: true,
        sparkColor: AppColors.accentMagenta,
        sparkValues: const [3, 4, 3.6, 4.2, 4.8, 4.4, 5, 5.4],
      ),
      _MiniStatCard(
        icon: Icons.shield_outlined,
        iconColor: const Color(0xFF8A6CFF),
        label: 'Reports',
        value: formatInt(MockData.reportsCount),
        delta: '↓ 4.3% from last week',
        deltaPositive: false,
        sparkColor: const Color(0xFF8A6CFF),
        sparkValues: const [8, 7.4, 7.8, 7, 6.6, 6.9, 6.3, 6],
      ),
      _MiniStatCard(
        icon: Icons.attach_money_rounded,
        iconColor: AppColors.accentCyan,
        label: 'Revenue',
        value: '\$${formatInt(MockData.revenue)}',
        delta: '↑ 18.7% from last month',
        deltaPositive: true,
        sparkColor: AppColors.accentCyan,
        sparkValues: const [5, 5.6, 6, 6.4, 7, 7.8, 8.4, 9.2],
      ),
    ];

    if (isNarrow) {
      return Column(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            cards[i],
            if (i != cards.length - 1) const SizedBox(height: 14),
          ],
        ],
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      final perRow = constraints.maxWidth < 1180 ? 3 : 5;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final c in cards)
            SizedBox(
              width: (constraints.maxWidth - (perRow - 1) * 16) / perRow,
              child: c,
            ),
        ],
      );
    });
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.delta,
    required this.deltaPositive,
    required this.sparkColor,
    required this.sparkValues,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String delta;
  final bool deltaPositive;
  final Color sparkColor;
  final List<double> sparkValues;

  @override
  Widget build(BuildContext context) {
    return DashedContainer(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha:0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                color: AppColors.surface,
                offset: const Offset(0, 20),
                icon: const Icon(Icons.more_vert_rounded, size: 16, color: AppColors.textMuted),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: AppColors.borderStrong),
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (action) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$label — $action (demo)'), backgroundColor: AppColors.surfaceAlt),
                  );
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'View Details', child: Text('View Details', style: TextStyle(color: AppColors.textPrimary, fontSize: 13))),
                  PopupMenuItem(value: 'Export CSV', child: Text('Export CSV', style: TextStyle(color: AppColors.textPrimary, fontSize: 13))),
                  PopupMenuItem(value: 'Refresh', child: Text('Refresh', style: TextStyle(color: AppColors.textPrimary, fontSize: 13))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            delta,
            style: TextStyle(
              color: deltaPositive ? AppColors.success : AppColors.danger,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 6),
          SparklineWidget(values: sparkValues, color: sparkColor, height: 40),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _GenderLegendRow extends StatelessWidget {
  const _GenderLegendRow({
    required this.color,
    required this.percent,
    required this.label,
    required this.count,
  });

  final Color color;
  final String percent;
  final String label;
  final String count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(percent, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
              Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
            ],
          ),
        ),
        Text(count, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }
}