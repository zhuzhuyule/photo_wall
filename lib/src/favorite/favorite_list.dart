import 'package:flutter/material.dart';
import 'package:photo_wall/src/const.dart';
import 'package:photo_wall/src/utils/image_api_helper.dart';
import 'package:provider/provider.dart';

import 'favorite_state.dart';

class FavoriteList extends StatelessWidget {
  const FavoriteList({super.key, required this.isOpen, this.openFolder});

  final bool isOpen;
  final void Function(String path)? openFolder;

  @override
  Widget build(BuildContext context) {
    var favoriteState = context.watch<FavoriteState>();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.fastLinearToSlowEaseIn,
      width: isOpen ? 300 : 0,
      height: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.black26, // 设置左边线的颜色
            width: 1.0, // 设置左边线的宽度
          ),
        ),
      ),
      child: isOpen
          ? ListView(
              children: favoriteState.favoriteDirs.map((fullPath) {
                return ListTile(
                  onTap: () {
                    openFolder?.call(fullPath);
                  },
                  leading: const Icon(
                    Icons.folder,
                    color: Colors.orangeAccent,
                  ),
                  title: Text(fullPath.split('/').last),
                  subtitle: Text(
                    fullPath
                        .replaceAll(ROOT_PATH, '')
                        .replaceAll(ImageApiHelper.baseUrl, ''),
                    style: const TextStyle(color: Colors.black26),
                  ),
                );
              }).toList(),
            )
          : const Text(''),
    );
  }
}
