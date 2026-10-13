class HealthDay {
  final DateTime date;
  final int? sleepMin;
  final double? hrvMs;
  final int? restingHr;
  final int? steps;
  final String source; // 'mock' | 'health_connect'

  const HealthDay({
    required this.date,
    this.sleepMin,
    this.hrvMs,
    this.restingHr,
    this.steps,
    this.source = 'mock',
  });

  HealthDay copyWith({
    int? sleepMin,
    double? hrvMs,
    int? restingHr,
    int? steps,
    String? source,
  }) =>
      HealthDay(
        date: date,
        sleepMin: sleepMin ?? this.sleepMin,
        hrvMs: hrvMs ?? this.hrvMs,
        restingHr: restingHr ?? this.restingHr,
        steps: steps ?? this.steps,
        source: source ?? this.source,
      );
}
