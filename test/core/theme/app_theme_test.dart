import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abaly/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    late ThemeData theme;

    setUp(() {
      theme = AppTheme.lightTheme;
    });

    test('uses Material 3', () {
      expect(theme.useMaterial3, isTrue);
    });

    test('brightness is light', () {
      expect(theme.brightness, Brightness.light);
    });

    group('color scheme', () {
      test('has a clinical teal/blue primary color', () {
        // Primary should be in the blue-teal spectrum (hue 170–240)
        final hsl = HSLColor.fromColor(theme.colorScheme.primary);
        expect(hsl.hue, inInclusiveRange(170.0, 240.0));
      });

      test('surface color is near-white', () {
        final surface = theme.colorScheme.surface;
        // Luminance close to 1.0 means near-white
        expect(surface.computeLuminance(), greaterThan(0.85));
      });

      test('on-primary is white for contrast', () {
        expect(theme.colorScheme.onPrimary, Colors.white);
      });
    });

    group('AppBar theme', () {
      test('has an AppBar theme defined', () {
        expect(theme.appBarTheme, isNotNull);
      });

      test('AppBar elevation is 0 for flat clinical look', () {
        expect(theme.appBarTheme.elevation, 0);
      });

      test('AppBar center title is true', () {
        expect(theme.appBarTheme.centerTitle, isTrue);
      });
    });

    group('Card theme', () {
      test('has a Card theme defined', () {
        expect(theme.cardTheme, isNotNull);
      });

      test('Card elevation is low for clean look', () {
        expect(theme.cardTheme.elevation, lessThanOrEqualTo(2.0));
      });
    });

    group('ElevatedButton theme', () {
      test('has an ElevatedButton theme defined', () {
        expect(theme.elevatedButtonTheme, isNotNull);
      });
    });

    group('InputDecoration theme', () {
      test('has an InputDecoration theme defined', () {
        expect(theme.inputDecorationTheme, isNotNull);
      });

      test('uses outlined or filled border for clinical form fields', () {
        final border = theme.inputDecorationTheme.border;
        expect(
          border,
          isA<OutlineInputBorder>(),
        );
      });
    });

    group('typography', () {
      test('has text theme defined', () {
        expect(theme.textTheme, isNotNull);
      });

      test('headline styles have appropriate font weight', () {
        final headlineLarge = theme.textTheme.headlineLarge;
        expect(headlineLarge, isNotNull);
        expect(
          headlineLarge!.fontWeight,
          isIn([FontWeight.w600, FontWeight.w700, FontWeight.bold]),
        );
      });
    });
  });
}
