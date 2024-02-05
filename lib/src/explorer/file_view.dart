import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_wall/src/utils/file.dart';

class FileView extends StatelessWidget {
  final FileSystemEntity file;
  final void Function(FileSystemEntity file) onPressed;
  final void Function(FileSystemEntity file) onView;

  const FileView({
    super.key,
    required this.file,
    required this.onPressed,
    required this.onView,
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

    final isImage = isImageFile(fileName);

    if (isImage) {
      iconData = Icons.image;
      color = Colors.blue;
    }

    return GestureDetector(
      onTap: () {
        if (isImage) {
          onView(file);
        } else if (file.statSync().type == FileSystemEntityType.directory) {
          onPressed(file);
        }
      },
      child: SizedBox(
        width: 100,
        child: Column(
          children: [
            // isImage
            //     ? Image.file(file as File)
            //     :
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
