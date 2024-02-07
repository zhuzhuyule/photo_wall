import 'package:flutter/material.dart';
import 'package:photo_wall/src/utils/file.dart';
import 'package:photo_wall/src/utils/image_api_helper.dart';

class NetworkFile extends StatelessWidget {
  final TFileInfo file;
  final void Function(TFileInfo file) onPressed;
  final void Function(TFileInfo file) onView;

  const NetworkFile({
    super.key,
    required this.file,
    required this.onPressed,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    String fileName = file.name;
    Color color = Colors.grey;

    // 根据文件类型设置相应的图标和文件名
    if (file.isDir) {
      iconData = Icons.folder;
      color = Colors.orangeAccent;
    } else {
      iconData = Icons.insert_drive_file_outlined;
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
        } else if (file.isDir) {
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
