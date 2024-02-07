import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_wall/src/utils/file.dart';
import 'package:photo_wall/src/utils/image_api_helper.dart';

import 'package:shared_preferences/shared_preferences.dart';

const favoritePathKey = 'photo_wall_favorites';

class FavoriteState with ChangeNotifier {
  late SharedPreferences _preference;
  late bool _loading = true;
  late List<String> _favoriteDirs = [];
  late final List<String> _favorites = [];

  List<String> get favorites => _favorites;
  List<String> get favoriteDirs => _favoriteDirs;
  bool get loading => _loading;

  FavoriteState() {
    SharedPreferences.getInstance()
        .then((value) => _preference = value)
        .then((value) => {_readPreference()});
  }

  getFavoriteFiles() async {
    for (var dir in _favoriteDirs) {
      if (dir.startsWith('http')) {
        final baseDir = dir.replaceAll(ImageApiHelper.baseUrl, '');
        final List<TFileInfo> files = await ImageApiHelper()
            .getDirFiles(baseDir)
            .then((data) => data.result);
        for (var file in files) {
          if (isImageFile(file.name)) {
            favorites.add(ImageApiHelper().getFileLink(baseDir, file));
          }
        }
      } else {
        final List<FileSystemEntity> files = Directory(dir).listSync().toList();
        for (var file in files) {
          if (isImageFile(file.path)) {
            favorites.add(file.path);
          }
        }
      }
    }
    notifyListeners();
  }

  void _readPreference() {
    _favoriteDirs = _preference.getStringList(favoritePathKey) ?? [];
    _loading = false;
    getFavoriteFiles();
  }

  void addDir(String dir) {
    if (!_favoriteDirs.contains(dir)) {
      _favoriteDirs.add(dir);
      _preference.setStringList(favoritePathKey, _favoriteDirs);
      getFavoriteFiles();
    }
  }

  void removeDir(String dir) {
    if (_favoriteDirs.contains(dir)) {
      _favoriteDirs.remove(dir);
      _preference.setStringList(favoritePathKey, _favoriteDirs);
      getFavoriteFiles();
    }
  }

  void toggleFavoriteDir(String dir) {
    if (_favoriteDirs.contains(dir)) {
      removeDir(dir);
    } else {
      addDir(dir);
    }
  }
}
