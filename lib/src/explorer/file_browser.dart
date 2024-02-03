import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:photo_wall/src/const.dart';
import 'package:photo_wall/src/explorer/breadcrumb.dart';
import 'package:photo_wall/src/explorer/file_view.dart';
import 'package:photo_wall/src/favorite/favorite_button.dart';
import 'package:photo_wall/src/favorite/favorite_list.dart';
import 'package:photo_wall/src/settings/settings_controller.dart';
import 'package:provider/provider.dart';

import '../favorite/favorite_state.dart';

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
              FavoriteButton(dir: dir),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.start, // 对齐方式
                      children: filterFiles(sortFiles(files)).map((fileEntity) {
                        return FileView(
                            file: fileEntity,
                            onView: (file) {
                              _dialogBuilder(context, file);
                            },
                            onPressed: (file) {
                              setState(() {
                                dir = file.path;
                              });
                            });
                      }).toList(),
                    ),
                  ),
                ),
              ),
              FavoriteList(isOpen: isOpen)
            ],
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

  List<FileSystemEntity> sortFiles(List<FileSystemEntity> files) {
    files.sort((a, b) {
      bool isDirectoryA = a is Directory;
      bool isDirectoryB = b is Directory;

      if (isDirectoryA && !isDirectoryB) {
        return -1; // 目录排在前面
      } else if (!isDirectoryA && isDirectoryB) {
        return 1; // 文件排在后面
      } else {
        return a.path.compareTo(b.path); // 其他情况按路径字母顺序排序
      }
    });
    return files;
  }

  List<FileSystemEntity> filterFiles(List<FileSystemEntity> files) {
    return files
        .where((file) => !file.path.split('/').last.startsWith('.'))
        .toList();
  }

  Future<void> _dialogBuilder(BuildContext context, FileSystemEntity file) {
    const double imageSizePercentage = 0.8;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * imageSizePercentage,
              maxHeight:
                  MediaQuery.of(context).size.height * imageSizePercentage,
            ),
            child: Image(
              fit: BoxFit.contain,
              image: FileImage(File(file.path)),
              // width: MediaQuery.of(context).size.width * 1,
              // height: MediaQuery.of(context).size.height * 1,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (frame == 0) {
                  return Stack(
                    children: [
                      child,
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.black.withOpacity(0.5),
                          child: Text(
                            file.path.split('/').last,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        );
      },
    );
  }
}
