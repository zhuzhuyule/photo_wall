import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_wall/src/common/empty.dart';
import 'package:photo_wall/src/const.dart';
import 'package:photo_wall/src/explorer/explorer_view.dart';
import 'package:photo_wall/src/main/background_blur.dart';
import 'package:photo_wall/src/main/background_image.dart';
import 'animated_image.dart';
import 'package:flutter/foundation.dart';
import 'package:photo_view/photo_view.dart';

class WallView extends StatefulWidget {
  const WallView({super.key, this.images = const []});

  final List<String> images;

  @override
  _WallViewState createState() => _WallViewState();
}

class _WallViewState extends State<WallView> {
  late String bgSrc = '';

  final List<String> images = [];
  final List<String> historyImages = [];
  final List<String> displayImages = [];
  late String previewImage = '';

  @override
  void initState() {
    super.initState();
    initStatus();
  }

  @override
  void didUpdateWidget(covariant WallView oldWidget) {
    super.didUpdateWidget(oldWidget);
    initStatus();
  }

  @override
  Widget build(BuildContext context) {
    // final imageService = Provider.of<ImageService>(context);
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          bgSrc == '' ? const Empty() : BackgroundImage(bgSrc: bgSrc),
          const BackgroundBlur(),
          ...renderPhotos(),
          renderPreview(),
          const FloatButton()
        ],
      ),
    );
  }

  Widget renderPreview() {
    return previewImage == ''
        ? const Empty()
        : GestureDetector(
            onTap: () {
              setState(() {
                previewImage = '';
              });
            },
            child: PhotoView(imageProvider: getImageProvider(previewImage)));
  }

  List<Widget> renderPhotos() {
    return displayImages
        .map((url) => AnimationImage(
            key: ValueKey(url),
            url: url,
            previewImage: previewImage,
            onPreview: (String url) {
              setState(() {
                previewImage = url;
              });
            },
            onShowAll: showNewImage,
            onEnd: removeImage))
        .toList();
  }

  void showNewImage() {
    String randomSrc = getRandomSrc(images);
    displayImages.add(randomSrc);
    images.remove(randomSrc);
    if (images.isEmpty && widget.images.isNotEmpty) {
      images.addAll(widget.images);
      historyImages.clear();
    }
    setState(() {});
  }

  void removeImage(String url) {
    displayImages.remove(url);
    historyImages.add(url);
    bgSrc = url;
    setState(() {});
  }

  void initStatus() {
    final newImages =
        widget.images.where((path) => !historyImages.contains(path)).toList();
    if (!listEquals(images, newImages)) {
      images.clear();
      images.addAll(newImages);

      if (images.isNotEmpty) {
        if (bgSrc == '') {
          bgSrc = getRandomSrc(images);
          setState(() {});
        }

        if (displayImages.isEmpty) {
          showNewImage();
        } else if (displayImages.any((item) => !images.contains(item))) {
          displayImages.retainWhere((item) => images.contains(item));
          images.retainWhere((item) => displayImages.contains(item));
          if (images.isEmpty && widget.images.isNotEmpty) {
            images.addAll(widget.images);
            historyImages.clear();
          }
          setState(() {});
        }
      }
    }
  }
}

class FloatButton extends StatelessWidget {
  const FloatButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: FloatingActionButton(
        onPressed: () async {
          Navigator.pushNamed(context, ExplorerView.routeName);
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}

String getRandomSrc(List<String> list) {
  Random random = Random();
  if (list.isEmpty) return '';
  int randomIndex = random.nextInt(list.length);
  return list[randomIndex];
}
