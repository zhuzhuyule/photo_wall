import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_wall/src/const.dart';
import 'package:photo_wall/src/explorer/breadcrumb.dart';
import 'package:photo_wall/src/explorer/file_view.dart';

class FileBrowser extends StatefulWidget {
  final String dir;
  const FileBrowser({super.key, required this.dir});

  @override
  State<FileBrowser> createState() => _FileBrowserState();
}

class _FileBrowserState extends State<FileBrowser> {
  late String dir;

  late bool isOpen = false;

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
          padding: const EdgeInsets.only(
            left: 18,
            right: 18,
          ),
          child: Row(
            children: [
              Expanded(
                child: Breadcrumb(dir: dir, onGoFolder: onGoFolder),
              ),
              dir != ROOT_PATH
                  ? IconButton(
                      icon: const Icon(Icons.reply),
                      onPressed: onBackFolder,
                    )
                  : const Text(''),
              IconButton(
                icon: const Icon(Icons.favorite),
                onPressed: () {
                  onBackFolder();
                },
              ),
              IconButton(
                icon: Icon(isOpen ? Icons.view_list_outlined : Icons.view_list),
                onPressed: () {
                  setState(() {
                    isOpen = !isOpen;
                  });
                },
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.start, // 对齐方式
                children: files.map((fileEntity) {
                  return FileView(
                      file: fileEntity,
                      onPressed: (file) {
                        if (file.statSync().type ==
                            FileSystemEntityType.directory) {
                          setState(() {
                            dir = file.path;
                          });
                        }
                      });
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void onBackFolder() {
    RegExp regExp = RegExp(r'/[^/]*$');
    late String newDir = dir.replaceAll(regExp, '');
    if (newDir.contains(ROOT_PATH)) {
      setState(() {
        dir = newDir;
      });
    }
  }

  void onGoFolder(String path) {
    if (path.contains(ROOT_PATH)) {
      setState(() {
        dir = path;
      });
    }
  }
}
