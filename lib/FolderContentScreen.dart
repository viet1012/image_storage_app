import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import 'Common/Common.dart';
import 'DetailScreen.dart';

enum SortOption { name, date, size }

class FolderContentScreen extends StatefulWidget {
  final String folderPath;
  const FolderContentScreen({super.key, required this.folderPath});

  @override
  _FolderContentScreenState createState() => _FolderContentScreenState();
}

class _FolderContentScreenState extends State<FolderContentScreen> {
  List<FileSystemEntity> mediaFiles = [];
  SortOption _sortOption = SortOption.name;

  @override
  void initState() {
    super.initState();
    _loadMediaFiles();
  }

  Future<void> _loadMediaFiles() async {
    final folderDir = Directory(widget.folderPath);
    setState(() {
      mediaFiles = folderDir.listSync().where((item) => item is File).toList();
      _sortMediaFiles();
    });
  }

  Future<void> _showMediaPicker(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('Chọn ảnh'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImages();
                },
              ),
              ListTile(
                leading: Icon(Icons.video_library),
                title: Text('Chọn video'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickVideo();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImages() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? images = await _picker.pickMultiImage();

    if (images != null) {
      for (var image in images) {
        final File newImage = File('${widget.folderPath}/${image.name}');
        await File(image.path).copy(newImage.path);
      }
      _loadMediaFiles();
    }
  }

  Future<void> _pickVideo() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? media = await _picker.pickVideo(source: ImageSource.gallery);

    if (media != null) {
      final File newMedia = File('${widget.folderPath}/${media.name}');
      await File(media.path).copy(newMedia.path);
      _loadMediaFiles();
    }
  }

  Future<void> _deleteMedia(String mediaPath) async {
    final shouldDelete = await Dialogs.showDeleteConfirmationDialog(
        context, 'Delete Media', 'Are you sure you want to delete this media?');
    if (shouldDelete == true) {
      try {
        final file = File(mediaPath);
        await file.delete();
        _loadMediaFiles();
      } catch (e) {
        print('Failed to delete media: $e');
      }
    }
  }

  void _sortMediaFiles() {
    switch (_sortOption) {
      case SortOption.name:
        mediaFiles.sort((a, b) => a.path.compareTo(b.path));
        break;
      case SortOption.date:
        mediaFiles.sort((a, b) => File(a.path)
            .lastModifiedSync()
            .compareTo(File(b.path).lastModifiedSync()));
        break;
      case SortOption.size:
        mediaFiles.sort((a, b) =>
            File(a.path).lengthSync().compareTo(File(b.path).lengthSync()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Media in ${widget.folderPath.split('/').last}'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepPurple,
                Colors.white,
              ],
            ),
          ),
        ),
        actions: [
          PopupMenuButton<SortOption>(
            onSelected: (SortOption result) {
              setState(() {
                _sortOption = result;
                _sortMediaFiles();
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              const PopupMenuItem<SortOption>(
                value: SortOption.name,
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.date,
                child: Text('Sort by Date'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.size,
                child: Text('Sort by Size'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade900, Colors.deepPurple.shade400],
          ),
        ),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: mediaFiles.length,
          itemBuilder: (context, index) {
            final media = mediaFiles[index];
            final isVideo = media.path.endsWith('.mp4');

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DetailScreen(mediaPath: media.path, isVideo: isVideo),
                  ),
                );
              },
              child: Hero(
                tag: media.path,
                child: GridTile(
                  footer: GridTileBar(
                    backgroundColor: Colors.black54,
                    title: isVideo
                        ? Text('VD ${index + 1}')
                        : Text('IMG ${index + 1}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteMedia(media.path);
                      },
                      color: Colors.white,
                    ),
                  ),
                  child: isVideo
                      ? FutureBuilder<VideoPlayerController>(
                          future: _initializeVideoPlayer(media.path),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return AspectRatio(
                                aspectRatio: snapshot.data!.value.aspectRatio,
                                child: VideoPlayer(snapshot.data!),
                              );
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                        )
                      : Image.file(
                          File(media.path),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMediaPicker(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<VideoPlayerController> _initializeVideoPlayer(String path) async {
    final controller = VideoPlayerController.file(File(path));
    await controller.initialize();
    return controller;
  }
}
