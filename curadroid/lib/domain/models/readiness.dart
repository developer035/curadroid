enum ReadinessBand { low, moderate, good }

class Readiness {
  final int score;         // 0..100 higher is better
  final int stressIndex;   // 0..100 higher is worse
  final ReadinessBand band;
  final List<String> drivers; // plain-English driver sentences

  const Readiness({
    required this.score,
    required this.stressIndex,
    required this.band,
    required this.drivers,
  });

  static ReadinessBand bandFor(int score) {
    if (score >= 70) return ReadinessBand.good;
    if (score >= 40) return ReadinessBand.moderate;
    return ReadinessBand.low;
  }

  String get bandLabel => switch (band) {
        ReadinessBand.good => 'Good',
        ReadinessBand.moderate => 'Moderate',
        ReadinessBand.low => 'Low',
      };

  String get stressLabel {
    if (stressIndex >= 70) return 'High';
    if (stressIndex >= 40) return 'Moderate';
    return 'Low';
  }
}
