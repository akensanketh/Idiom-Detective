import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/idiom.dart';

/// Provider for managing the user's favorite idioms.
class FavoritesProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Idiom> _favorites = [];
  int _favoriteCount = 0;
  bool _isLoading = false;

  List<Idiom> get favorites => _favorites;
  int get favoriteCount => _favoriteCount;
  bool get isLoading => _isLoading;

  /// Load all favorites from the database.
  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      _favorites = await _db.getFavorites();
      _favoriteCount = _favorites.length;
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle an idiom's favorite status. Returns the new status.
  Future<bool> toggleFavorite(int idiomId) async {
    try {
      final isFav = await _db.toggleFavorite(idiomId);
      await loadFavorites();
      return isFav;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return false;
    }
  }

  /// Check if a specific idiom is favorited.
  Future<bool> isFavorite(int idiomId) async {
    return await _db.isFavorite(idiomId);
  }

  /// Get the current favorite count.
  Future<void> refreshCount() async {
    _favoriteCount = await _db.getFavoriteCount();
    notifyListeners();
  }
}
