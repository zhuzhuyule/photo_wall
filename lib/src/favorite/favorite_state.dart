import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteState with ChangeNotifier {
  FavoriteState();

  final List<String> _favorites = [];
  List<String> get favorites => _favorites;

  void addFavorite(String favorite) {
    if (!_favorites.contains(favorite)) {
      _favorites.add(favorite);
      notifyListeners();
    }
  }

  void removeFavorite(String favorite) {
    if (_favorites.contains(favorite)) {
      _favorites.remove(favorite);
      notifyListeners();
    }
  }

  void toggleFavorite(String favorite) {
    if (_favorites.contains(favorite)) {
      _favorites.remove(favorite);
    } else {
      _favorites.add(favorite);
    }
    notifyListeners();
  }
}
