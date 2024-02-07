import 'package:flutter/material.dart';
import 'package:photo_wall/src/utils/image_api_helper.dart';

import 'network_file.dart';

class NetworkWindow extends StatefulWidget {
  final String dir;
  final void Function(String path) onPressed;

  const NetworkWindow({
    super.key,
    required this.dir,
    required this.onPressed,
  });

  @override
  State<NetworkWindow> createState() => _NetworkWindowState();
}

class _NetworkWindowState extends State<NetworkWindow> {
  late FutureResult<List<TFileInfo>>? data;
  late String? preDir;

  @override
  void initState() {
    super.initState();
    data = null;
    preDir = null;
  }

  @override
  Widget build(BuildContext context) {
    final dir = widget.dir;
    if (dir != preDir) {
      data = null;
    }
    preDir = dir;
    return FutureBuilder(
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
          return Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            alignment: WrapAlignment.start, // 对齐方式
            children: data!.result.map((file) {
              return NetworkFile(
                  file: file,
                  onView: (file) {
                    // _dialogBuilder(context, file);
                  },
                  onPressed: (file) {
                    widget.onPressed.call(
                        dir == '/' ? '/${file.name}' : '$dir/${file.name}');
                  });
            }).toList(),
          );
        });
  }
}
