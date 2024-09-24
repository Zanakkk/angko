// lib/provider/angko.dart
// ignore_for_file: empty_catches

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/score_entry.dart';

enum GuessStatus { success, duplicate, invalid }

class NumberleProvider with ChangeNotifier {
  int _numberLength = 4; // Length of the number to guess
  final int _maxAttempts = 5; // Maximum number of attempts
  String _targetNumber = '';
  final List<String> _guesses = [];
  final List<List<String>> _feedbacks = [];
  final List<String> _currentInput = [];
  final Stopwatch _stopwatch = Stopwatch();
  int _score = 0;
  List<ScoreEntry> _highScores = [];
  final int _difficultyLevel = 1; // 1: Easy, 2: Medium, 3: Hard

  // Additional parameters for scoring
  final int _easyBonus = 2000;
  final int _mediumBonus = 1500;
  final int _hardBonus = 1000;

  int _inputCount = 0; // Menyimpan jumlah input yang telah dilakukan
  int get inputCount => _inputCount; // Getter untuk jumlah input

  NumberleProvider() {
    _generateTargetNumber();
    _stopwatch.start();
    _loadHighScores();
  }

  // Firebase Realtime Database URL
  final String _firebaseUrl =
      'https://angko-6a438-default-rtdb.asia-southeast1.firebasedatabase.app/angko2.json';

  // Public getters
  String get targetNumber => _targetNumber;
  int get numberLength => _numberLength;
  int get maxAttempts => _maxAttempts;
  List<String> get guesses => _guesses;
  List<List<String>> get feedbacks => _feedbacks;
  List<String> get currentInput => _currentInput;
  int get score => _score;
  List<ScoreEntry> get highScores => _highScores;

  // Generates a random target number
  void _generateTargetNumber() {
    final random = Random();
    _targetNumber = '';
    while (_targetNumber.length < _numberLength) {
      String digit = random.nextInt(10).toString();
      _targetNumber += digit; // Allow duplicates
    }
  }

  // Handles keypad input
  void handleKeyPress(String key) {
    if (key == '⌫') {
      _deleteLastDigit();
    } else if (key == '⏎') {
      _submitGuess();
    } else {
      _addDigit(key);
    }
  }

  // Adds a digit to the current input
  void _addDigit(String digit) {
    if (_currentInput.length < _numberLength) {
      _currentInput.add(digit);
      _inputCount++; // Tambah jumlah input
      notifyListeners();
    }
  }

  // Deletes the last digit from the current input
  void _deleteLastDigit() {
    if (_currentInput.isNotEmpty) {
      _currentInput.removeLast();
      notifyListeners();
    }
  }

  int _getLevelBonus() {
    switch (_difficultyLevel) {
      case 1:
        return _easyBonus;
      case 2:
        return _mediumBonus;
      case 3:
        return _hardBonus;
      default:
        return 0;
    }
  }

  // Submits the current guess
  Future<void> _submitGuess() async {
    if (_currentInput.length != _numberLength) {
      return; // Handle incomplete guesses
    }

    String guess = _currentInput.join('');
    GuessStatus status = makeGuess(guess);

    if (status == GuessStatus.success) {
      _calculateScore();
      _currentInput.clear();
      notifyListeners();
    } else if (status == GuessStatus.duplicate) {
      _score -= 100; // Penalize for duplicate guess
      notifyListeners();
    } else if (status == GuessStatus.invalid) {
      _score -= 200; // Penalize for invalid guess
      notifyListeners();
    }
  }

  // Makes a guess and returns the status
  GuessStatus makeGuess(String guess) {
    if (guess.length != _numberLength || !RegExp(r'^\d+$').hasMatch(guess)) {
      return GuessStatus.invalid;
    }

    if (_guesses.contains(guess)) {
      return GuessStatus.duplicate;
    }

    _guesses.add(guess);
    _feedbacks.add(_evaluateGuess(guess));
    notifyListeners();
    return GuessStatus.success;
  }

  // Evaluates the guess and provides feedback
  List<String> _evaluateGuess(String guess) {
    List<String> feedback = List.filled(_numberLength, '⬜');

    // Create a map for target number digit counts
    Map<String, int> targetDigitCount = {};
    for (var digit in _targetNumber.split('')) {
      targetDigitCount[digit] = (targetDigitCount[digit] ?? 0) + 1;
    }

    // First pass: Check for correct digits in the correct position
    for (int i = 0; i < _numberLength; i++) {
      if (guess[i] == _targetNumber[i]) {
        feedback[i] = '🟩';
        targetDigitCount[guess[i]] = targetDigitCount[guess[i]]! - 1;
      }
    }

    // Second pass: Check for correct digits in the wrong position
    for (int i = 0; i < _numberLength; i++) {
      if (feedback[i] == '🟩') continue;
      if (_targetNumber.contains(guess[i]) && targetDigitCount[guess[i]]! > 0) {
        feedback[i] = '🟨';
        targetDigitCount[guess[i]] = targetDigitCount[guess[i]]! - 1;
      }
    }

    return feedback;
  }

  // Calculates the score based on attempts and time taken
  void _calculateScore() {
    const int timeLimit = 300;
    int attemptsBonus = (_maxAttempts - _guesses.length + 1) * 1000;
    int timeTaken = _stopwatch.elapsed.inSeconds;
    int timeBonus = (timeLimit - timeTaken) * 10;

    // Prevent negative bonuses
    if (timeBonus < 0) timeBonus = 0;

    // Calculate distance penalty (1 point for each digit off)
    int distancePenalty = _calculateDistancePenalty();

    // Set bonus based on difficulty level
    int levelBonus = _getLevelBonus();

    _score = attemptsBonus + timeBonus + levelBonus - distancePenalty;
    if (_score < 0) _score = 0; // Prevent negative score
  }

  int _calculateDistancePenalty() {
    if (_guesses.isEmpty) return 0;

    // Calculate penalty based on distance from the target number
    String lastGuess = _guesses.last;
    int penalty = 0;
    for (int i = 0; i < _numberLength; i++) {
      if (lastGuess[i] != _targetNumber[i]) {
        penalty += 5; // Example penalty value for each incorrect digit
      }
    }
    return penalty;
  }

  // Saves the score to Firebase with a username
  Future<void> saveScore(String username) async {
    _calculateScore();

    if (username.isEmpty) {
      return; // Tambahkan penanganan untuk nama kosong
    }

    final scoreEntry = ScoreEntry(
      username: username,
      timestamp: DateTime.now(),
      score: _score,
      digitLength: _numberLength,
      inputCount:
          (_inputCount ~/ _numberLength), // Membagi jumlah input dengan 4
      elapsedTime:
          _stopwatch.elapsed.inSeconds, // Menyimpan waktu yang telah dihabiskan
    );

    try {
      final response = await http.post(
        Uri.parse(_firebaseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(scoreEntry.toJson()),
      );

      if (response.statusCode == 200) {
        await _loadHighScores();
      } else {
        // Tangani kesalahan jika tidak berhasil menyimpan
      }
    } catch (e) {}
  }

  // Loads high scores from Firebase
  Future<void> _loadHighScores() async {
    try {
      final response = await http.get(Uri.parse(_firebaseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);

        if (data != null) {
          _highScores = [];
          data.forEach((key, value) {
            final entry = ScoreEntry.fromJson(value);
            _highScores.add(entry);
          });

          // Sort high scores descending
          _highScores.sort((a, b) => b.score.compareTo(a.score));

          notifyListeners();
        }
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle error
    }
  }

  // Resets the game
  void resetGame() {
    _guesses.clear();
    _feedbacks.clear();
    _currentInput.clear();
    _score = 0;
    _inputCount = 0; // Reset jumlah input
    _generateTargetNumber();
    _stopwatch.reset();
    _stopwatch.start();
    notifyListeners();
  }

  void setNumberLength(int length) {
    _numberLength = length;
    _generateTargetNumber(); // Generate a new target number with the new length
    notifyListeners();
  }
}
