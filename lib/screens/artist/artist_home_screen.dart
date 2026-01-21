import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/folder_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/folder_model.dart';
import '../../models/track_model.dart';
import '../../services/music_track_service.dart';
import 'package:uuid/uuid.dart';

class ArtistHomeScreen extends StatefulWidget {
  const ArtistHomeScreen({super.key});

  @override
  State<ArtistHomeScreen> createState() => _ArtistHomeScreenState();
}

class _ArtistHomeScreenState extends State<ArtistHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser != null) {
        context.read<FolderProvider>().loadFolders(auth.currentUser!.id);
      }
      context.read<FolderProvider>().loadPublicFolders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _NewsfeedTab(),
      const _MyFoldersTab(),
      const _ProfileTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('YUSIC'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Newsfeed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'My Folders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () => _showCreateFolderDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
    final nameController = TextEditingController();
    bool isPublic = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Folder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Folder Name',
                  hintText: 'Enter folder name',
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Public Folder'),
                subtitle: const Text('Visible in newsfeed'),
                value: isPublic,
                onChanged: (value) {
                  setState(() => isPublic = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final auth = context.read<AuthProvider>();
                  final folder = FolderModel(
                    id: const Uuid().v4(),
                    artistId: auth.currentUser!.id,
                    name: nameController.text,
                    isPublic: isPublic,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  context.read<FolderProvider>().createFolder(folder);
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsfeedTab extends StatelessWidget {
  const _NewsfeedTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<FolderProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.publicFolders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.music_note, size: 64, color: AppTheme.textHint),
                SizedBox(height: 16),
                Text('No public folders yet'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.publicFolders.length,
          itemBuilder: (context, index) {
            final folder = provider.publicFolders[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                onTap: () => _navigateToFolderDetails(context, folder),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.folder, color: Colors.white),
                ),
                title: Text(folder.name),
                subtitle: Text('${folder.trackCount} tracks'),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => _navigateToFolderDetails(context, folder),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToFolderDetails(BuildContext context, FolderModel folder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FolderDetailsScreen(folder: folder),
      ),
    );
  }
}

class _MyFoldersTab extends StatelessWidget {
  const _MyFoldersTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<FolderProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.folders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 64, color: AppTheme.textHint),
                SizedBox(height: 16),
                Text('No folders yet'),
                SizedBox(height: 8),
                Text(
                  'Tap + to create your first folder',
                  style: TextStyle(color: AppTheme.textHint),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.folders.length,
          itemBuilder: (context, index) {
            final folder = provider.folders[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                onTap: () => _navigateToFolderDetails(context, folder),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: folder.isPublic
                        ? AppTheme.primaryGradient
                        : AppTheme.secondaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    folder.isPublic ? Icons.folder : Icons.folder_special,
                    color: Colors.white,
                  ),
                ),
                title: Text(folder.name),
                subtitle: Text(
                  folder.isPublic
                      ? 'Public • ${folder.trackCount} tracks'
                      : 'Private • ${folder.trackCount} tracks',
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: ListTile(
                        leading:
                            Icon(folder.isPublic ? Icons.lock : Icons.public),
                        title: Text(
                            folder.isPublic ? 'Make Private' : 'Make Public'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onTap: () {
                        provider.toggleFolderVisibility(
                            folder.id, !folder.isPublic);
                      },
                    ),
                    const PopupMenuItem(
                      child: ListTile(
                        leading: Icon(Icons.delete),
                        title: Text('Delete'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToFolderDetails(BuildContext context, FolderModel folder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FolderDetailsScreen(folder: folder),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final user = auth.currentUser;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.folder_special),
                      title: const Text('Private Folders'),
                      trailing: Text(
                        '${user.privateFolderCount}/${user.privateFolderLimit}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (user.privateFolderCount >= user.privateFolderLimit)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Purchase more folders
                          },
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('Buy More Folders'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.errorColor),
              title: const Text('Logout',
                  style: TextStyle(color: AppTheme.errorColor)),
              onTap: () {
                auth.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }
}

// Folder Details Screen
class _FolderDetailsScreen extends StatefulWidget {
  final FolderModel folder;

  const _FolderDetailsScreen({required this.folder});

  @override
  State<_FolderDetailsScreen> createState() => _FolderDetailsScreenState();
}

class _FolderDetailsScreenState extends State<_FolderDetailsScreen> {
  List<TrackModel> _tracks = [];
  bool _isLoading = true;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playTrack(TrackModel track) async {
    try {
      // For web, open audio in new tab or use url_launcher
      if (kIsWeb) {
        final uri = Uri.parse(track.audioUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening: ${track.audioUrl}'),
                backgroundColor: AppTheme.primaryColor,
              ),
            );
          }
        }
      } else {
        // For mobile/desktop, use audioplayers
        await _audioPlayer.play(UrlSource(track.audioUrl));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Playing: ${track.title}'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing track: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _loadTracks() async {
    setState(() => _isLoading = true);
    try {
      final service = MusicTrackService();
      final tracks = await service.getArtistTracks(widget.folder.artistId);
      setState(() {
        _tracks = tracks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading tracks: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tracks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.music_note,
                          size: 80, color: AppTheme.textHint),
                      const SizedBox(height: 16),
                      const Text('No tracks in this folder'),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showAddTrackDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Your First Track'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tracks.length,
                  itemBuilder: (context, index) {
                    final track = _tracks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              const Icon(Icons.music_note, color: Colors.white),
                        ),
                        title: Text(track.title),
                        subtitle: Text(track.artist ?? 'Unknown Artist'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                '${track.duration ~/ 60}:${(track.duration % 60).toString().padLeft(2, '0')}'),
                            IconButton(
                              icon: const Icon(Icons.play_arrow),
                              onPressed: () => _playTrack(track),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTrackDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTrackDialog(BuildContext context) {
    final titleController = TextEditingController();
    final artistController = TextEditingController();
    final durationController = TextEditingController(text: '180');
    Uint8List? audioFileBytes;
    String? audioFileName;
    bool isUploading = false;
    double uploadProgress = 0.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Track'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Track Title',
                    hintText: 'Enter track title',
                    prefixIcon: Icon(Icons.music_note),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: artistController,
                  decoration: const InputDecoration(
                    labelText: 'Artist Name',
                    hintText: 'Enter artist name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration (seconds)',
                    hintText: 'Enter duration in seconds',
                    prefixIcon: Icon(Icons.timer),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: isUploading
                      ? null
                      : () async {
                          try {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.audio,
                              allowMultiple: false,
                              withData: true,
                            );

                            if (result != null && result.files.isNotEmpty) {
                              final file = result.files.first;
                              setDialogState(() {
                                audioFileBytes = file.bytes;
                                audioFileName = file.name;
                              });

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Selected: ${file.name}'),
                                  backgroundColor: AppTheme.successColor,
                                ),
                              );
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error picking file: $e'),
                                backgroundColor: AppTheme.errorColor,
                              ),
                            );
                          }
                        },
                  icon: Icon(audioFileBytes != null
                      ? Icons.check_circle
                      : Icons.upload_file),
                  label: Text(audioFileName ?? 'Choose Audio File'),
                ),
                if (isUploading) const SizedBox(height: 16),
                if (isUploading) LinearProgressIndicator(value: uploadProgress),
                if (isUploading) const SizedBox(height: 8),
                if (isUploading)
                  Text('Uploading: ${(uploadProgress * 100).toInt()}%'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUploading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isUploading || audioFileBytes == null
                  ? null
                  : () async {
                      if (titleController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a track title'),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                        return;
                      }

                      setDialogState(() {
                        isUploading = true;
                        uploadProgress = 0.0;
                      });

                      try {
                        final auth = context.read<AuthProvider>();
                        if (auth.currentUser == null)
                          throw Exception('Not authenticated');

                        final service = MusicTrackService();

                        // Upload to Supabase
                        await service.uploadTrack(
                          fileBytes: audioFileBytes!,
                          fileName: audioFileName!,
                          title: titleController.text,
                          artistName: artistController.text.isNotEmpty
                              ? artistController.text
                              : null,
                          artistId: auth.currentUser!.id,
                          folderId: widget.folder.id,
                          duration:
                              int.tryParse(durationController.text) ?? 180,
                          onProgress: (progress) {
                            setDialogState(() {
                              uploadProgress = progress;
                            });
                          },
                        );

                        // Reload tracks from database
                        await _loadTracks();

                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Track uploaded successfully!'),
                            backgroundColor: AppTheme.successColor,
                          ),
                        );
                      } catch (e) {
                        setDialogState(() {
                          isUploading = false;
                        });

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Upload failed: $e'),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                      }
                    },
              child: const Text('Upload Track'),
            ),
          ],
        ),
      ),
    );
  }
}
