import 'dart:convert';

class ExerciseSession {
  final int id;
  final String techniqueId;
  final DateTime startedAt;
  final DateTime completedAt;
  final int? preMood;
  final int? postMood;
  final Map<String, String> inputs; // thought-record fields, etc.

  const ExerciseSession({
    required this.id,
    required this.techniqueId,
    required this.startedAt,
    required this.completedAt,
    this.preMood,
    this.postMood,
    this.inputs = const {},
  });

  int? get moodDelta =>
      (preMood != null && postMood != null) ? postMood! - preMood! : null;

  factory ExerciseSession.fromJson(Map<String, dynamic> j) => ExerciseSession(
        id: j['id'] as int,
        techniqueId: j['technique_id'] as String,
        startedAt: DateTime.parse(j['started_at'] as String),
        completedAt: DateTime.parse(j['completed_at'] as String),
        preMood: j['pre_mood'] as int?,
        postMood: j['post_mood'] as int?,
        inputs: Map<String, String>.from(
            jsonDecode(j['inputs'] as String? ?? '{}') as Map),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'technique_id': techniqueId,
        'started_at': startedAt.toIso8601String(),
        'completed_at': completedAt.toIso8601String(),
        'pre_mood': preMood,
        'post_mood': postMood,
        'inputs': jsonEncode(inputs),
      };
}
