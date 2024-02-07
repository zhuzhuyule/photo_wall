import 'package:flutter/material.dart';
import 'package:photo_wall/src/explorer/breadcrumb.dart';
import 'package:photo_wall/src/favorite/favorite_button.dart';
import 'package:photo_wall/src/favorite/favorite_list.dart';
import 'package:photo_wall/src/utils/image_api_helper.dart';

import 'network_window.dart';

class NetworkBrowser extends StatefulWidget {
  final String dir;
  const NetworkBrowser({super.key, required this.dir});

  @override
  State<NetworkBrowser> createState() => _NetworkBrowserState();
}

class _NetworkBrowserState extends State<NetworkBrowser> {
  late String dir;

  late bool isOpen = false;

  @override
  void initState() {
    super.initState();
    dir = widget.dir.replaceAll(ImageApiHelper.baseUrl, '');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          child: Row(
            children: [
              Expanded(
                child: Breadcrumb(dir: dir, openFolder: openFolder),
              ),
              dir != '/'
                  ? IconButton(
                      icon: const Icon(Icons.reply),
                      onPressed: onBackFolder,
                    )
                  : const Text(''),
              FavoriteButton(dir: '${ImageApiHelper.baseUrl}$dir'),
              IconButton(
                icon: Icon(isOpen ? Icons.view_list_outlined : Icons.view_list),
                onPressed: () {
                  isOpen = !isOpen;
                  setState(() {});
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
                  child: NetworkWindow(
                      key: ValueKey(dir), dir: dir, onPressed: openFolder),
                )),
              ),
              FavoriteList(isOpen: isOpen, openFolder: openFolder)
            ],
          ),
        ),
      ],
    );
  }

  void onBackFolder() {
    RegExp regExp = RegExp(r'/[^/]*$');
    late String newDir = dir.replaceAll(regExp, '');
    if (newDir.startsWith('/')) {
      setState(() {
        dir = newDir;
      });
    }
  }

  void openFolder(String path) {
    setState(() {
      dir = path
          .replaceAll(ImageApiHelper.baseUrl, '')
          .replaceAll(RegExp('/+'), '/');
    });
  }
}
