import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_header.dart';
import 'sidebar.dart';

class AdminScaffold extends StatefulWidget {
  const AdminScaffold({
    super.key,
    required this.currentRoute,
    required this.child,
  });

  final String currentRoute;

  final Widget child;

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

/// Below this width, the sidebar switches from an inline, layout-pushing
/// panel to an overlay drawer that floats above the content and closes
/// itself automatically (on nav tap, on scrim tap, or on route change).
const double kMobileBreakpoint = 900;
const double kSidebarWidth = 240;

class _AdminScaffoldState extends State<AdminScaffold> {
  bool _sidebarOpen = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _toggleDesktopSidebar() {
    setState(() => _sidebarOpen = !_sidebarOpen);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < kMobileBreakpoint;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        onMenuTap: () {
          if (isMobile) {
            _scaffoldKey.currentState?.openDrawer();
          } else {
            _toggleDesktopSidebar();
          }
        },
        isMobile: isMobile,
        sidebarWidthOverride: isMobile ? null : (_sidebarOpen ? kSidebarWidth : 0),
      ),
      // On mobile, the sidebar becomes a standard Flutter Drawer: it slides
      // in as an overlay with its own scrim, swipe-to-dismiss, and closes
      // automatically as soon as a nav item calls Navigator.pop below —
      // no custom positioning/animation code needed.
      drawer: isMobile
          ? Drawer(
              backgroundColor: AppColors.background,
              width: kSidebarWidth,
              child: SafeArea(
                child: Sidebar(
                  currentRoute: widget.currentRoute,
                  onNavigate: () => Navigator.of(context).maybePop(),
                ),
              ),
            )
          : null,
      body: isMobile ? _buildContent() : _buildDesktopBody(),
    );
  }

  Widget _buildDesktopBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: _sidebarOpen ? kSidebarWidth : 0,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(),
          child: Sidebar(currentRoute: widget.currentRoute),
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          final scale = Tween<double>(begin: 0.96, end: 1.0).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              alignment: Alignment.topCenter,
              scale: scale,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

class AdminPageContent extends StatelessWidget {
  const AdminPageContent({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final Widget child;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < kMobileBreakpoint;
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ],
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stack title/trailing vertically on narrow screens instead of
          // forcing them into a single row, which is what squeezed content
          // into a sliver on mobile before.
          if (isMobile && trailing != null) ...[
            heading,
            const SizedBox(height: 14),
            trailing!,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: heading),
                if (trailing != null) trailing!,
              ],
            ),
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }
}
