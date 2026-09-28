import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/idiom.dart';

/// Main provider for idiom data — search, categories, random, and daily case.
class IdiomProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // ─── State ──────────────────────────────────────────────────────
  List<Idiom> _allIdioms = [];
  List<Idiom> _searchResults = [];
  List<Idiom> _categoryIdioms = [];
  List<Idiom> _recentlyViewed = [];
  List<Map<String, dynamic>> _categories = [];
  Idiom? _randomIdiom;
  Idiom? _dailyIdiom;
  Idiom? _selectedIdiom;
  int _totalCount = 0;
  bool _isLoading = false;
  bool _isSearching = false;
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedDifficulty;

  // ─── Getters ────────────────────────────────────────────────────
  List<Idiom> get allIdioms => _allIdioms;
  List<Idiom> get searchResults => _searchResults;
  List<Idiom> get categoryIdioms => _categoryIdioms;
  List<Idiom> get recentlyViewed => _recentlyViewed;
  List<Map<String, dynamic>> get categories => _categories;
  Idiom? get randomIdiom => _randomIdiom;
  Idiom? get dailyIdiom => _dailyIdiom;
  Idiom? get selectedIdiom => _selectedIdiom;
  int get totalCount => _totalCount;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String? get selectedDifficulty => _selectedDifficulty;

  // ─── Initialization ─────────────────────────────────────────────
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _totalCount = await _db.getIdiomCount();
      _categories = await _db.getCategories();
      _recentlyViewed = await _db.getRecentlyViewed();
      await fetchRandomIdiom();
    } catch (e) {
      debugPrint('IdiomProvider init error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Load All Idioms ───────────────────────────────────────────
  Future<void> loadAllIdioms({String? category, String? difficulty}) async {
    _isLoading = true;
    _selectedCategory = category;
    _selectedDifficulty = difficulty;
    notifyListeners();

    try {
      _allIdioms = await _db.getIdioms(
        category: category,
        difficulty: difficulty,
      );
    } catch (e) {
      debugPrint('Error loading idioms: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Search ─────────────────────────────────────────────────────
  Future<void> search(String query) async {
    _searchQuery = query;

    if (query.trim().isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      _searchResults = await _db.searchIdioms(query.trim());
    } catch (e) {
      debugPrint('Error searching: $e');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }

  // ─── Load Category Idioms ──────────────────────────────────────
  Future<void> loadCategoryIdioms(String category) async {
    _isLoading = true;
    _selectedCategory = category;
    notifyListeners();

    try {
      _categoryIdioms = await _db.getIdioms(category: category);
    } catch (e) {
      debugPrint('Error loading category: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Random Idiom ──────────────────────────────────────────────
  Future<void> fetchRandomIdiom() async {
    try {
      _randomIdiom = await _db.getRandomIdiom();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching random idiom: $e');
    }
  }

  // ─── Detail View ───────────────────────────────────────────────
  Future<void> selectIdiom(int id) async {
    try {
      _selectedIdiom = await _db.getIdiomById(id);
      if (_selectedIdiom != null) {
        await _db.addToRecentlyViewed(id);
        _recentlyViewed = await _db.getRecentlyViewed();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error selecting idiom: $e');
    }
  }

  void clearSelectedIdiom() {
    _selectedIdiom = null;
    notifyListeners();
  }

  // ─── Recently Viewed ──────────────────────────────────────────
  Future<void> loadRecentlyViewed() async {
    try {
      _recentlyViewed = await _db.getRecentlyViewed();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading recently viewed: $e');
    }
  }

  Future<void> clearRecentlyViewed() async {
    try {
      await _db.clearRecentlyViewed();
      _recentlyViewed = [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing recently viewed: $e');
    }
  }

  // ─── Refresh favorite state on an idiom in any list ────────────
  void updateIdiomFavoriteState(int idiomId, bool isFavorite) {
    _updateList(_allIdioms, idiomId, isFavorite);
    _updateList(_searchResults, idiomId, isFavorite);
    _updateList(_categoryIdioms, idiomId, isFavorite);
    _updateList(_recentlyViewed, idiomId, isFavorite);

    if (_randomIdiom?.id == idiomId) {
      _randomIdiom = _randomIdiom!.copyWith(isFavorite: isFavorite);
    }
    if (_dailyIdiom?.id == idiomId) {
      _dailyIdiom = _dailyIdiom!.copyWith(isFavorite: isFavorite);
    }
    if (_selectedIdiom?.id == idiomId) {
      _selectedIdiom = _selectedIdiom!.copyWith(isFavorite: isFavorite);
    }

    notifyListeners();
  }

  void _updateList(List<Idiom> list, int idiomId, bool isFavorite) {
    final index = list.indexWhere((i) => i.id == idiomId);
    if (index != -1) {
      list[index] = list[index].copyWith(isFavorite: isFavorite);
    }
  }
}
