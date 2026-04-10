import 'package:flutter_test/flutter_test.dart';

import 'package:abaly/core/supabase/supabase_config.dart';

void main() {
  group('SupabaseConfig', () {
    test('url is a non-empty string loaded from .env', () {
      expect(SupabaseConfig.url, isA<String>());
      expect(SupabaseConfig.url, isNotEmpty);
    });

    test('anonKey is a non-empty string loaded from .env', () {
      expect(SupabaseConfig.anonKey, isA<String>());
      expect(SupabaseConfig.anonKey, isNotEmpty);
    });

    test('url and anonKey are distinct values', () {
      expect(SupabaseConfig.url, isNot(equals(SupabaseConfig.anonKey)));
    });
  });
}
