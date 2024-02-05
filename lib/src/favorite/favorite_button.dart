import 'package:flutter/material.dart';
import 'package:photo_wall/src/favorite/favorite_state.dart';
import 'package:provider/provider.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.dir,
  });

  final String dir;

  @override
  Widget build(BuildContext context) {
    var favoriteSate = context.watch<FavoriteState>();

    final icon = favoriteSate.favoriteDirs.contains(dir)
        ? const Icon(
            Icons.favorite,
            color: Colors.red,
          )
        : const Icon(Icons.favorite_border);
    return IconButton(
      icon: icon,
      onPressed: () {
        favoriteSate.toggleFavoriteDir(dir);
      },
    );
  }
}
