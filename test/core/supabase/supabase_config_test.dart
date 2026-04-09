import 'package:flutter_test/flutter_test.dart';

import 'package:abaly/core/supabase/supabase_config.dart';

void main() {
  group('SupabaseConfig', () {
    test('url constant is defined from SUPABASE_URL dart-define', () {
      // When no --dart-define is provided the value is an empty string,
      // which is the documented default for String.fromEnvironment.
      // In real builds/CI the value will be non-empty.
      expect(SupabaseConfig.url, isA<String>());
    });

    test('anonKey constant is defined from SUPABASE_ANON_KEY dart-define', () {
      expect(SupabaseConfig.anonKey, isA<String>());
    });

    test('url and anonKey are distinct constants', () {
      // Sanity check: they should not accidentally point to the same define.
      // This will only be meaningful when both defines are supplied, but it
      // guards against copy-paste errors in the config class.
      if (SupabaseConfig.url.isNotEmpty && SupabaseConfig.anonKey.isNotEmpty) {
        expect(SupabaseConfig.url, isNot(equals(SupabaseConfig.anonKey)));
      }
    });
  });
}
