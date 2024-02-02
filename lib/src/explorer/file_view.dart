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

    // 根据文件类型设置相应的图标和文件名
    if (file is File) {
      iconData = Icons.insert_drive_file_outlined;
      fileName = file.path.split('/').last;
    } else if (file is Directory) {
      iconData = Icons.folder;
      fileName = file.path.split('/').last;
    } else {
      iconData = Icons.insert_drive_file_outlined;
      fileName = 'Unknown';
    }

    return GestureDetector(
      onTap: () => onPressed(file),
      child: SizedBox(
        width: 100,
        child: Column(
          children: [
            Icon(
              iconData,
              size: 50,
              color: file is Directory ? Colors.orangeAccent : Colors.grey,
            ),
            Text(fileName),
          ],
        ),
      ),
    );
  }
}
