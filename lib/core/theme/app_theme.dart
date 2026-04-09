import 'package:flutter/material.dart';

/// Clinical light theme for the Abaly ABA therapy app.
///
/// Design intent: calm, professional, and accessible — suited to a clinical
/// environment where practitioners and caregivers need clear information
/// hierarchy and minimal visual noise.
abstract final class AppTheme {
  // ── Palette ────────────────────────────────────────────────────────────────

  /// Primary brand colour: a calm teal-blue used in medical/clinical contexts.
  static const Color _primary = Color(0xFF1A6B8A);

  /// Slightly lighter teal for interactive secondary elements.
  static const Color _primaryContainer = Color(0xFFB8DDE8);

  /// Deep navy — used for on-primary-container text and focused states.
  static const Color _onPrimaryContainer = Color(0xFF002D3B);

  /// Muted teal accent for secondary actions and highlights.
  static const Color _secondary = Color(0xFF4A9E8A);
  static const Color _secondaryContainer = Color(0xFFBCEADE);
  static const Color _onSecondaryContainer = Color(0xFF002117);

  /// Clinical background: off-white with the faintest cool tint.
  static const Color _surface = Color(0xFFF6FAFB);

  /// Card / sheet background — pure white for clear content containers.
  static const Color _surfaceContainer = Color(0xFFFFFFFF);

  /// Standard dark text on light surfaces.
  static const Color _onSurface = Color(0xFF1A1C1E);

  /// Subdued text for secondary labels and placeholders.
  static const Color _onSurfaceVariant = Color(0xFF40484C);

  /// Dividers, outlines, and inactive borders.
  static const Color _outline = Color(0xFFCBD5DA);

  /// Softer variant for subtle borders (e.g. un-focused input).
  static const Color _outlineVariant = Color(0xFFE2EAED);

  /// Clinical error — accessible red.
  static const Color _error = Color(0xFFBA1A1A);

  // ── Spacing & shape constants ───────────────────────────────────────────────

  static const double _radiusSmall = 6.0;
  static const double _radiusMedium = 10.0;
  static const double _radiusLarge = 16.0;

  // ── Light theme ────────────────────────────────────────────────────────────

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,

        // Color scheme --------------------------------------------------------
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: _primary,
          onPrimary: Colors.white,
          primaryContainer: _primaryContainer,
          onPrimaryContainer: _onPrimaryContainer,
          secondary: _secondary,
          onSecondary: Colors.white,
          secondaryContainer: _secondaryContainer,
          onSecondaryContainer: _onSecondaryContainer,
          error: _error,
          onError: Colors.white,
          surface: _surface,
          onSurface: _onSurface,
          onSurfaceVariant: _onSurfaceVariant,
          outline: _outline,
          outlineVariant: _outlineVariant,
          surfaceContainerLowest: _surfaceContainer,
          surfaceContainerLow: _surfaceContainer,
          surfaceContainer: _surfaceContainer,
          surfaceContainerHigh: Color(0xFFF0F5F7),
          surfaceContainerHighest: Color(0xFFE8F0F3),
        ),

        // Scaffold & background -----------------------------------------------
        scaffoldBackgroundColor: _surface,

        // AppBar --------------------------------------------------------------
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: true,
          backgroundColor: _surface,
          foregroundColor: _onSurface,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: _onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
          iconTheme: IconThemeData(color: _primary),
        ),

        // Card ----------------------------------------------------------------
        cardTheme: CardThemeData(
          elevation: 1,
          color: _surfaceContainer,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(_radiusMedium)),
            side: BorderSide(color: _outlineVariant, width: 1),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),

        // ElevatedButton ------------------------------------------------------
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            minimumSize: const Size(88, 48),
            shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(_radiusMedium)),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),

        // OutlinedButton ------------------------------------------------------
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _primary,
            side: const BorderSide(color: _primary, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            minimumSize: const Size(88, 48),
            shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(_radiusMedium)),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),

        // TextButton ----------------------------------------------------------
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
          ),
        ),

        // InputDecoration (text fields) ----------------------------------------
        inputDecorationTheme: InputDecorationTheme(
          filled: false,
          border: OutlineInputBorder(
            borderRadius:
                const BorderRadius.all(Radius.circular(_radiusSmall)),
            borderSide: const BorderSide(color: _outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                const BorderRadius.all(Radius.circular(_radiusSmall)),
            borderSide: const BorderSide(color: _outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                const BorderRadius.all(Radius.circular(_radiusSmall)),
            borderSide: const BorderSide(color: _primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius:
                const BorderRadius.all(Radius.circular(_radiusSmall)),
            borderSide: const BorderSide(color: _error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius:
                const BorderRadius.all(Radius.circular(_radiusSmall)),
            borderSide: const BorderSide(color: _error, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: const TextStyle(
            color: _onSurfaceVariant,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          labelStyle: const TextStyle(
            color: _onSurfaceVariant,
            fontSize: 15,
          ),
          floatingLabelStyle:
              const TextStyle(color: _primary, fontSize: 13),
        ),

        // Divider -------------------------------------------------------------
        dividerTheme: const DividerThemeData(
          color: _outlineVariant,
          thickness: 1,
          space: 1,
        ),

        // Chip ----------------------------------------------------------------
        chipTheme: ChipThemeData(
          backgroundColor: _surfaceContainer,
          side: const BorderSide(color: _outlineVariant),
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(_radiusLarge)),
          ),
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _onSurface,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),

        // ListTile ------------------------------------------------------------
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          iconColor: _primary,
          titleTextStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: _onSurface,
          ),
          subtitleTextStyle: TextStyle(
            fontSize: 13,
            color: _onSurfaceVariant,
          ),
        ),

        // FloatingActionButton ------------------------------------------------
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: CircleBorder(),
        ),

        // BottomNavigationBar -------------------------------------------------
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: _surfaceContainer,
          selectedItemColor: _primary,
          unselectedItemColor: _onSurfaceVariant,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        ),

        // Typography ----------------------------------------------------------
        textTheme: const TextTheme(
          // Display
          displayLarge: TextStyle(
            fontSize: 57,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.25,
            color: _onSurface,
          ),
          displayMedium: TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.w400,
            color: _onSurface,
          ),
          displaySmall: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w400,
            color: _onSurface,
          ),
          // Headline
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: _onSurface,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: _onSurface,
          ),
          headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: _onSurface,
          ),
          // Title
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: _onSurface,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
            color: _onSurface,
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: _onSurface,
          ),
          // Body
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
            color: _onSurface,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
            color: _onSurface,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
            color: _onSurfaceVariant,
          ),
          // Label
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: _onSurface,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: _onSurface,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: _onSurfaceVariant,
          ),
        ),
      );
}
