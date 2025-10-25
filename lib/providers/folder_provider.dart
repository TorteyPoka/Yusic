import 'package:flutter/material.dart';
import '../models/folder_model.dart';
import '../services/folder_service.dart';

class FolderProvider extends ChangeNotifier {
  List<FolderModel> _folders = [];
  List<FolderModel> _publicFolders = [];
  bool _isLoading = false;

  List<FolderModel> get folders => _folders;
  List<FolderModel> get publicFolders => _publicFolders;
  bool get isLoading => _isLoading;

  final FolderService _folderService = FolderService();

  Future<void> loadFolders(String artistId) async {
    _isLoading = true;
    notifyListeners();

    _folders = await _folderService.getFoldersByArtist(artistId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPublicFolders() async {
    _isLoading = true;
    notifyListeners();

    _publicFolders = await _folderService.getPublicFolders();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createFolder(FolderModel folder) async {
    await _folderService.createFolder(folder);
    await loadFolders(folder.artistId);
  }

  Future<void> toggleFolderVisibility(String folderId, bool isPublic) async {
    await _folderService.updateFolderVisibility(folderId, isPublic);
    notifyListeners();
  }
}
