import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_wall/src/explorer/file_view.dart';

class FileBrowser extends StatefulWidget {
  final String dir;
  const FileBrowser({super.key, required this.dir});

  @override
  State<FileBrowser> createState() => _FileBrowserState();
}

class _FileBrowserState extends State<FileBrowser> {
  late String dir;

  @override
  void initState() {
    super.initState();
    dir = widget.dir;
  }

  @override
  Widget build(BuildContext context) {
    final List<FileSystemEntity> files = Directory(dir)
        .listSync(); //.sort((file1, file2) => file1.path.compareTo(file2.path));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(dir),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.start, // 对齐方式
              children: files.map((fileEntity) {
                return FileView(
                    file: fileEntity,
                    onPressed: (file) {
                      setState(() {
                        dir = file.path;
                      });
                    });
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
