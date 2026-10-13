import '../models/checkin.dart';
import '../models/readiness.dart';

/// Technique IDs must match the catalog in features/exercises/catalog.dart
const kBoxBreathing = 'box_breathing';
const kBehavioralActivation = 'behavioral_activation';
const kThoughtRecord = 'thought_record';
const kWindDownBreathing = 'wind_down_breathing';
const kGrounding54321 = 'grounding_54321';

class PickTechnique {
  const PickTechnique();

  /// Returns the best technique ID given current [readiness] and optional [checkin].
  /// Rule order is first-match, as per the design doc.
  String call({required Readiness readiness, CheckIn? checkin}) {
    // Rule 1: High stress or racing-thoughts tag
    if (readiness.stressIndex >= 70 ||
        (checkin?.hasRacingTag ?? false)) {
      return kBoxBreathing;
    }

    // Rule 2: Low mood AND low energy
    if (checkin != null && checkin.mood <= 2 && checkin.energy <= 2) {
      return kBehavioralActivation;
    }

    // Rule 3: Worry / "what if" in note or tags
    if (checkin?.hasWorryTag ?? false) {
      return kThoughtRecord;
    }

    // Rule 4: Sleep more than 60 min below baseline
    // (We don't have baseline here; drivers text contains "below your baseline"
    // so we check drivers as a proxy — this keeps the use-case pure.)
    final hasSleepDriver = readiness.drivers
        .any((d) => d.toLowerCase().contains('sleep') && d.contains('below'));
    if (hasSleepDriver) {
      return kWindDownBreathing;
    }

    // Rule 5: Default
    return kGrounding54321;
  }
}
