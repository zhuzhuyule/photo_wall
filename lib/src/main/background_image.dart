import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_wall/src/const.dart';

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({
    super.key,
    required this.bgSrc,
  });

  final String bgSrc;

  @override
  Widget build(BuildContext context) {
    return Image(
      key: ValueKey('bg $bgSrc'),
      image: getImageProvider(bgSrc),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}
