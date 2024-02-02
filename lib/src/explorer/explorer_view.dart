import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_wall/src/explorer/file_browser.dart';
import 'package:permission_handler/permission_handler.dart';

class ExplorerView extends StatefulWidget {
  const ExplorerView({super.key});
  static const routeName = '/explorer';

  @override
  State<ExplorerView> createState() => _ExplorerViewState();
}

class _ExplorerViewState extends State<ExplorerView> {
  late String src = '';
  late List<FileSystemEntity> files = [];

  late String dir;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    dir = '/storage/emulated/0';
  }

  Future<void> requestPermissions() async {
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      // 权限已授予，可以访问外部存储空间
    } else {
      // 权限被拒绝，无法访问外部存储空间
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorer'),
      ),
      body: FileBrowser(
        dir: dir,
      ),
    );
  }

  Future<void> _loadImages() async {
    try {
      // 获取设备上的图片目录
      // Directory? appDir = await getExternalStorageDirectory();
      Directory imageDir = Directory('/storage/emulated/0');

      // // 获取目录下的图片文件列表
      List<FileSystemEntity> files = imageDir.listSync();
      // List<File> images = files.whereType<File>().toList();

      print(files.map((item) => item.path + item.uri.path));
      // setState(() {
      //   _imageFiles = images;
      // });
    } catch (e) {
      print('Error loading images: $e');
    }
  }
}
