import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The RightONE brand mark: a gradient "R1" glyph + wordmark, matching the
/// reference dashboard design. Used on the login screen, sidebar header,
/// and anywhere else the brand needs to appear.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.iconSize = 34,
    this.showWordmark = true,
    this.wordmarkFontSize = 20,
    this.glow = true,
  });

  final double iconSize;
  final bool showWordmark;
  final double wordmarkFontSize;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogoMark(size: iconSize, glow: glow),
        if (showWordmark) ...[
          SizedBox(width: iconSize * 0.32),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: wordmarkFontSize,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
              children: [
                const TextSpan(
                  text: 'Right',
                  style: TextStyle(color: AppColors.accentMagenta),
                ),
                TextSpan(
                  text: 'ONE',
                   style: TextStyle(color: AppColors.accentCyan
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Just the "R1" glyph mark (magenta/cyan wordmark on a soft glow), no
/// text wordmark — for compact spots like the login screen badge or a
/// collapsed sidebar. Includes a soft radial magenta glow behind the mark,
/// matching the mobile app's splash screen.
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 34, this.glow = true});

  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (!glow)
            Container(
              width: size * 3.1,
              height: size * 3.1,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentMagenta.withValues(alpha:0.45),
                    AppColors.accentMagenta.withValues(alpha:0.0),
                  ],
                ),
              ),
            ),
          Image.asset(
            'assets/images/R1.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
