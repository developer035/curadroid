enum TechniqueKind { breathing, grounding, cognitive, behavioural }
enum StepType { read, input, timer, breath }
enum TechniqueTrigger { highStress, lowEnergy, worry, poorSleep, general }

class TechniqueStep {
  final String text;
  final int? durationSec;
  final StepType type;
  // For breath steps: inhale, hold, exhale, hold durations in seconds
  final int? inhale;
  final int? holdIn;
  final int? exhale;
  final int? holdOut;
  final String? inputKey; // for input steps

  const TechniqueStep({
    required this.text,
    this.durationSec,
    required this.type,
    this.inhale,
    this.holdIn,
    this.exhale,
    this.holdOut,
    this.inputKey,
  });
}

class Technique {
  final String id;
  final String title;
  final String subtitle;
  final TechniqueKind kind;
  final int minutes;
  final List<TechniqueStep> steps;
  final List<TechniqueTrigger> bestFor;
  final String whyNow; // "why this, why now" line for coach

  const Technique({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.minutes,
    required this.steps,
    required this.bestFor,
    required this.whyNow,
  });

  String get kindLabel => switch (kind) {
        TechniqueKind.breathing => 'Breathing',
        TechniqueKind.grounding => 'Grounding',
        TechniqueKind.cognitive => 'Cognitive',
        TechniqueKind.behavioural => 'Behavioural',
      };
}
