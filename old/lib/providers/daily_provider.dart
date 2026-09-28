import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database_helper.dart';
import '../models/idiom.dart';
import '../utils/constants.dart';

/// Provider for the "Daily Case" feature — one new idiom each day.
class DailyProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Idiom? _dailyIdiom;
  bool _isLoading = false;
  bool _isNewDay = false;

  Idiom? get dailyIdiom => _dailyIdiom;
  bool get isLoading => _isLoading;
  bool get isNewDay => _isNewDay;

  /// Initialize and load today's daily idiom.
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final storedDate = prefs.getString(AppConstants.prefDailyIdiomDate);
      final storedId = prefs.getInt(AppConstants.prefDailyIdiomId);

      if (storedDate == today && storedId != null) {
        // Same day — load the stored idiom
        _dailyIdiom = await _db.getIdiomById(storedId);
        _isNewDay = false;
      } else {
        // New day — pick a new random idiom
        _dailyIdiom = await _db.getRandomIdiom();
        _isNewDay = true;

        if (_dailyIdiom != null) {
          await prefs.setString(AppConstants.prefDailyIdiomDate, today);
          await prefs.setInt(AppConstants.prefDailyIdiomId, _dailyIdiom!.id);
        }
      }
    } catch (e) {
      debugPrint('Error loading daily idiom: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Force refresh for a new daily idiom (for testing/manual refresh).
  Future<void> forceRefresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      _dailyIdiom = await _db.getRandomIdiom();
      _isNewDay = true;

      if (_dailyIdiom != null) {
        final prefs = await SharedPreferences.getInstance();
        final today = DateTime.now().toIso8601String().split('T')[0];
        await prefs.setString(AppConstants.prefDailyIdiomDate, today);
        await prefs.setInt(AppConstants.prefDailyIdiomId, _dailyIdiom!.id);
      }
    } catch (e) {
      debugPrint('Error refreshing daily idiom: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
