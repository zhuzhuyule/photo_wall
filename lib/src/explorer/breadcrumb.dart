import 'package:flutter/material.dart';

class Breadcrumb extends StatelessWidget {
  const Breadcrumb({
    super.key,
    required this.dir,
    required this.openFolder,
  });

  final String dir;
  final void Function(String path) openFolder;

  @override
  Widget build(BuildContext context) {
    final List<String> items = [];
    late String path = '/';
    for (var name in dir.split('/')) {
      final str = name.trim();
      if (str.isNotEmpty) {
        path += '/$name';
        items.add(path);
      }
    }

    return Row(children: [
      IconButton(
          icon: const Icon(Icons.folder_open),
          onPressed: () {
            openFolder('/');
          }),
      ...items
          .sublist(0, items.length > 1 ? items.length - 1 : 0)
          .map((path) => BreadcrumbItem(
              text: path.split('/').last,
              onPressed: () {
                openFolder(path);
              }))
          .toList(),

      items.isNotEmpty
          ? BreadcrumbItem(text: (items.last).split('/').last)
          : const Text('') // 最后一个不跳转
    ]);
  }
}

class BreadcrumbItem extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const BreadcrumbItem({super.key, required this.text, this.onPressed});

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
        onPressed != null
            ? GestureDetector(
                onTap: onPressed,
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 22, color: Colors.black12),
                ),
              )
            : Text(
                text,
                style: const TextStyle(fontSize: 22),
              ),
      ],
    );
  }
}
