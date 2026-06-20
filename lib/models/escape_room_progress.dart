/// Data models for Escape Room progress persistence.
///
/// These models are serialized to JSON and stored via SharedPreferences.
library;

class EscapeRoomProgress {
  Map<String, RoomResult> rooms;
  bool storyViewed;
  bool isCompleted;
  DateTime? startedAt;
  DateTime? completedAt;

  EscapeRoomProgress({
    Map<String, RoomResult>? rooms,
    this.storyViewed = false,
    this.isCompleted = false,
    this.startedAt,
    this.completedAt,
  }) : rooms = rooms ?? {};

  factory EscapeRoomProgress.fromJson(Map<String, dynamic> json) {
    final roomsJson = json['rooms'] as Map<String, dynamic>? ?? {};
    return EscapeRoomProgress(
      rooms: roomsJson.map(
        (k, v) => MapEntry(k, RoomResult.fromJson(v as Map<String, dynamic>)),
      ),
      storyViewed: json['storyViewed'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'rooms': rooms.map((k, v) => MapEntry(k, v.toJson())),
        'storyViewed': storyViewed,
        'isCompleted': isCompleted,
        'startedAt': startedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };
}

class RoomResult {
  final int correctAnswers;
  final int totalQuestions;
  final String code;
  final bool isPassed;
  final DateTime completedAt;

  const RoomResult({
    required this.correctAnswers,
    required this.totalQuestions,
    required this.code,
    required this.isPassed,
    required this.completedAt,
  });

  double get percentage =>
      totalQuestions > 0 ? correctAnswers / totalQuestions : 0;

  int get percentInt => (percentage * 100).round();

  factory RoomResult.fromJson(Map<String, dynamic> json) => RoomResult(
        correctAnswers: json['correctAnswers'] as int,
        totalQuestions: json['totalQuestions'] as int,
        code: json['code'] as String,
        isPassed: json['isPassed'] as bool,
        completedAt: DateTime.parse(json['completedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'correctAnswers': correctAnswers,
        'totalQuestions': totalQuestions,
        'code': code,
        'isPassed': isPassed,
        'completedAt': completedAt.toIso8601String(),
      };
}
