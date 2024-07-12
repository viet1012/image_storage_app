import 'dart:io';

import 'package:flutter/material.dart';

import 'Common/CustomAppBar.dart';

class DetailScreen extends StatelessWidget {
  final String imagePath;
  DetailScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Image Detail',
      ),
      body: Center(
        child: Hero(
          tag: imagePath,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
