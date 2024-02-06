import 'dart:io';
import 'package:flutter/material.dart';

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
