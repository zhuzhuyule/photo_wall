import 'package:flutter/material.dart';
import 'package:photo_wall/src/const.dart';

class Breadcrumb extends StatelessWidget {
  const Breadcrumb({
    super.key,
    required this.dir,
    required this.onGoFolder,
  });

  final String dir;
  final void Function(String path) onGoFolder;

  @override
  Widget build(BuildContext context) {
    final List<String> items = [];
    for (var name in dir.replaceAll(ROOT_PATH, '/').split('/')) {
      if (name.isNotEmpty) {
        items.add(name);
      }
    }

    return Row(children: [
      IconButton(
          icon: const Icon(Icons.folder_open),
          onPressed: () {
            onGoFolder(ROOT_PATH);
          }),
      ...items
          .map((text) => BreadcrumbItem(text: text, onPressed: () {}))
          .toList()
    ]);
  }
}

class BreadcrumbItem extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const BreadcrumbItem(
      {super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.chevron_right,
          size: 22,
          color: Colors.grey,
        ),
        GestureDetector(
          onTap: onPressed,
          child: Text(
            text,
            style: const TextStyle(fontSize: 22),
          ),
        ),
      ],
    );
  }
}
