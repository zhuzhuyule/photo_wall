import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:photo_wall/src/explorer/explorer_view.dart';
import 'package:photo_wall/src/main/image_service.dart';
import 'package:provider/provider.dart';
import 'animated_image.dart';

class WallView extends StatefulWidget {
  const WallView({super.key});

  @override
  _WallViewState createState() => _WallViewState();
}

class _WallViewState extends State<WallView> {
  bool selected = false;
  int count = 1;

  List<String> list = [];

  void addImage() {
    setState(() {
      count += 1;
      list.add("https://picsum.photos/600/800?random$count");
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildAnimatedContainer(String url) {
      return AnimationImage(
          key: ValueKey(url),
          url: url,
          onEnd: () {
            setState(() {
              list.remove(url);
            });
            addImage();
          });
    }

    return ChangeNotifierProvider(
        create: (_) => ImageService(),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Builder(builder: (context) {
            // final imageService = Provider.of<ImageService>(context);
            return Stack(
              alignment: AlignmentDirectional.centerStart,
              children: [
                Image.network(
                  'https://picsum.photos/600/800',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
                ...list.map((url) => buildAnimatedContainer(url)).toList(),
                Positioned(
                  bottom: 0,
                  child: FloatingActionButton(
                    onPressed: () async {
                      // addImage();
                      Navigator.pushNamed(context, ExplorerView.routeName);
                    },
                    child: const Icon(Icons.play_arrow),
                  ),
                )
              ],
            );
          }),
        ));
  }
}
