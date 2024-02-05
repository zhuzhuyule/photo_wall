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
  late bool loaded = false;
  @override
  Widget build(BuildContext context) {
    final src = widget.filePath;
    return Image(
        key: ValueKey(src),
        image: FileImage(File(src)),
        errorBuilder: (context, error, stackTrace) {
          widget.onError.call(src);
          return const Text('Error loading image');
        },
        frameBuilder: loaded
            ? null
            : (context, child, frame, wasSynchronouslyLoaded) {
                if (!loaded && frame == 0) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.onLoaded.call(src);
                    setState(() {
                      loaded = true;
                    });
                  });
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              });
  }
}
