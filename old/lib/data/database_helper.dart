import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../models/idiom.dart';
import '../utils/constants.dart';

/// Singleton helper for SQLite database operations (with Web in-memory fallback).
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;
  List<Idiom>? _webIdioms;
  final Set<int> _webFavorites = {};
  final List<int> _webRecentlyViewed = [];
  bool _webInitialized = false;

  /// Get or initialize the database (or web memory store).
  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> _ensureWebInitialized() async {
    if (!kIsWeb || _webInitialized) return;
    try {
      final jsonString = await rootBundle.loadString('assets/data/idioms.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      _webIdioms = jsonList.map((item) => Idiom.fromJson(item as Map<String, dynamic>)).toList();

      final prefs = await SharedPreferences.getInstance();
      final favList = prefs.getStringList('web_favorites') ?? [];
      _webFavorites.addAll(favList.map((e) => int.parse(e)));

      final recentList = prefs.getStringList('web_recently_viewed') ?? [];
      _webRecentlyViewed.addAll(recentList.map((e) => int.parse(e)));

      _webInitialized = true;
    } catch (e) {
      debugPrint('Error initializing web store: $e');
    }
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  /// Create tables and seed data from JSON asset.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableIdioms} (
        id INTEGER PRIMARY KEY,
        idiom TEXT NOT NULL,
        meaning TEXT NOT NULL,
        explanation TEXT NOT NULL,
        example TEXT NOT NULL,
        usage TEXT DEFAULT 'both',
        category TEXT NOT NULL,
        difficulty TEXT DEFAULT 'intermediate',
        origin TEXT DEFAULT '',
        related TEXT DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableFavorites} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idiom_id INTEGER NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        FOREIGN KEY (idiom_id) REFERENCES ${AppConstants.tableIdioms}(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableRecentlyViewed} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idiom_id INTEGER NOT NULL UNIQUE,
        viewed_at TEXT NOT NULL,
        FOREIGN KEY (idiom_id) REFERENCES ${AppConstants.tableIdioms}(id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_idioms_category ON ${AppConstants.tableIdioms}(category)
    ''');
    await db.execute('''
      CREATE INDEX idx_idioms_difficulty ON ${AppConstants.tableIdioms}(difficulty)
    ''');

    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/idioms.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      final batch = db.batch();
      for (final item in jsonList) {
        final map = item as Map<String, dynamic>;
        batch.insert(AppConstants.tableIdioms, {
          'id': map['id'],
          'idiom': map['idiom'],
          'meaning': map['meaning'],
          'explanation': map['explanation'],
          'example': map['example'],
          'usage': map['usage'] ?? 'both',
          'category': map['category'],
          'difficulty': map['difficulty'] ?? 'intermediate',
          'origin': map['origin'] ?? '',
          'related': (map['related'] as List?)?.join('|') ?? '',
        });
      }
      await batch.commit(noResult: true);
    } catch (e) {
      debugPrint('Error seeding database: $e');
      rethrow;
    }
  }

  // ─── Idiom Queries ──────────────────────────────────────────────

  Future<List<Idiom>> getIdioms({
    String? category,
    String? difficulty,
    int? limit,
    int? offset,
  }) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      var list = _webIdioms ?? [];
      if (category != null) {
        list = list.where((i) => i.category == category).toList();
      }
      if (difficulty != null) {
        list = list.where((i) => i.difficulty == difficulty).toList();
      }
      list.sort((a, b) => a.idiom.compareTo(b.idiom));
      if (offset != null && offset < list.length) {
        list = list.sublist(offset);
      }
      if (limit != null && limit < list.length) {
        list = list.sublist(0, limit);
      }
      return list.map((i) => i.copyWith(isFavorite: _webFavorites.contains(i.id))).toList();
    }

    final db = await database;
    final where = <String>[];
    final whereArgs = <String>[];

    if (category != null) {
      where.add('i.category = ?');
      whereArgs.add(category);
    }
    if (difficulty != null) {
      where.add('i.difficulty = ?');
      whereArgs.add(difficulty);
    }

    final whereClause = where.isNotEmpty ? 'WHERE ${where.join(' AND ')}' : '';

    final results = await db!.rawQuery('''
      SELECT i.*, 
             CASE WHEN f.idiom_id IS NOT NULL THEN 1 ELSE 0 END as is_favorite
      FROM ${AppConstants.tableIdioms} i
      LEFT JOIN ${AppConstants.tableFavorites} f ON i.id = f.idiom_id
      $whereClause
      ORDER BY i.idiom ASC
      ${limit != null ? 'LIMIT $limit' : ''}
      ${offset != null ? 'OFFSET $offset' : ''}
    ''', whereArgs);

    return results.map((row) => _rowToIdiom(row)).toList();
  }

  Future<List<Idiom>> searchIdioms(String query) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final q = query.toLowerCase();
      final list = (_webIdioms ?? []).where((i) {
        return i.idiom.toLowerCase().contains(q) ||
            i.meaning.toLowerCase().contains(q) ||
            i.explanation.toLowerCase().contains(q);
      }).toList();

      list.sort((a, b) {
        final aExact = a.idiom.toLowerCase().contains(q);
        final bExact = b.idiom.toLowerCase().contains(q);
        if (aExact && !bExact) return -1;
        if (!aExact && bExact) return 1;
        return a.idiom.compareTo(b.idiom);
      });

      return list.take(50).map((i) => i.copyWith(isFavorite: _webFavorites.contains(i.id))).toList();
    }

    final db = await database;
    final searchTerm = '%$query%';

    final results = await db!.rawQuery('''
      SELECT i.*,
             CASE WHEN f.idiom_id IS NOT NULL THEN 1 ELSE 0 END as is_favorite
      FROM ${AppConstants.tableIdioms} i
      LEFT JOIN ${AppConstants.tableFavorites} f ON i.id = f.idiom_id
      WHERE i.idiom LIKE ? OR i.meaning LIKE ? OR i.explanation LIKE ?
      ORDER BY 
        CASE 
          WHEN i.idiom LIKE ? THEN 1
          WHEN i.meaning LIKE ? THEN 2
          ELSE 3
        END,
        i.idiom ASC
      LIMIT 50
    ''', [searchTerm, searchTerm, searchTerm, searchTerm, searchTerm]);

    return results.map((row) => _rowToIdiom(row)).toList();
  }

  Future<Idiom?> getIdiomById(int id) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      try {
        final i = (_webIdioms ?? []).firstWhere((item) => item.id == id);
        return i.copyWith(isFavorite: _webFavorites.contains(i.id));
      } catch (_) {
        return null;
      }
    }

    final db = await database;
    final results = await db!.rawQuery('''
      SELECT i.*,
             CASE WHEN f.idiom_id IS NOT NULL THEN 1 ELSE 0 END as is_favorite
      FROM ${AppConstants.tableIdioms} i
      LEFT JOIN ${AppConstants.tableFavorites} f ON i.id = f.idiom_id
      WHERE i.id = ?
    ''', [id]);

    if (results.isEmpty) return null;
    return _rowToIdiom(results.first);
  }

  Future<Idiom?> getRandomIdiom() async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final list = List<Idiom>.from(_webIdioms ?? [])..shuffle();
      if (list.isEmpty) return null;
      final i = list.first;
      return i.copyWith(isFavorite: _webFavorites.contains(i.id));
    }

    final db = await database;
    final results = await db!.rawQuery('''
      SELECT i.*,
             CASE WHEN f.idiom_id IS NOT NULL THEN 1 ELSE 0 END as is_favorite
      FROM ${AppConstants.tableIdioms} i
      LEFT JOIN ${AppConstants.tableFavorites} f ON i.id = f.idiom_id
      ORDER BY RANDOM()
      LIMIT 1
    ''');

    if (results.isEmpty) return null;
    return _rowToIdiom(results.first);
  }

  Future<List<Idiom>> getRandomIdioms(int count, {String? difficulty}) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      var list = List<Idiom>.from(_webIdioms ?? []);
      if (difficulty != null) {
        list = list.where((i) => i.difficulty == difficulty).toList();
      }
      list.shuffle();
      return list.take(count).map((i) => i.copyWith(isFavorite: _webFavorites.contains(i.id))).toList();
    }

    final db = await database;
    final where = difficulty != null ? 'WHERE i.difficulty = ?' : '';
    final args = difficulty != null ? [difficulty] : <String>[];

    final results = await db!.rawQuery('''
      SELECT i.*,
             CASE WHEN f.idiom_id IS NOT NULL THEN 1 ELSE 0 END as is_favorite
      FROM ${AppConstants.tableIdioms} i
      LEFT JOIN ${AppConstants.tableFavorites} f ON i.id = f.idiom_id
      $where
      ORDER BY RANDOM()
      LIMIT ?
    ''', [...args, count]);

    return results.map((row) => _rowToIdiom(row)).toList();
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final map = <String, int>{};
      for (final i in _webIdioms ?? []) {
        map[i.category] = (map[i.category] ?? 0) + 1;
      }
      final result = map.entries
          .map((e) => {'category': e.key, 'count': e.value})
          .toList()
        ..sort((a, b) => (a['category'] as String).compareTo(b['category'] as String));
      return result;
    }

    final db = await database;
    return await db!.rawQuery('''
      SELECT category, COUNT(*) as count
      FROM ${AppConstants.tableIdioms}
      GROUP BY category
      ORDER BY category ASC
    ''');
  }

  Future<int> getIdiomCount() async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      return _webIdioms?.length ?? 0;
    }

    final db = await database;
    final result = await db!.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableIdioms}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ─── Favorites ──────────────────────────────────────────────────

  Future<bool> toggleFavorite(int idiomId) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      bool added = false;
      if (_webFavorites.contains(idiomId)) {
        _webFavorites.remove(idiomId);
        added = false;
      } else {
        _webFavorites.add(idiomId);
        added = true;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('web_favorites', _webFavorites.map((e) => e.toString()).toList());
      return added;
    }

    final db = await database;
    final existing = await db!.query(
      AppConstants.tableFavorites,
      where: 'idiom_id = ?',
      whereArgs: [idiomId],
    );

    if (existing.isNotEmpty) {
      await db.delete(
        AppConstants.tableFavorites,
        where: 'idiom_id = ?',
        whereArgs: [idiomId],
      );
      return false;
    } else {
      await db.insert(AppConstants.tableFavorites, {
        'idiom_id': idiomId,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    }
  }

  Future<bool> isFavorite(int idiomId) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      return _webFavorites.contains(idiomId);
    }

    final db = await database;
    final result = await db!.query(
      AppConstants.tableFavorites,
      where: 'idiom_id = ?',
      whereArgs: [idiomId],
    );
    return result.isNotEmpty;
  }

  Future<List<Idiom>> getFavorites() async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final list = (_webIdioms ?? [])
          .where((i) => _webFavorites.contains(i.id))
          .map((i) => i.copyWith(isFavorite: true))
          .toList();
      return list;
    }

    final db = await database;
    final results = await db!.rawQuery('''
      SELECT i.*, 1 as is_favorite
      FROM ${AppConstants.tableIdioms} i
      INNER JOIN ${AppConstants.tableFavorites} f ON i.id = f.idiom_id
      ORDER BY f.created_at DESC
    ''');

    return results.map((row) => _rowToIdiom(row)).toList();
  }

  Future<int> getFavoriteCount() async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      return _webFavorites.length;
    }

    final db = await database;
    final result = await db!.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableFavorites}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ─── Recently Viewed ───────────────────────────────────────────

  Future<void> addToRecentlyViewed(int idiomId) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      _webRecentlyViewed.remove(idiomId);
      _webRecentlyViewed.insert(0, idiomId);
      if (_webRecentlyViewed.length > 50) {
        _webRecentlyViewed.removeLast();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('web_recently_viewed', _webRecentlyViewed.map((e) => e.toString()).toList());
      return;
    }

    final db = await database;

    await db!.delete(
      AppConstants.tableRecentlyViewed,
      where: 'idiom_id = ?',
      whereArgs: [idiomId],
    );

    await db.insert(AppConstants.tableRecentlyViewed, {
      'idiom_id': idiomId,
      'viewed_at': DateTime.now().toIso8601String(),
    });

    await db.rawDelete('''
      DELETE FROM ${AppConstants.tableRecentlyViewed}
      WHERE id NOT IN (
        SELECT id FROM ${AppConstants.tableRecentlyViewed}
        ORDER BY viewed_at DESC
        LIMIT 50
      )
    ''');
  }

  Future<List<Idiom>> getRecentlyViewed({int limit = 20}) async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      final ids = _webRecentlyViewed.take(limit).toList();
      final result = <Idiom>[];
      for (final id in ids) {
        final match = (_webIdioms ?? []).where((i) => i.id == id).firstOrNull;
        if (match != null) {
          result.add(match.copyWith(isFavorite: _webFavorites.contains(match.id)));
        }
      }
      return result;
    }

    final db = await database;
    final results = await db!.rawQuery('''
      SELECT i.*,
             CASE WHEN f.idiom_id IS NOT NULL THEN 1 ELSE 0 END as is_favorite
      FROM ${AppConstants.tableIdioms} i
      INNER JOIN ${AppConstants.tableRecentlyViewed} r ON i.id = r.idiom_id
      LEFT JOIN ${AppConstants.tableFavorites} f ON i.id = f.idiom_id
      ORDER BY r.viewed_at DESC
      LIMIT ?
    ''', [limit]);

    return results.map((row) => _rowToIdiom(row)).toList();
  }

  Future<void> clearRecentlyViewed() async {
    if (kIsWeb) {
      await _ensureWebInitialized();
      _webRecentlyViewed.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('web_recently_viewed');
      return;
    }

    final db = await database;
    await db!.delete(AppConstants.tableRecentlyViewed);
  }

  // ─── Helpers ────────────────────────────────────────────────────

  Idiom _rowToIdiom(Map<String, dynamic> row) {
    final relatedStr = row['related'] as String? ?? '';
    final related = relatedStr.isEmpty ? <String>[] : relatedStr.split('|');

    return Idiom(
      id: row['id'] as int,
      idiom: row['idiom'] as String,
      meaning: row['meaning'] as String,
      explanation: row['explanation'] as String,
      example: row['example'] as String,
      usage: row['usage'] as String? ?? 'both',
      category: row['category'] as String,
      difficulty: row['difficulty'] as String? ?? 'intermediate',
      origin: row['origin'] as String? ?? '',
      related: related,
      isFavorite: (row['is_favorite'] as int?) == 1,
    );
  }

  Future<void> close() async {
    if (kIsWeb) return;
    final db = await database;
    await db?.close();
    _database = null;
  }
}
