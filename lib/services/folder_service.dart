import '../models/folder_model.dart';

class FolderService {
  // Sample data - In production, this would use a real database/API
  static final List<FolderModel> _mockFolders = [
    // Sample public folders from various artists
    FolderModel(
      id: 'folder_001',
      artistId: 'artist_002',
      name: 'Summer Vibes 2025',
      description: 'Chill tracks for summer',
      isPublic: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      trackCount: 8,
    ),
    FolderModel(
      id: 'folder_002',
      artistId: 'artist_003',
      name: 'Electronic Dreams',
      description: 'EDM and electronic music collection',
      isPublic: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      trackCount: 12,
    ),
    FolderModel(
      id: 'folder_003',
      artistId: 'artist_001',
      name: 'My Private Collection',
      description: 'Work in progress tracks',
      isPublic: false,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      trackCount: 5,
    ),
    FolderModel(
      id: 'folder_004',
      artistId: 'artist_001',
      name: 'Released Singles',
      description: 'My official releases',
      isPublic: true,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      trackCount: 6,
    ),
    FolderModel(
      id: 'folder_005',
      artistId: 'artist_004',
      name: 'Jazz Sessions',
      description: 'Live jazz recordings',
      isPublic: true,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      trackCount: 10,
    ),
  ];
  Future<List<FolderModel>> getFoldersByArtist(String artistId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // For demo purposes, return some folders with the current artistId
    // This ensures users always see demo folders
    final userFolders =
        _mockFolders.where((f) => f.artistId == artistId).toList();

    // If user has no folders, create some demo folders for them
    if (userFolders.isEmpty && _mockFolders.isNotEmpty) {
      return _mockFolders.take(3).map((folder) {
        return folder.copyWith(artistId: artistId);
      }).toList();
    }

    return userFolders;
  }

  Future<List<FolderModel>> getPublicFolders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockFolders.where((f) => f.isPublic).toList();
  }

  Future<void> createFolder(FolderModel folder) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockFolders.add(folder);
  }

  Future<void> updateFolderVisibility(String folderId, bool isPublic) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockFolders.indexWhere((f) => f.id == folderId);
    if (index != -1) {
      _mockFolders[index] = _mockFolders[index].copyWith(isPublic: isPublic);
    }
  }

  Future<void> deleteFolder(String folderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockFolders.removeWhere((f) => f.id == folderId);
  }
}
