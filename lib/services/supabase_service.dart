import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Service - Wrapper for Supabase operations
/// Provides convenient access to Supabase client and common operations
class SupabaseService {
  // Singleton pattern
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  /// Get Supabase client instance
  SupabaseClient get client => Supabase.instance.client;

  /// Get current user
  User? get currentUser => client.auth.currentUser;

  /// Get current user ID
  String? get currentUserId => client.auth.currentUser?.id;

  /// Auth state stream
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // =========================
  // AUTHENTICATION METHODS
  // =========================

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  /// Update user password
  Future<UserResponse> updatePassword(String newPassword) async {
    return await client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  /// Update user metadata
  Future<UserResponse> updateUserMetadata(Map<String, dynamic> data) async {
    return await client.auth.updateUser(
      UserAttributes(data: data),
    );
  }

  // =========================
  // DATABASE METHODS
  // =========================

  /// Get all records from a table
  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final response = await client.from(table).select();
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get records with filtering
  Future<List<Map<String, dynamic>>> getWhere(
    String table,
    String column,
    dynamic value,
  ) async {
    final response = await client.from(table).select().eq(column, value);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get single record by ID
  Future<Map<String, dynamic>?> getById(String table, String id) async {
    final response =
        await client.from(table).select().eq('id', id).maybeSingle();
    return response;
  }

  /// Insert a record
  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    final response = await client.from(table).insert(data).select().single();
    return response;
  }

  /// Update a record
  Future<Map<String, dynamic>> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    final response =
        await client.from(table).update(data).eq('id', id).select().single();
    return response;
  }

  /// Delete a record
  Future<void> delete(String table, String id) async {
    await client.from(table).delete().eq('id', id);
  }

  /// Stream records from a table
  Stream<List<Map<String, dynamic>>> streamTable(String table) {
    return client.from(table).stream(primaryKey: ['id']).map(
        (data) => List<Map<String, dynamic>>.from(data));
  }

  /// Stream records with filtering
  Stream<List<Map<String, dynamic>>> streamWhere(
    String table,
    String column,
    dynamic value,
  ) {
    return client
        .from(table)
        .stream(primaryKey: ['id'])
        .eq(column, value)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  // =========================
  // STORAGE METHODS
  // =========================

  /// Upload file to storage
  Future<String> uploadFile(
    String bucket,
    String path,
    dynamic file, {
    Map<String, String>? fileOptions,
  }) async {
    await client.storage.from(bucket).upload(
          path,
          file,
          fileOptions: FileOptions(
            upsert: fileOptions?['upsert'] == 'true',
          ),
        );

    // Get public URL
    final publicUrl = client.storage.from(bucket).getPublicUrl(path);
    return publicUrl;
  }

  /// Download file from storage
  Future<List<int>> downloadFile(String bucket, String path) async {
    final response = await client.storage.from(bucket).download(path);
    return response;
  }

  /// Delete file from storage
  Future<void> deleteFile(String bucket, String path) async {
    await client.storage.from(bucket).remove([path]);
  }

  /// Get public URL for a file
  String getPublicUrl(String bucket, String path) {
    return client.storage.from(bucket).getPublicUrl(path);
  }

  /// List files in a bucket
  Future<List<FileObject>> listFiles(
    String bucket, {
    String? path,
    SearchOptions? searchOptions,
  }) async {
    final response = await client.storage.from(bucket).list(
          path: path,
          searchOptions: searchOptions ?? const SearchOptions(),
        );
    return response;
  }

  // =========================
  // REALTIME METHODS
  // =========================

  /// Subscribe to realtime changes
  RealtimeChannel subscribeToTable(
    String table,
    void Function(PostgresChangePayload) callback,
  ) {
    return client
        .channel('public:$table')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          callback: callback,
        )
        .subscribe();
  }

  /// Unsubscribe from a channel
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await channel.unsubscribe();
  }
}
