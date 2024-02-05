import 'dart:io';
import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_wall/src/common/empty.dart';
import 'package:photo_wall/src/explorer/explorer_view.dart';
import 'animated_image.dart';
import 'package:flutter/foundation.dart';

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

  void showNewImage() {
    String randomSrc = getRandomSrc(images);
    displayImages.add(randomSrc);
    images.remove(randomSrc);
    setState(() {});
  }

  void removeImage(String url) {
    displayImages.remove(url);
    historyImages.add(url);
    bgSrc = url;
    setState(() {});
  }

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
          setState(() {});
        }
      }
    }
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
          const FloatButton()
        ],
      ),
    );
  }

  List<Widget> renderPhotos() {
    return displayImages
        .map((url) => AnimationImage(
            key: ValueKey(url),
            url: url,
            onShowAll: showNewImage,
            onEnd: removeImage))
        .toList();
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

class BackgroundBlur extends StatelessWidget {
  const BackgroundBlur({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
      child: Container(
        color: Colors.transparent,
      ),
    );
  }
}

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({
    super.key,
    required this.bgSrc,
  });

  final String bgSrc;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      key: ValueKey('bg $bgSrc'),
      File(bgSrc),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}

String getRandomSrc(List<String> list) {
  Random random = Random();
  if (list.isEmpty) return '';
  int randomIndex = random.nextInt(list.length);
  return list[randomIndex];
}
