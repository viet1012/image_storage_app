import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'Common/CustomAppBar.dart';
import 'DetailScreen.dart';

class FolderContentScreen extends StatefulWidget {
  final String folderPath;
  FolderContentScreen({required this.folderPath});

  @override
  _FolderContentScreenState createState() => _FolderContentScreenState();
}

class _FolderContentScreenState extends State<FolderContentScreen> {
  List<String> images = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final folderDir = Directory(widget.folderPath);
    setState(() {
      images = folderDir
          .listSync()
          .where((item) => item is File)
          .map((item) => item.path)
          .toList();
    });
  }

  Future<void> _addImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final File newImage = File('${widget.folderPath}/${image.name}');
      await File(image.path).copy(newImage.path);
      _loadImages();
    }
  }

  Future<void> _deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      await file.delete();
      _loadImages();
    } catch (e) {
      print('Failed to delete image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Images in ${widget.folderPath.split('/').last}',
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
          itemCount: images.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DetailScreen(imagePath: images[index]),
                  ),
                );
              },
              child: Hero(
                tag: images[index],
                child: GridTile(
                  footer: GridTileBar(
                    backgroundColor: Colors.black54,
                    title: Text('Image ${index + 1}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteImage(images[index]);
                      },
                      color: Colors.white,
                    ),
                  ),
                  child: Image.file(
                    File(images[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addImage,
        child: Icon(Icons.add),
        backgroundColor:
            Colors.blue, // Thay đổi màu nút Floating Action Button tùy ý
      ),
    );
  }
}
