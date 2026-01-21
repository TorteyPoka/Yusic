import 'package:equatable/equatable.dart';

class TrackModel extends Equatable {
  final String id;
  final String folderId;
  final String artistId;
  final String title;
  final String? artist;
  final String audioUrl;
  final String? coverImage;
  final int duration; // in seconds
  final DateTime createdAt;

  const TrackModel({
    required this.id,
    required this.folderId,
    required this.artistId,
    required this.title,
    this.artist,
    required this.audioUrl,
    this.coverImage,
    required this.duration,
    required this.createdAt,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id']?.toString() ?? '',
      // Handle both snake_case (database) and camelCase (app)
      folderId: (json['folder_id'] ?? json['folderId'] ?? '').toString(),
      artistId: (json['artist_id'] ?? json['artistId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      artist: json['artist_name'] ?? json['artist'],
      audioUrl: (json['audio_url'] ?? json['audioUrl'] ?? '').toString(),
      coverImage: json['cover_image'] ?? json['coverImage'],
      duration: (json['duration'] ?? 0) as int,
      createdAt: DateTime.parse((json['created_at'] ??
              json['createdAt'] ??
              DateTime.now().toIso8601String())
          .toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'folder_id': folderId,
      'artist_id': artistId,
      'title': title,
      'artist_name': artist,
      'audio_url': audioUrl,
      'cover_image': coverImage,
      'duration': duration,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
        id,
        folderId,
        artistId,
        title,
        artist,
        audioUrl,
        coverImage,
        duration,
        createdAt,
      ];
}
