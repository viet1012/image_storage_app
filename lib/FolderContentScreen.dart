import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import 'Common/Common.dart';
import 'Common/CustomAppBar.dart';
import 'DetailScreen.dart';

class FolderContentScreen extends StatefulWidget {
  final String folderPath;
  const FolderContentScreen({super.key, required this.folderPath});

  @override
  _FolderContentScreenState createState() => _FolderContentScreenState();
}

class _FolderContentScreenState extends State<FolderContentScreen> {
  List<FileSystemEntity> mediaFiles = [];

  @override
  void initState() {
    super.initState();
    _loadMediaFiles();
  }

  Future<void> _loadMediaFiles() async {
    final folderDir = Directory(widget.folderPath);
    setState(() {
      mediaFiles = folderDir.listSync().where((item) => item is File).toList();
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
                  _pickMedia(isImage: true);
                },
              ),
              ListTile(
                leading: Icon(Icons.video_library),
                title: Text('Chọn video'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickMedia(isImage: false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickMedia({required bool isImage}) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? media = isImage
        ? await _picker.pickImage(source: ImageSource.gallery)
        : await _picker.pickVideo(source: ImageSource.gallery);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Media in ${widget.folderPath.split('/').last}',
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
                    title: Text('Media ${index + 1}'),
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
