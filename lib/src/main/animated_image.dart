import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math';

class AnimationImage extends StatefulWidget {
  const AnimationImage({Key? key, required this.url, this.onEnd})
      : super(key: key);

  final String url;
  final Function? onEnd;

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
      animate = animate
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            controller.reverse();
          } else if (status == AnimationStatus.dismissed) {
            controller.forward();
          }
        });
      controller.forward(from: tween.lerp(Random().nextDouble()));
    } else {
      final Animation<double> curve =
          CurvedAnimation(parent: controller, curve: Curves.linear);
      animate = tween.animate(curve);
      controller.forward();
    }

    return animate;
  }

  @override
  initState() {
    super.initState();
    double screenWidth = window.physicalSize.width;

    leftController = getController(seconds: 122);
    leftAnimation =
        getAnimation(screenWidth, -screenWidth, leftController, false);

    // leftAnimation.addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     widget.onEnd?.call();
    //   }
    // });

    scaleController = getController(seconds: 16);
    scaleAnimation = getAnimation(1.0, 1.2, scaleController);

    rotateController = getController(seconds: 15);
    rotateAnimation = getAnimation(-0.1, 0.1, rotateController);
  }

  @override
  Widget build(BuildContext context) {
    // var appState = context.watch<ImageService>();
    // print(appState.list.length);
    return AnimatedBuilder(
        animation: rotateAnimation,
        child: Image.network(widget.url),
        builder: (context, child) {
          return AnimatedBuilder(
              animation: scaleAnimation,
              child: child,
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

      if (leftAnimation.value + width + 100 < 0) {
        print("Element moved out of screen to the left!");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onEnd?.call();
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
