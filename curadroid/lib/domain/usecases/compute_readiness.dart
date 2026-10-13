import '../models/health_day.dart';
import '../models/readiness.dart';
import '../models/checkin.dart';

// Population defaults when baseline data is insufficient (<5 days)
const _defaultSleep = 450.0;  // minutes
const _defaultHrv = 50.0;     // ms
const _defaultRhr = 62.0;     // bpm
const _baselineDays = 14;

class ComputeReadiness {
  const ComputeReadiness();

  /// Computes [Readiness] from today's [HealthDay] and [history] (last 14 days).
  /// [todayCheckin] is optional — used for stress index calculation.
  Readiness call({
    required HealthDay? today,
    required List<HealthDay> history,
    CheckIn? todayCheckin,
  }) {
    final baseline = _computeBaseline(history);

    double? sleepScore = _sleepScore(today?.sleepMin?.toDouble(), baseline.sleep);
    double? hrvScore = _hrvScore(today?.hrvMs, baseline.hrv);
    double? rhrScore = _rhrScore(today?.restingHr?.toDouble(), baseline.rhr);

    // Renormalise weights when metrics are missing
    final scores = <double, double>{
      if (sleepScore != null) 0.40: sleepScore,
      if (hrvScore != null) 0.35: hrvScore,
      if (rhrScore != null) 0.25: rhrScore,
    };

    final int readiness;
    if (scores.isEmpty) {
      readiness = 50; // neutral default with no data
    } else {
      final totalWeight = scores.keys.fold(0.0, (a, b) => a + b);
      final weightedSum = scores.entries
          .fold(0.0, (a, e) => a + e.key * e.value);
      readiness = (weightedSum / totalWeight).round().clamp(0, 100);
    }

    final stressIndex = _stressIndex(readiness, todayCheckin);
    final drivers = _drivers(today, baseline, history);

    return Readiness(
      score: readiness,
      stressIndex: stressIndex,
      band: Readiness.bandFor(readiness),
      drivers: drivers,
    );
  }

  _Baseline _computeBaseline(List<HealthDay> history) {
    if (history.length < 5) {
      return _Baseline(_defaultSleep, _defaultHrv, _defaultRhr);
    }
    final recent = history.take(_baselineDays).toList();
    double sleepSum = 0; int sleepCount = 0;
    double hrvSum = 0; int hrvCount = 0;
    double rhrSum = 0; int rhrCount = 0;

    for (final d in recent) {
      if (d.sleepMin != null) { sleepSum += d.sleepMin!; sleepCount++; }
      if (d.hrvMs != null) { hrvSum += d.hrvMs!; hrvCount++; }
      if (d.restingHr != null) { rhrSum += d.restingHr!; rhrCount++; }
    }

    return _Baseline(
      sleepCount > 0 ? sleepSum / sleepCount : _defaultSleep,
      hrvCount > 0 ? hrvSum / hrvCount : _defaultHrv,
      rhrCount > 0 ? rhrSum / rhrCount : _defaultRhr,
    );
  }

  double? _sleepScore(double? sleep, double baseSleep) {
    if (sleep == null) return null;
    return (100.0 * sleep / 480.0).clamp(0.0, 100.0);
  }

  double? _hrvScore(double? hrv, double baseHrv) {
    if (hrv == null) return null;
    return (50.0 + 50.0 * (hrv - baseHrv) / (0.3 * baseHrv)).clamp(0.0, 100.0);
  }

  double? _rhrScore(double? rhr, double baseRhr) {
    if (rhr == null) return null;
    return (50.0 - 50.0 * (rhr - baseRhr) / (0.15 * baseRhr)).clamp(0.0, 100.0);
  }

  int _stressIndex(int readiness, CheckIn? checkin) {
    final base = 0.6 * (100 - readiness);
    if (checkin == null) return base.round().clamp(0, 100);
    final selfStress = 0.4 * ((checkin.stress - 1) / 4.0 * 100);
    return (base + selfStress).round().clamp(0, 100);
  }

  List<String> _drivers(
      HealthDay? today, _Baseline baseline, List<HealthDay> history) {
    final drivers = <({double deviation, String message})>[];

    if (today?.sleepMin != null) {
      final diff = today!.sleepMin! - baseline.sleep;
      if (diff.abs() > 30) {
        final label = diff < 0
            ? 'Sleep was ${(-diff).round()} min below your baseline'
            : 'Sleep was ${diff.round()} min above your baseline';
        drivers.add((deviation: diff.abs(), message: label));
      }
    }

    if (today?.hrvMs != null) {
      final diff = today!.hrvMs! - baseline.hrv;
      final pct = (diff / baseline.hrv * 100).abs();
      if (pct > 10) {
        final label = diff < 0
            ? 'HRV is ${pct.round()}% below your baseline — your body is working harder'
            : 'HRV is ${pct.round()}% above your baseline — great recovery';
        drivers.add((deviation: pct, message: label));
      }
    }

    if (today?.restingHr != null) {
      final diff = today!.restingHr! - baseline.rhr;
      if (diff.abs() > 3) {
        final label = diff > 0
            ? 'Resting HR is ${diff.round()} bpm higher than usual'
            : 'Resting HR is ${(-diff).round()} bpm lower than usual — great sign';
        drivers.add((deviation: diff.abs(), message: label));
      }
    }

    // Return top 2 by deviation magnitude
    drivers.sort((a, b) => b.deviation.compareTo(a.deviation));
    return drivers.take(2).map((d) => d.message).toList();
  }
}

class _Baseline {
  final double sleep;
  final double hrv;
  final double rhr;
  const _Baseline(this.sleep, this.hrv, this.rhr);
}
