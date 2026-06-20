import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/escape_room_progress.dart';

/// Central state management for the Escape Room flow.
///
/// Each room (r1, r2, r3) generates a random 4-character alphanumeric code
/// (A-Z, 0-9) when the user reaches ≥ 70% correct answers.
///
/// FINAL PUZZLE (Room 4) logic:
///   Expected code = char at index 0 from r1
///                 + char at index 1 from r2
///                 + char at index 2 from r3
///                 + char at index 3 from r4
///   Example: r1="A7K9" r2="P4M2" r3="X8T5" r4="Q2R6" → "A4T6"
class EscapeRoomProvider extends ChangeNotifier {
  // ─── Constants ────────────────────────────────────────────────────
  static const String _storageKey = 'escape_room_progress_v2';
  static const double passThreshold = 0.70; // 70 %

  /// Characters used when generating random room codes.
  static const String _codeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  // (removed I/O/0/1 to avoid visual ambiguity)

  // ─── State ────────────────────────────────────────────────────────
  EscapeRoomProgress _progress = EscapeRoomProgress();
  EscapeRoomProgress get progress => _progress;

  // ─── Persistence ──────────────────────────────────────────────────
  Future<void> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_storageKey);
      if (json != null) {
        _progress = EscapeRoomProgress.fromJson(
          jsonDecode(json) as Map<String, dynamic>,
        );
      }
    } catch (_) {
      _progress = EscapeRoomProgress();
    }
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(_progress.toJson()));
    } catch (_) {
      // Silently fail – progress is still in memory.
    }
  }

  // ─── Story ────────────────────────────────────────────────────────
  void markStoryViewed() {
    _progress.storyViewed = true;
    _progress.startedAt ??= DateTime.now();
    _save();
    notifyListeners();
  }

  // ─── Code generation ──────────────────────────────────────────────
  /// Generates a random 4-character alphanumeric code (A-Z, 0-9, excluding
  /// visually ambiguous characters: I, O, 0, 1).
  ///
  /// The [roomId] is used as part of the seed so that if the player retries
  /// a room on the same millisecond the code still differs between rooms.
  String _generateCode(String roomId) {
    final seed = DateTime.now().millisecondsSinceEpoch ^ roomId.hashCode;
    final rng = Random(seed);
    return List.generate(4, (_) => _codeAlphabet[rng.nextInt(_codeAlphabet.length)]).join();
  }

  // ─── Room completion ──────────────────────────────────────────────
  /// Records a room result. If the room passes (≥ 70%), a random 4-char code
  /// is generated. If the room fails, the code is empty.
  void completeRoom(String roomId, int correct, int total) {
    final passed = total > 0 && (correct / total) >= passThreshold;
    final code = passed ? _generateCode(roomId) : '';

    _progress.rooms[roomId] = RoomResult(
      correctAnswers: correct,
      totalQuestions: total,
      code: code,
      isPassed: passed,
      completedAt: DateTime.now(),
    );
    _save();
    notifyListeners();
  }

  // ─── Access control ───────────────────────────────────────────────
  bool canAccessRoom(String roomId) {
    switch (roomId) {
      case 'r1':
        return true;
      case 'r2':
        return _progress.rooms['r1']?.isPassed ?? false;
      case 'r3':
        return _progress.rooms['r2']?.isPassed ?? false;
      case 'r4':
        return (_progress.rooms['r1']?.isPassed ?? false) &&
            (_progress.rooms['r2']?.isPassed ?? false) &&
            (_progress.rooms['r3']?.isPassed ?? false);
      default:
        return false;
    }
  }

  // ─── Codes ────────────────────────────────────────────────────────
  String? getCode(String roomId) => _progress.rooms[roomId]?.code;

  Map<String, String> getAllCodes() {
    final codes = <String, String>{};
    for (final entry in _progress.rooms.entries) {
      if (entry.value.code.isNotEmpty) {
        codes[entry.key] = entry.value.code;
      }
    }
    return codes;
  }

  // ─── Final Puzzle validation ──────────────────────────────────────
  /// The expected FINAL code is assembled from one character per room:
  ///   Position 0 (1st char) from Room 1
  ///   Position 1 (2nd char) from Room 2
  ///   Position 2 (3rd char) from Room 3
  ///   Position 3 (4th char) from Room 4
  ///
  /// All four rooms must be completed and have a 4-char code for this to work.
  bool validateFinalCode(String input) {
    final r1 = _progress.rooms['r1']?.code ?? '';
    final r2 = _progress.rooms['r2']?.code ?? '';
    final r3 = _progress.rooms['r3']?.code ?? '';
    final r4 = _progress.rooms['r4']?.code ?? '';

    if (r1.length < 4 || r2.length < 4 || r3.length < 4 || r4.length < 4) {
      return false;
    }

    final expected = '${r1[0]}${r2[1]}${r3[2]}${r4[3]}';
    final cleaned = input.trim().toUpperCase().replaceAll(RegExp(r'[\s\-]'), '');
    return cleaned == expected;
  }

  /// Returns the 4-character final code that the player must enter.
  /// Returns '????' if any room is not yet completed.
  String get expectedFinalCode {
    final r1 = _progress.rooms['r1']?.code ?? '';
    final r2 = _progress.rooms['r2']?.code ?? '';
    final r3 = _progress.rooms['r3']?.code ?? '';
    final r4 = _progress.rooms['r4']?.code ?? '';

    final c1 = r1.length >= 1 ? r1[0] : '?';
    final c2 = r2.length >= 2 ? r2[1] : '?';
    final c3 = r3.length >= 3 ? r3[2] : '?';
    final c4 = r4.length >= 4 ? r4[3] : '?';

    return '$c1$c2$c3$c4';
  }

  // ─── Completion ───────────────────────────────────────────────────
  void markCompleted() {
    _progress.isCompleted = true;
    _progress.completedAt = DateTime.now();
    _save();
    notifyListeners();
  }

  // ─── Retry / Reset ────────────────────────────────────────────────
  void retryRoom(String roomId) {
    _progress.rooms.remove(roomId);
    _save();
    notifyListeners();
  }

  void resetAll() {
    _progress = EscapeRoomProgress();
    _save();
    notifyListeners();
  }

  // ─── Calculated start phase ───────────────────────────────────────
  /// Returns the phase to resume at based on persisted progress.
  int get startPhase {
    if (_progress.isCompleted) return 5;
    if (!_progress.storyViewed) return 0;
    if (!(_progress.rooms['r1']?.isPassed ?? false)) return 1;
    if (!(_progress.rooms['r2']?.isPassed ?? false)) return 2;
    if (!(_progress.rooms['r3']?.isPassed ?? false)) return 3;
    return 4;
  }

  // ─── Helpers ──────────────────────────────────────────────────────
  static String motivationalMessage(double pct) {
    if (pct >= 1.0) return '🏆 PERFECT SCORE! Absolutely incredible!';
    if (pct >= 0.9) return '🌟 Amazing work! Almost perfect!';
    if (pct >= 0.8) return '🎉 Great job! You really know your English!';
    if (pct >= 0.7) return '🚀 You passed this room! Keep it up!';
    if (pct >= 0.6) return '💪 So close! Just a little more practice.';
    if (pct >= 0.5) return '📚 Keep studying! You\'re on the right track.';
    return '🔥 Don\'t give up! Review and try again.';
  }

  static int requiredCorrect(int total) => (total * passThreshold).ceil();
}
