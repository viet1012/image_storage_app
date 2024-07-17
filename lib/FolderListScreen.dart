import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Common/Common.dart';
import 'Common/CustomAppBar.dart';
import 'Common/CustomElevatedButton.dart';
import 'FolderContentScreen.dart';

class FolderListScreen extends StatefulWidget {
  @override
  _FolderListScreenState createState() => _FolderListScreenState();
}

class _FolderListScreenState extends State<FolderListScreen> {
  List<String> folders = [];
  List<bool> isCircle = []; // List to store circle shape states

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final directory = await getApplicationDocumentsDirectory();
    final folderDir = Directory('${directory.path}/image_storage');
    if (!await folderDir.exists()) {
      await folderDir.create(recursive: true);
    }
    setState(() {
      folders = folderDir
          .listSync()
          .where((item) => item is Directory)
          .map((item) => item.path)
          .toList();
      isCircle = List.generate(folders.length, (index) => true);
    });
  }

  Future<void> _createFolder(String folderName, String password) async {
    final directory = await getApplicationDocumentsDirectory();
    final folderDir = Directory('${directory.path}/image_storage/$folderName');
    print("folderDir: ${folderDir.path}");
    if (!await folderDir.exists()) {
      await folderDir.create(recursive: true);
    }
    await _setPassword(folderName, password);
    _loadFolders();
  }

  Future<void> _deleteFolder(String folderName) async {
    final directory = await getApplicationDocumentsDirectory();
    final folderDir = Directory('${directory.path}/image_storage/$folderName');
    if (await folderDir.exists()) {
      await folderDir.delete(recursive: true);
      await _removePassword(folderName);
      _loadFolders();
    }
  }

  Future<void> _checkPassword(String folderName) async {
    final password = await _getPassword(folderName);
    print("password: $password");
    if (password != null) {
      final enteredPassword = await _displayPasswordDialog();
      if (enteredPassword == null) {
        return;
      }
      if (enteredPassword == password) {
        _navigateToFolderContent(folderName);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Incorrect password')));
      }
    } else {
      _navigateToFolderContent(folderName);
    }
  }

  Future<String?> _displayPasswordDialog() async {
    TextEditingController _controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Password'),
          content: TextField(
            controller: _controller,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Password'),
          ),
          actions: [
            CustomElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: 'Cancel',
            ),
            CustomElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_controller.text);
              },
              text: 'OK',
            ),
          ],
        );
      },
    );
  }

  Future<void> _renameFolder(String oldFolderName, String newFolderName) async {
    final directory = await getApplicationDocumentsDirectory();
    final oldFolderDir =
        Directory('${directory.path}/image_storage/$oldFolderName');
    final newFolderDir =
        Directory('${directory.path}/image_storage/$newFolderName');

    if (await oldFolderDir.exists() && !await newFolderDir.exists()) {
      await oldFolderDir.rename(newFolderDir.path);
      final password = await _getPassword(oldFolderName);
      if (password != null) {
        await _setPassword(newFolderName, password);
        await _removePassword(oldFolderName);
      }
      _loadFolders();
    }
  }

  Future<void> _setPassword(String folderName, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password_$folderName', password);
  }

  Future<void> _removePassword(String folderName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('password_$folderName');
  }

  Future<String?> _getPassword(String folderName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('password_$folderName');
  }

  Future<void> _changePassword(String folderName) async {
    final newPassword = await _displayNewPasswordDialog();
    if (newPassword != null && newPassword.isNotEmpty) {
      await _setPassword(folderName, newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
    }
  }

  String convertToInitials(String fullName) {
    String initials = '';
    List<String> nameParts = fullName.split(' ');
    for (var item in nameParts) {
      if (item.isNotEmpty) initials += item[0];
    }
    return initials.toUpperCase();
  }

  Future<String?> _displayNewPasswordDialog() async {
    TextEditingController _controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter New Password'),
          content: TextField(
            controller: _controller,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'New Password'),
          ),
          actions: [
            CustomElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: 'Cancel',
            ),
            CustomElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_controller.text);
              },
              text: 'OK',
            ),
          ],
        );
      },
    );
  }

  void _navigateToFolderContent(String folderName) {
    final folderPath =
        folders.firstWhere((folder) => folder.split('/').last == folderName);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderContentScreen(folderPath: folderPath),
      ),
    );
  }

  void _toggleShape(int index) {
    setState(() {
      isCircle[index] =
          !isCircle[index]; // Toggle the state of the selected item
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Folders',
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
        child: folders.isEmpty
            ? const Center(
                child: Text(
                  'No folders found',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: folders.length,
                itemBuilder: (context, index) {
                  final folderPath = folders[index];
                  final folderName = folderPath.split('/').last;
                  return Card(
                    elevation: 2,
                    color: Colors.white12,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: isCircle[index]
                          ? BorderRadius.circular(200)
                          : BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.shade300, width: 2),
                    ),

                    // ĐANG SỬA Ở ĐÂY
                    child: isCircle[index]
                        ? Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () => _toggleShape(index),
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: const BoxDecoration(
                                  color: Colors.deepPurpleAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Text(
                                      convertToInitials(folderName),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : ListTile(
                            title: GestureDetector(
                              onTap: () => _toggleShape(index),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.deepPurpleAccent,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    bottomRight: Radius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  textAlign: TextAlign.center,
                                  folderName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            onTap: () async {
                              await _checkPassword(folderName);
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.lock,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    await _changePassword(folderName);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    final newName =
                                        await _displayRenameDialog(folderName);
                                    if (newName != null && newName.isNotEmpty) {
                                      await _renameFolder(folderName, newName);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    final confirm = await Dialogs
                                        .showDeleteConfirmationDialog(
                                            context,
                                            'Delete Folder',
                                            'Are you sure you want to delete this folder?');
                                    if (confirm == true) {
                                      _deleteFolder(folderName);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await _displayFolderCreationDialog();
          if (result != null && result[0].isNotEmpty) {
            _createFolder(result[0], result[1]);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<String?> _displayRenameDialog(String oldFolderName) async {
    TextEditingController _controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Rename Folder',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'New Folder Name'),
          ),
          actions: [
            CustomElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: 'Cancel',
            ),
            CustomElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_controller.text);
              },
              text: 'OK',
            ),
          ],
        );
      },
    );
  }

  Future<List<String>?> _displayFolderCreationDialog() async {
    TextEditingController _folderNameController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();

    return showDialog<List<String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Create Folder',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _folderNameController,
                  decoration: const InputDecoration(
                    labelText: 'Folder Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password (optional)',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            CustomElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: 'Cancel',
            ),
            CustomElevatedButton(
              onPressed: () {
                Navigator.of(context).pop([
                  _folderNameController.text,
                  _passwordController.text,
                ]);
              },
              text: 'Create',
            ),
          ],
        );
      },
    );
  }
}
