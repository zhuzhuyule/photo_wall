import 'dart:io';

import 'package:flutter/material.dart';

const ROOT_PATH = '/storage/emulated/0';

ImageProvider<Object> getImageProvider(String src) {
  return src.startsWith('http')
      ? NetworkImage(src)
      : FileImage(File(src)) as ImageProvider<Object>;
}
