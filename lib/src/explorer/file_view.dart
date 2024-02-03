import 'dart:io';

import 'package:flutter/material.dart';

typedef VoidCallback = void Function(FileSystemEntity file);

class FileView extends StatelessWidget {
  final FileSystemEntity file;
  final VoidCallback onPressed;

  const FileView({
    super.key,
    required this.file,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    String fileName = '';
    Color color = Colors.grey;

    // 根据文件类型设置相应的图标和文件名
    if (file is File) {
      iconData = Icons.insert_drive_file_outlined;
      fileName = file.path.split('/').last;
    } else if (file is Directory) {
      iconData = Icons.folder;
      color = Colors.orangeAccent;
      fileName = file.path.split('/').last;
    } else {
      iconData = Icons.insert_drive_file_outlined;
      fileName = 'Unknown';
    }

    if (isImageFile(fileName)) {
      iconData = Icons.image;
      color = Colors.blue;
    }

    return GestureDetector(
      onTap: () {
        if (file.statSync().type == FileSystemEntityType.directory) {
          onPressed(file);
        }
      },
      child: SizedBox(
        width: 100,
        child: Column(
          children: [
            Icon(
              iconData,
              size: 50,
              color: color,
            ),
            Text(fileName),
          ],
        ),
      ),
    );
  }
}

bool isImageFile(String fileName) {
  String extension = fileName.toLowerCase();
  if (extension.endsWith('.jpg') ||
      extension.endsWith('.jpeg') ||
      extension.endsWith('.png') ||
      extension.endsWith('.gif') ||
      extension.endsWith('.bmp')) {
    return true;
  } else {
    return false;
  }
}
