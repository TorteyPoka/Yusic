import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/track_model.dart';

/// Music Track Service for handling track uploads and management with Supabase
class MusicTrackService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  /// Upload a music track with metadata to Supabase Storage and Database
  Future<String> uploadTrack({
    required Uint8List fileBytes,
    required String fileName,
    required String title,
    required String artistId,
    String? artistName,
    String? folderId,
    String? genre,
    int? duration,
    String? coverImage,
    Function(double)? onProgress,
  }) async {
    try {
      // Generate storage path: audio-tracks/{artistId}/{fileName}
      final storagePath =
          '$artistId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      // Upload to Supabase Storage
      if (onProgress != null) onProgress(0.3);

      await _supabase.storage.from('audio-tracks').uploadBinary(
            storagePath,
            fileBytes,
            fileOptions: const FileOptions(
              contentType: 'audio/mpeg',
            ),
          );

      if (onProgress != null) onProgress(0.7);

      // Get public URL
      final String publicUrl =
          _supabase.storage.from('audio-tracks').getPublicUrl(storagePath);

      // Save track metadata to database
      // Only include folder_id if it's a valid UUID format
      final Map<String, dynamic> trackData = {
        'artist_id': artistId,
        'title': title,
        'artist_name': artistName,
        'audio_url': publicUrl,
        'cover_image': coverImage,
        'duration': duration ?? 0,
        'file_size': fileBytes.length,
        'genre': genre,
        'plays': 0,
        'likes': 0,
      };

      // Only add folder_id if it's a valid UUID (36 chars with dashes)
      if (folderId != null && folderId.contains('-') && folderId.length == 36) {
        trackData['folder_id'] = folderId;
      }

      final response =
          await _supabase.from('tracks').insert(trackData).select().single();

      if (onProgress != null) onProgress(1.0);

      return response['id'] as String;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading track: $e');
      }

      // Enhanced error messages
      if (e.toString().contains('Bucket not found')) {
        throw Exception(
            'Storage bucket not found. Please create "audio-tracks" bucket in Supabase Dashboard:\n1. Go to Storage\n2. Create new bucket: audio-tracks\n3. Make it public\n4. Set file size limit to 50MB');
      }

      throw Exception('Failed to upload track: $e');
    }
  }

  /// Get all tracks by an artist
  Future<List<TrackModel>> getArtistTracks(String artistId) async {
    try {
      final response = await _supabase
          .from('tracks')
          .select()
          .eq('artist_id', artistId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TrackModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting artist tracks: $e');
      }
      throw Exception('Failed to load tracks: $e');
    }
  }

  /// Get tracks in a specific folder
  Future<List<TrackModel>> getFolderTracks(String folderId) async {
    try {
      final response = await _supabase
          .from('tracks')
          .select()
          .eq('folder_id', folderId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TrackModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting folder tracks: $e');
      }
      throw Exception('Failed to load folder tracks: $e');
    }
  }

  /// Delete a track
  Future<void> deleteTrack(String trackId) async {
    try {
      // Get track info first to delete from storage
      final track =
          await _supabase.from('tracks').select().eq('id', trackId).single();

      // Delete from storage
      final audioUrl = track['audio_url'] as String;
      final storagePath = audioUrl.split('/audio-tracks/').last;

      await _supabase.storage.from('audio-tracks').remove([storagePath]);

      // Delete from database
      await _supabase.from('tracks').delete().eq('id', trackId);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting track: $e');
      }
      throw Exception('Failed to delete track: $e');
    }
  }
}
