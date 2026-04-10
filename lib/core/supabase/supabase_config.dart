import 'package:envied/envied.dart';

part 'supabase_config.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class SupabaseConfig {
  @EnviedField(varName: 'SUPABASE_URL')
  static String url = _SupabaseConfig.url;

  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static String anonKey = _SupabaseConfig.anonKey;
}
