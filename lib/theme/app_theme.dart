import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AppColors {
  AppColors._();

  static const background = Color(0xFF0C0C12);
  static const surface = Color(0xFF161623);
  static const surfaceAlt = Color(0xFF1A1A2B);
  static const input = Color(0xFF1C1C2B);

  static const border = Color(0x332D2D3D); 
  static const borderStrong = Color(0xFF2D2D3D);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB4B4BB);
  static const textMuted = Color(0xFF7E8584);

  static const accentMagenta = Color(0xFFFF2FB3);
  static const accentPink = Color(0xFFD10888);
  static const accentCyan = Color(0xFF22D3EE);
  static const accentCyan2 = Color(0xFF02A2BA);

  static const gold = Color(0xFFFFC107);
  static const goldDark = Color(0xFFE6A800);

  static const success = Color(0xFF3DDC84);
  static const warning = Color(0xFFFFC107);
  static const danger = Color(0xFFFF3B30);

  static const primaryGradient = LinearGradient(
    colors: [accentMagenta, accentPink],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const secondaryGradient = LinearGradient(
    colors: [accentCyan, accentCyan2],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const goldGradient = LinearGradient(
    colors: [gold, goldDark],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class AppTheme {
  AppTheme._();

  static TextTheme _brandTextTheme(TextTheme base) {
    return GoogleFonts.plusJakartaSansTextTheme(base).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        surface: AppColors.background,
        primary: AppColors.accentMagenta,
        secondary: AppColors.accentCyan,
        error: AppColors.danger,
      ),
      textTheme: _brandTextTheme(base.textTheme),
      dividerColor: AppColors.border,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.input,
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textMuted,
          fontSize: 14,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentMagenta, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentMagenta,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }
}
