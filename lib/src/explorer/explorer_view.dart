import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_wall/src/const.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_wall/src/explorer/network/network_browser.dart';

import 'local/file_browser.dart';

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
    dir = ROOT_PATH;
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
        title: const Text('选择图片目录'),
      ),
      body: const NetworkBrowser(
        dir: '',
      ),
      // body: FileBrowser(
      //   dir: dir,
      // ),
    );
  }
}
