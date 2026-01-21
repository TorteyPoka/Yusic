import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Configuration
///
/// IMPORTANT: Replace these with your actual Supabase project credentials
/// Get your credentials from: https://app.supabase.com/project/_/settings/api
class SupabaseConfig {
  // Supabase project URL
  static const String supabaseUrl = 'https://vkrmpzjjwsmqcyakjeag.supabase.co';

  // Supabase anon/public key
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZrcm1wempqd3NtcWN5YWtqZWFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg4ODYzNDYsImV4cCI6MjA4NDQ2MjM0Nn0.iY2mbOgM7qhnWiHuPd73A3Arny69LiOODoepFMyyhkI';

  // Get Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  // Optional: For development/testing, you can use environment variables
  // Install flutter_dotenv package and load from .env file

  /// Check if Supabase is properly configured
  static bool get isConfigured {
    return supabaseUrl != 'YOUR_SUPABASE_URL' &&
        supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY' &&
        supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty;
  }
}
