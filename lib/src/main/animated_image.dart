import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_wall/src/utils/file.dart';
import 'image_loader.dart';

class AnimationImage extends StatefulWidget {
  const AnimationImage(
      {Key? key,
      required this.url,
      required this.previewImage,
      this.onEnd,
      this.onShowAll,
      this.onPreview})
      : super(key: key);

  final String url;
  final String previewImage;
  final Function(String url)? onEnd;
  final Function(String url)? onPreview;
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
  late bool isLoaded = false;

  @override
  initState() {
    super.initState();

    leftController = getController(seconds: 122);
    leftAnimation = getAnimation(
        screenWidth + 100, -screenWidth * 2, leftController, false);

    scaleController = getController(seconds: 16);
    scaleAnimation = getAnimation(1.0, 1.2, scaleController);

    rotateController = getController(seconds: 15);
    rotateAnimation = getAnimation(-0.1, 0.1, rotateController);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoaded) {
      if (widget.previewImage != '' && leftController.isAnimating) {
        leftController.stop();
        scaleController.stop();
        rotateController.stop();
      } else {
        startAnimation();
      }
    }

    return AnimatedBuilder(
        animation: rotateAnimation,
        child: ImageLoader(
          key: ValueKey(widget.url),
          src: widget.url,
          onLoaded: (path) {
            setState(() {
              isLoaded = true;
            });
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
          return AnimatedBuilder(
              animation: scaleAnimation,
              child: child,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(leftAnimation.value, 0),
                  child: Transform.scale(
                    scale: scaleAnimation.value,
                    child: Transform.rotate(
                      angle: rotateAnimation.value,
                      child: LayoutBuilder(builder: (context, constraints) {
                        getSizeOfContainer();
                        return FractionallySizedBox(
                          heightFactor: 0.75,
                          child: GestureDetector(
                            onTap: () {
                              if (widget.previewImage == '') {
                                widget.onPreview?.call(widget.url);
                              }
                            },
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
                                    width: 6, // 边框宽度
                                  ),
                                ),
                                child: child),
                          ),
                        );
                      }),
                    ),
                  ),
                );
              });
        });
  }

  void startAnimation() {
    leftController.forward();
    scaleController.repeat(reverse: true);
    rotateController.repeat(reverse: true);
  }

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
      controller.value = Random().nextDouble();
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

  void getSizeOfContainer() {
    // 使用BuildContext获取RenderBox
    if (_containerKey.currentContext != null) {
      RenderBox renderBox =
          _containerKey.currentContext?.findRenderObject() as RenderBox;

      double width = renderBox.size.width;

      if (!isShowAll && leftAnimation.value + width + 50 < screenWidth) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            isShowAll = true;
          });
          widget.onShowAll!.call();
        });
      }

      if (leftAnimation.value + width + 100 < 0) {
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
