import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

const favoriteKey = 'photo_wall_favorites';

class FavoriteState with ChangeNotifier {
  late SharedPreferences _preference;
  late List<String> _favorites = [];

  List<String> get favorites => _favorites;

  FavoriteState() {
    SharedPreferences.getInstance()
        .then((value) => _preference = value)
        .then((value) => {_readPreference()});
  }

  void _readPreference() {
    _favorites = _preference.getStringList(favoriteKey) ?? [];
    notifyListeners();
  }

  void addFavorite(String favorite) {
    if (!_favorites.contains(favorite)) {
      _favorites.add(favorite);
      _preference.setStringList(favoriteKey, _favorites);
      notifyListeners();
    }
  }

  void removeFavorite(String favorite) {
    if (_favorites.contains(favorite)) {
      _favorites.remove(favorite);
      _preference.setStringList(favoriteKey, _favorites);
      notifyListeners();
    }
  }

  void toggleFavorite(String favorite) {
    if (_favorites.contains(favorite)) {
      removeFavorite(favorite);
    } else {
      addFavorite(favorite);
    }
    notifyListeners();
  }
}
