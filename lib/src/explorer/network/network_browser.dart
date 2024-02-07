import 'package:flutter/material.dart';
import 'package:photo_wall/src/explorer/breadcrumb.dart';
import 'package:photo_wall/src/favorite/favorite_button.dart';
import 'package:photo_wall/src/favorite/favorite_list.dart';
import 'package:photo_wall/src/utils/image_api_helper.dart';

import 'network_view.dart';

class NetworkBrowser extends StatefulWidget {
  final String dir;
  const NetworkBrowser({super.key, required this.dir});

  @override
  State<NetworkBrowser> createState() => _NetworkBrowserState();
}

class _NetworkBrowserState extends State<NetworkBrowser> {
  late String dir;
  late String? preDir;

  late bool isOpen = false;
  late FutureResult<List<TFileInfo>>? data;

  @override
  void initState() {
    super.initState();
    dir = widget.dir.replaceAll(ImageApiHelper.baseUrl, '');
    data = null;
    preDir = null;
  }

  @override
  Widget build(BuildContext context) {
    if (dir != preDir) {
      data = null;
    }
    preDir = dir;
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
          child: FutureBuilder(
              future: data == null
                  ? ImageApiHelper().getDirFiles(dir)
                  : Future.value(data),
              builder: (context, snapshot) {
                if (data == null) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data == null) {
                    return const Text('没有找到文件');
                  }
                  data = snapshot.data;
                }
                return Row(
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
                            children: data!.result.map((file) {
                              return NetworkView(
                                  file: file,
                                  onView: (file) {
                                    // _dialogBuilder(context, file);
                                  },
                                  onPressed: (file) {
                                    setState(() {
                                      dir += dir == '/'
                                          ? file.name
                                          : '/${file.name}';
                                    });
                                  });
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    FavoriteList(isOpen: isOpen, openFolder: openFolder)
                  ],
                );
              }),
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
      dir = path.replaceAll(ImageApiHelper.baseUrl, '');
    });
  }
}
