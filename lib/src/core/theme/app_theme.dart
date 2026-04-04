import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Color scheme ──────────────────────────────────────────────────────────────

class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color primary;
  final Color success;
  final Color warning;
  final Color error;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.primary,
    required this.success,
    required this.warning,
    required this.error,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
  });

  // ── Dark (arcade) ─────────────────────────────────────────────────────────
  static const dark = AppColors(
    background:      Color(0xFF112756),
    surface:         Color(0xFF0D1E42),
    surfaceElevated: Color(0xFF1A3060),
    primary:         Color(0xFF5078FF),
    success:         Color(0xFF39B402),
    warning:         Color(0xFFFFC10A),
    error:           Color(0xFFFF325F),
    textPrimary:     Color(0xFFFFFFFF),
    textSecondary:   Color(0xFF8BA3CC),
    border:          Color(0xFF2A4480),
  );

  // ── Light (PDAX brand) ────────────────────────────────────────────────────
  static const light = AppColors(
    background:      Color(0xFFF5F7F5),
    surface:         Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFEEF0EE),
    primary:         Color(0xFF39B402),
    success:         Color(0xFF39B402),
    warning:         Color(0xFFF5A623),
    error:           Color(0xFFE53935),
    textPrimary:     Color(0xFF1A1A1A),
    textSecondary:   Color(0xFF757575),
    border:          Color(0xFFE0E0E0),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? primary,
    Color? success,
    Color? warning,
    Color? error,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
  }) {
    return AppColors(
      background:      background      ?? this.background,
      surface:         surface         ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      primary:         primary         ?? this.primary,
      success:         success         ?? this.success,
      warning:         warning         ?? this.warning,
      error:           error           ?? this.error,
      textPrimary:     textPrimary     ?? this.textPrimary,
      textSecondary:   textSecondary   ?? this.textSecondary,
      border:          border          ?? this.border,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      background:      Color.lerp(background,      other.background,      t)!,
      surface:         Color.lerp(surface,          other.surface,         t)!,
      surfaceElevated: Color.lerp(surfaceElevated,  other.surfaceElevated, t)!,
      primary:         Color.lerp(primary,          other.primary,         t)!,
      success:         Color.lerp(success,          other.success,         t)!,
      warning:         Color.lerp(warning,          other.warning,         t)!,
      error:           Color.lerp(error,            other.error,           t)!,
      textPrimary:     Color.lerp(textPrimary,      other.textPrimary,     t)!,
      textSecondary:   Color.lerp(textSecondary,    other.textSecondary,   t)!,
      border:          Color.lerp(border,           other.border,          t)!,
    );
  }
}

// ── Convenience extension ─────────────────────────────────────────────────────

extension AppColorsX on BuildContext {
  AppColors get colors => AppColors.of(this);
}

// ── ThemeData builders ────────────────────────────────────────────────────────

class AppTheme {
  static final _appBarTitleStyle = GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  static final _buttonTextStyle = GoogleFonts.plusJakartaSans(
    fontWeight: FontWeight.w600,
    fontSize: 15,
  );

  static ThemeData _base(AppColors c, Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: c.background,
      extensions: [c],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: c.primary,
        onPrimary: c.textPrimary,
        secondary: c.warning,
        onSecondary: c.textPrimary,
        surface: c.surface,
        onSurface: c.textPrimary,
        error: c.error,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        TextTheme(
          displayLarge:  TextStyle(color: c.textPrimary),
          displayMedium: TextStyle(color: c.textPrimary),
          headlineLarge: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold),
          headlineMedium:TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(color: c.textPrimary),
          titleLarge:    TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600),
          titleMedium:   TextStyle(color: c.textPrimary),
          bodyLarge:     TextStyle(color: c.textPrimary),
          bodyMedium:    TextStyle(color: c.textSecondary),
          labelLarge:    TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _appBarTitleStyle.copyWith(color: c.textPrimary),
        iconTheme: IconThemeData(color: c.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: brightness == Brightness.dark ? Colors.white : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: _buttonTextStyle,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: c.primary, width: 2),
        ),
        hintStyle: TextStyle(color: c.textSecondary),
        labelStyle: TextStyle(color: c.textSecondary),
      ),
    );
  }

  static ThemeData get dark  => _base(AppColors.dark,  Brightness.dark);
  static ThemeData get light => _base(AppColors.light, Brightness.light);
}
