import 'dart:io';

import 'package:flutter/material.dart';

import 'package:photo_wall/src/utils/file.dart';

import 'image_loader.dart';

class AnimationImage extends StatefulWidget {
  const AnimationImage(
      {Key? key, required this.url, this.onEnd, this.onShowAll})
      : super(key: key);

  final String url;
  final Function(String url)? onEnd;
  final Function? onShowAll;

  @override
  _AnimationImageState createState() => _AnimationImageState();
}

class _AnimationImageState extends State<AnimationImage>
    with TickerProviderStateMixin {
  late Animation<double> leftAnimation;
  late AnimationController leftController;

  late Animation<double> scaleAnimation;
  late AnimationController scaleController;

  late Animation<double> rotateAnimation;
  late AnimationController rotateController;

  final GlobalKey _containerKey = GlobalKey();

  late bool isShowAll = false;

  getController({int seconds = 0, int milliseconds = 0}) {
    return AnimationController(
        duration: Duration(seconds: seconds, milliseconds: milliseconds),
        vsync: this);
  }

  getAnimation(double begin, double end, AnimationController controller,
      [bool repeat = true]) {
    final tween = Tween(begin: begin, end: end);
    late Animation animate;
    if (repeat) {
      final Animation<double> curve =
          CurvedAnimation(parent: controller, curve: Curves.linear);
      animate = tween.animate(curve);
    } else {
      final Animation<double> curve =
          CurvedAnimation(parent: controller, curve: Curves.linear);
      animate = tween.animate(curve);
    }

    return animate;
  }

  @override
  initState() {
    super.initState();
    leftController = getController(seconds: 122);
    leftAnimation =
        getAnimation(screenWidth, -screenWidth, leftController, false);

    scaleController = getController(seconds: 16);
    scaleAnimation = getAnimation(1.0, 1.2, scaleController);

    rotateController = getController(seconds: 15);
    rotateAnimation = getAnimation(-0.1, 0.1, rotateController);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: rotateAnimation,
        child: widget.url.startsWith('http')
            ? Image.network(widget.url)
            : Image.file(File(widget.url)),
        builder: (context, child) {
          return AnimatedBuilder(
              animation: scaleAnimation,
              child: ImageLoader(
                key: ValueKey(widget.url),
                filePath: widget.url,
                onLoaded: (path) {
                  leftController.forward();
                  scaleController.repeat(reverse: true);
                  rotateController.repeat(reverse: true);
                },
                onError: (filePath) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      isShowAll = true;
                    });
                    widget.onShowAll!.call();
                    widget.onEnd?.call(filePath);
                  });
                },
              ),
              builder: (context, child) {
                return Transform.scale(
                  alignment: Alignment.center,
                  scale: scaleAnimation.value,
                  child: Transform.rotate(
                    alignment: Alignment.bottomCenter,
                    angle: rotateAnimation.value,
                    child: LayoutBuilder(builder: (context, constraints) {
                      getSizeOfContainer();
                      return FractionallySizedBox(
                        heightFactor: 0.75,
                        child: Container(
                            key: _containerKey,
                            decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 10.0,
                                  offset: Offset(0, 10.0),
                                )
                              ],
                              border: Border.all(
                                color: Colors.white,
                                width: 5, // 边框宽度
                              ),
                            ),
                            transform: Matrix4.identity()
                              ..translate(leftAnimation.value, 0, 0),
                            child: child),
                      );
                    }),
                  ),
                );
              });
        });
  }

  void getSizeOfContainer() {
    // 使用BuildContext获取RenderBox
    if (_containerKey.currentContext != null) {
      RenderBox renderBox =
          _containerKey.currentContext?.findRenderObject() as RenderBox;

      Size size = renderBox.size;
      double width = size.width;

      if (!isShowAll && leftAnimation.value + width + 200 < screenWidth) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            isShowAll = true;
          });
          widget.onShowAll!.call();
        });
      }

      if (leftAnimation.value + width + 100 < 0) {
        print("Element moved out of screen to the left!");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onEnd?.call(widget.url);
        });
      }
    }
  }

  @override
  dispose() {
    leftController.dispose();
    scaleController.dispose();
    rotateController.dispose();
    super.dispose();
  }
}
