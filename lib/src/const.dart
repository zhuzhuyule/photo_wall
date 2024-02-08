import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

const ROOT_PATH = '/storage/emulated/0';

ImageProvider<Object> getImageProvider(String src) {
  return src.startsWith('http')
      ? NetworkImage(src)
      : FileImage(File(src)) as ImageProvider<Object>;
}

toast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.grey,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
