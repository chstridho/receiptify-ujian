import 'package:flutter/material.dart';

class FavoriteItem {
  final String id;
  final String title;
  final String imageUrl;

  FavoriteItem({
    required this.id,
    required this.title,
    required this.imageUrl,
  });
}

class FavoritesManager extends ChangeNotifier {
  final List<FavoriteItem> _favorites = [];

  List<FavoriteItem> get favorites => _favorites;

  void addFavorite(String id, String title, String imageUrl) {
    if (!_favorites.any((item) => item.id == id)) {
      _favorites.add(FavoriteItem(id: id, title: title, imageUrl: imageUrl));
      notifyListeners();
    }
  }

  void removeFavorite(String id) {
    _favorites.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  bool isFavorite(String id) {
    return _favorites.any((item) => item.id == id);
  }
}
