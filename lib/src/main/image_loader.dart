import 'dart:io';
import 'package:flutter/material.dart';

class ImageLoader extends StatefulWidget {
  const ImageLoader({
    super.key,
    required this.onLoaded,
    required this.onError,
    this.filePath = '',
  });

  final String filePath;
  final void Function(String filePath) onLoaded;
  final void Function(String filePath) onError;

  @override
  State<ImageLoader> createState() => _ImageLoaderState();
}

class _ImageLoaderState extends State<ImageLoader> {
  late dynamic image = '';
  @override
  Widget build(BuildContext context) {
    final src = widget.filePath;
    return image != ''
        ? image
        : Image(
            key: ValueKey(src),
            image: FileImage(File(src)),
            errorBuilder: (context, error, stackTrace) {
              widget.onError.call(src);
              return const Text('Error loading image');
            },
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (image == '' && frame == 0) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    image = child;
                  });
                  widget.onLoaded.call(src);
                });
              }
              return const CircularProgressIndicator();
            });
  }
}
