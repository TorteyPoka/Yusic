import 'package:equatable/equatable.dart';

class FolderModel extends Equatable {
  final String id;
  final String artistId;
  final String name;
  final String? description;
  final String? coverImage;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int trackCount;

  const FolderModel({
    required this.id,
    required this.artistId,
    required this.name,
    this.description,
    this.coverImage,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    this.trackCount = 0,
  });

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      id: json['id'] as String,
      artistId: json['artistId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverImage: json['coverImage'] as String?,
      isPublic: json['isPublic'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      trackCount: json['trackCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'artistId': artistId,
      'name': name,
      'description': description,
      'coverImage': coverImage,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'trackCount': trackCount,
    };
  }

  FolderModel copyWith({
    String? id,
    String? artistId,
    String? name,
    String? description,
    String? coverImage,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? trackCount,
  }) {
    return FolderModel(
      id: id ?? this.id,
      artistId: artistId ?? this.artistId,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      trackCount: trackCount ?? this.trackCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        artistId,
        name,
        description,
        coverImage,
        isPublic,
        createdAt,
        updatedAt,
        trackCount,
      ];
}
