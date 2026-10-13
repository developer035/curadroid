import '../models/checkin.dart';

class ComputeStreak {
  const ComputeStreak();

  /// Returns the current streak (consecutive local days with ≥1 check-in).
  /// Allows a 1-day grace: if today has no check-in, we start counting from yesterday.
  int call(List<CheckIn> allCheckins) {
    if (allCheckins.isEmpty) return 0;

    // Collect distinct local dates that have check-ins
    final dates = allCheckins
        .map((c) => _localDate(c.ts))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // newest first

    final today = _localDate(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    // If most recent check-in is older than yesterday, streak is broken
    if (dates.first.isBefore(yesterday)) return 0;

    // Count consecutive days backwards (with 1-day grace built-in by starting from yesterday)
    int streak = 0;
    DateTime cursor = dates.first;

    for (final date in dates) {
      if (date == cursor) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else if (date.isBefore(cursor)) {
        // Gap — streak ends
        break;
      }
    }

    return streak;
  }

  DateTime _localDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
