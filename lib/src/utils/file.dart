import 'dart:ui';

bool isImageFile(String fileName) {
  String extension = fileName.toLowerCase();
  if (extension.endsWith('.jpg') ||
      extension.endsWith('.jpeg') ||
      extension.endsWith('.png') ||
      extension.endsWith('.gif') ||
      extension.endsWith('.bmp')) {
    return true;
  } else {
    return false;
  }
}

double screenWidth = window.physicalSize.width / window.devicePixelRatio;
double screenHeight = window.physicalSize.height / window.devicePixelRatio;
