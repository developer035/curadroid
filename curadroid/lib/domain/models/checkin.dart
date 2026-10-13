import 'dart:convert';

class CheckIn {
  final int id;
  final DateTime ts;
  final int mood;    // 1..5
  final int energy;  // 1..5
  final int stress;  // 1..5
  final String? note;
  final List<String> tags;

  const CheckIn({
    required this.id,
    required this.ts,
    required this.mood,
    required this.energy,
    required this.stress,
    this.note,
    this.tags = const [],
  });

  factory CheckIn.fromJson(Map<String, dynamic> j) => CheckIn(
        id: j['id'] as int,
        ts: DateTime.parse(j['ts'] as String),
        mood: j['mood'] as int,
        energy: j['energy'] as int,
        stress: j['stress'] as int,
        note: j['note'] as String?,
        tags: List<String>.from(
            jsonDecode(j['tags'] as String? ?? '[]') as List),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ts': ts.toIso8601String(),
        'mood': mood,
        'energy': energy,
        'stress': stress,
        'note': note,
        'tags': jsonEncode(tags),
      };

  bool get hasWorryTag =>
      tags.any((t) => t.toLowerCase().contains('worr')) ||
      (note?.toLowerCase().contains('worr') ?? false) ||
      (note?.toLowerCase().contains('what if') ?? false);

  bool get hasRacingTag =>
      tags.any((t) => t.toLowerCase().contains('racing'));
}
