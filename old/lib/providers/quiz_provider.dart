import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database_helper.dart';
import '../models/idiom.dart';
import '../utils/constants.dart';

/// Provider for quiz and detective challenge game state.
class QuizProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Random _random = Random();

  // ─── Quiz State ─────────────────────────────────────────────────
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _highScore = 0;
  int _totalQuizzes = 0;
  int _streak = 0;
  bool _isLoading = false;
  bool _isQuizActive = false;
  bool _isAnswered = false;
  int? _selectedAnswer;
  String _quizDifficulty = 'all';

  // ─── Detective Challenge State ──────────────────────────────────
  int _detectiveScore = 0;
  bool _isChallengeActive = false;

  // ─── Getters ────────────────────────────────────────────────────
  List<QuizQuestion> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  QuizQuestion? get currentQuestion =>
      _questions.isNotEmpty && _currentQuestionIndex < _questions.length
          ? _questions[_currentQuestionIndex]
          : null;
  int get score => _score;
  int get highScore => _highScore;
  int get totalQuizzes => _totalQuizzes;
  int get streak => _streak;
  bool get isLoading => _isLoading;
  bool get isQuizActive => _isQuizActive;
  bool get isAnswered => _isAnswered;
  int? get selectedAnswer => _selectedAnswer;
  String get quizDifficulty => _quizDifficulty;
  int get detectiveScore => _detectiveScore;
  bool get isChallengeActive => _isChallengeActive;
  int get questionsRemaining => _questions.length - _currentQuestionIndex;
  double get progress => _questions.isEmpty
      ? 0
      : (_currentQuestionIndex + 1) / _questions.length;
  bool get isLastQuestion =>
      _currentQuestionIndex >= _questions.length - 1;

  // ─── Initialization ─────────────────────────────────────────────
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt(AppConstants.prefQuizHighScore) ?? 0;
    _totalQuizzes = prefs.getInt(AppConstants.prefTotalQuizzes) ?? 0;
    _detectiveScore = prefs.getInt(AppConstants.prefDetectiveScore) ?? 0;
    _streak = prefs.getInt(AppConstants.prefStreak) ?? 0;

    // Check streak continuity
    final lastStreakDate = prefs.getString(AppConstants.prefLastStreakDate);
    if (lastStreakDate != null) {
      final lastDate = DateTime.parse(lastStreakDate);
      final today = DateTime.now();
      final difference = today.difference(lastDate).inDays;
      if (difference > 1) {
        _streak = 0;
        await prefs.setInt(AppConstants.prefStreak, 0);
      }
    }

    notifyListeners();
  }

  // ─── Start Quiz ─────────────────────────────────────────────────
  Future<void> startQuiz({String difficulty = 'all'}) async {
    _isLoading = true;
    _quizDifficulty = difficulty;
    notifyListeners();

    try {
      final diff = difficulty == 'all' ? null : difficulty;
      // Get more idioms than needed for question + options pool
      final idioms = await _db.getRandomIdioms(
        AppConstants.quizQuestionCount * AppConstants.quizOptionsCount,
        difficulty: diff,
      );

      if (idioms.length < AppConstants.quizOptionsCount) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      _questions = _generateQuestions(idioms);
      _currentQuestionIndex = 0;
      _score = 0;
      _isQuizActive = true;
      _isAnswered = false;
      _selectedAnswer = null;
    } catch (e) {
      debugPrint('Error starting quiz: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Generate quiz questions from a pool of idioms.
  List<QuizQuestion> _generateQuestions(List<Idiom> pool) {
    final questions = <QuizQuestion>[];
    final usedIds = <int>{};

    for (int i = 0;
        i < AppConstants.quizQuestionCount && usedIds.length < pool.length;
        i++) {
      // Pick a correct answer
      Idiom? correct;
      for (final idiom in pool) {
        if (!usedIds.contains(idiom.id)) {
          correct = idiom;
          usedIds.add(idiom.id);
          break;
        }
      }
      if (correct == null) break;

      // Pick wrong options
      final wrongOptions = pool
          .where((i) => i.id != correct!.id)
          .toList()
        ..shuffle(_random);

      final options = [
        correct.meaning,
        ...wrongOptions
            .take(AppConstants.quizOptionsCount - 1)
            .map((i) => i.meaning),
      ];

      // Randomize the question type
      final questionType =
          _random.nextBool() ? QuizType.meaningFromIdiom : QuizType.idiomFromMeaning;

      if (questionType == QuizType.meaningFromIdiom) {
        options.shuffle(_random);
        questions.add(QuizQuestion(
          idiom: correct,
          questionText: 'What does "${correct.idiom}" mean?',
          options: options,
          correctIndex: options.indexOf(correct.meaning),
          type: QuizType.meaningFromIdiom,
        ));
      } else {
        // For idiom-from-meaning, swap options to be idiom names
        final idiomOptions = [
          correct.idiom,
          ...wrongOptions.take(AppConstants.quizOptionsCount - 1).map((i) => i.idiom),
        ]..shuffle(_random);

        questions.add(QuizQuestion(
          idiom: correct,
          questionText: 'Which idiom means: "${correct.meaning}"?',
          options: idiomOptions,
          correctIndex: idiomOptions.indexOf(correct.idiom),
          type: QuizType.idiomFromMeaning,
        ));
      }
    }

    return questions;
  }

  // ─── Answer Question ────────────────────────────────────────────
  void answerQuestion(int selectedIndex) {
    if (_isAnswered || currentQuestion == null) return;

    _selectedAnswer = selectedIndex;
    _isAnswered = true;

    if (selectedIndex == currentQuestion!.correctIndex) {
      _score++;
    }

    notifyListeners();
  }

  // ─── Next Question ──────────────────────────────────────────────
  Future<void> nextQuestion() async {
    if (isLastQuestion) {
      await _finishQuiz();
      return;
    }

    _currentQuestionIndex++;
    _isAnswered = false;
    _selectedAnswer = null;
    notifyListeners();
  }

  // ─── Finish Quiz ────────────────────────────────────────────────
  Future<void> _finishQuiz() async {
    _isQuizActive = false;
    _totalQuizzes++;

    if (_score > _highScore) {
      _highScore = _score;
    }

    // Update streak
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastStreakDate = prefs.getString(AppConstants.prefLastStreakDate);

    if (lastStreakDate != today) {
      _streak++;
      await prefs.setString(AppConstants.prefLastStreakDate, today);
    }

    await prefs.setInt(AppConstants.prefQuizHighScore, _highScore);
    await prefs.setInt(AppConstants.prefTotalQuizzes, _totalQuizzes);
    await prefs.setInt(AppConstants.prefStreak, _streak);

    notifyListeners();
  }

  // ─── Detective Challenge ───────────────────────────────────────
  Future<void> startDetectiveChallenge() async {
    _isLoading = true;
    notifyListeners();

    try {
      final idioms = await _db.getRandomIdioms(
        AppConstants.detectiveChallengeCount * AppConstants.quizOptionsCount,
      );

      if (idioms.length < AppConstants.quizOptionsCount) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      _questions = _generateQuestions(idioms);
      // Override question count for challenge
      if (_questions.length > AppConstants.detectiveChallengeCount) {
        _questions = _questions.sublist(0, AppConstants.detectiveChallengeCount);
      }

      _currentQuestionIndex = 0;
      _score = 0;
      _isChallengeActive = true;
      _isQuizActive = true;
      _isAnswered = false;
      _selectedAnswer = null;
    } catch (e) {
      debugPrint('Error starting challenge: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Reset ──────────────────────────────────────────────────────
  void resetQuiz() {
    _questions = [];
    _currentQuestionIndex = 0;
    _score = 0;
    _isQuizActive = false;
    _isChallengeActive = false;
    _isAnswered = false;
    _selectedAnswer = null;
    notifyListeners();
  }
}

// ─── Quiz Question Model ────────────────────────────────────────

enum QuizType { meaningFromIdiom, idiomFromMeaning }

class QuizQuestion {
  final Idiom idiom;
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final QuizType type;

  const QuizQuestion({
    required this.idiom,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    required this.type,
  });

  String get correctAnswer => options[correctIndex];
}
