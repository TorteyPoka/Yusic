import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/folder_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/folder_model.dart';
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
                  onPressed: () {},
                ),
              ),
            );
          },
        );
      },
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
