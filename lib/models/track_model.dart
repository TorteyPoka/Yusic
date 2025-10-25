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
      id: json['id'] as String,
      folderId: json['folderId'] as String,
      artistId: json['artistId'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String?,
      audioUrl: json['audioUrl'] as String,
      coverImage: json['coverImage'] as String?,
      duration: json['duration'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'folderId': folderId,
      'artistId': artistId,
      'title': title,
      'artist': artist,
      'audioUrl': audioUrl,
      'coverImage': coverImage,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
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
