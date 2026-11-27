import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'tokens.dart';

abstract final class AppTheme {
  static const String fontFamily = 'Inter';

  static ThemeData get light => _build(Brightness.light, AppColors.light);
  static ThemeData get dark => _build(Brightness.dark, AppColors.dark);

  static bool _licenseRegistered = false;

  /// Registers the bundled Inter SIL Open Font License in Flutter's licence registry.
  static void registerFontLicenses() {
    if (_licenseRegistered) return;
    _licenseRegistered = true;
    LicenseRegistry.addLicense(() async* {
      try {
        final license = await rootBundle.loadString('assets/fonts/OFL.txt');
        yield LicenseEntryWithLineBreaks(const ['Inter Font'], license);
      } catch (_) {
        // Ignored in tests that do not bundle assets.
      }
    });
  }

  /// System status/navigation bar overlay style matching edge-to-edge rules.
  static SystemUiOverlayStyle systemOverlayStyleFor(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    );
  }

  static ThemeData _build(Brightness brightness, AppColors c) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: c.accentDefault,
      onPrimary: c.textOnAccent,
      secondary: c.bgInverse,
      onSecondary: c.textOnInverse,
      error: c.statusDanger,
      onError: c.textOnAccent,
      surface: c.bgCanvas,
      surfaceContainerLowest: c.bgSurface,
      surfaceContainerHigh: c.bgSubtle,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      outline: c.borderStrong,
      outlineVariant: c.borderHairline,
      inverseSurface: c.bgInverse,
      onInverseSurface: c.textOnInverse,
      scrim: c.scrim,
    );

    final textTheme = TextTheme(
      // Display: 28 / 34, 600, -0.4
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        height: 34 / 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: c.textPrimary,
      ),
      // Title: 20 / 26, 600, -0.2
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        height: 26 / 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: c.textPrimary,
      ),
      // Headline: 16 / 22, 600, -0.1
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        height: 22 / 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: c.textPrimary,
      ),
      // Body Strong: 15 / 22, 500, 0
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: c.textPrimary,
      ),
      // Body: 15 / 22, 400, 0
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: c.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: c.textPrimary,
      ),
      // Label: 13 / 18, 500, 0
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: c.textSecondary,
      ),
      // Caption: 12 / 16, 400, 0
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: c.textSecondary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.bgCanvas,
      textTheme: textTheme,
      extensions: [c],
      appBarTheme: AppBarTheme(
        backgroundColor: c.bgCanvas,
        foregroundColor: c.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: systemOverlayStyleFor(brightness),
        titleTextStyle: textTheme.titleMedium,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: AppTokens.navBarHeight,
        backgroundColor: c.bgSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: c.bgSubtle,
        indicatorShape: const StadiumBorder(),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: active ? c.textPrimary : c.textTertiary,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return textTheme.labelMedium!.copyWith(
            color: active ? c.textPrimary : c.textTertiary,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(AppTokens.minTouchTarget, AppTokens.buttonHeight),
          backgroundColor: c.accentDefault,
          foregroundColor: c.textOnAccent,
          elevation: 0,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusControl),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.bgSurface,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: c.scrim,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTokens.radiusSheetTop),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.bgSubtle,
        isDense: true,
        contentPadding: const EdgeInsets.all(14),
        hintStyle: textTheme.bodyMedium!.copyWith(color: c.textTertiary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusControl),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusControl),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusControl),
          borderSide: BorderSide(color: c.borderStrong, width: 1),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.bgInverse,
        contentTextStyle: textTheme.bodyMedium!.copyWith(color: c.textOnInverse),
        actionTextColor: c.textOnInverse,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusControl),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: c.borderHairline,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
