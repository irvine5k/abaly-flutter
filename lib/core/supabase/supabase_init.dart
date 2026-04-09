import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

/// Initializes the Supabase client.
///
/// Must be called once before any Supabase calls are made, typically
/// at the start of [main] before [runApp].
///
/// Reads [SupabaseConfig.url] and [SupabaseConfig.anonKey] which are
/// injected via --dart-define at build/run time.
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
}
