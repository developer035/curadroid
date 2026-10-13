import '../../domain/models/technique.dart';

/// Single source of truth for all techniques.
const List<Technique> kTechniqueCatalog = [
  Technique(
    id: 'box_breathing',
    title: 'Box Breathing',
    subtitle: 'Reset your nervous system in 2 minutes',
    kind: TechniqueKind.breathing,
    minutes: 2,
    bestFor: [TechniqueTrigger.highStress, TechniqueTrigger.general],
    whyNow: 'Stress is high — box breathing resets your nervous system fast.',
    steps: [
      TechniqueStep(
        text: 'Box breathing uses equal counts to calm your nervous system. We\'ll do 4 rounds.',
        type: StepType.read,
      ),
      TechniqueStep(
        text: 'Breathe with the circle',
        type: StepType.breath,
        inhale: 4,
        holdIn: 4,
        exhale: 4,
        holdOut: 4,
        durationSec: 64, // 4 rounds × 16 sec
      ),
      TechniqueStep(
        text: 'Notice how you feel now. Take a slow, natural breath.',
        type: StepType.read,
        durationSec: 10,
      ),
    ],
  ),
  Technique(
    id: 'grounding_54321',
    title: '5-4-3-2-1 Grounding',
    subtitle: 'Anchor yourself in the present moment',
    kind: TechniqueKind.grounding,
    minutes: 5,
    bestFor: [TechniqueTrigger.highStress, TechniqueTrigger.general],
    whyNow: 'When thoughts race, your senses can bring you back to now.',
    steps: [
      TechniqueStep(
        text: 'This exercise uses your five senses to pull your attention into the present — out of your head.',
        type: StepType.read,
      ),
      TechniqueStep(
        text: 'Name 5 things you can see right now.',
        type: StepType.input,
        inputKey: 'see',
        durationSec: 30,
      ),
      TechniqueStep(
        text: 'Name 4 things you can hear.',
        type: StepType.input,
        inputKey: 'hear',
        durationSec: 25,
      ),
      TechniqueStep(
        text: 'Name 3 things you can physically feel (your feet on the floor, fabric on your skin…).',
        type: StepType.input,
        inputKey: 'touch',
        durationSec: 25,
      ),
      TechniqueStep(
        text: 'Name 2 things you can smell.',
        type: StepType.input,
        inputKey: 'smell',
        durationSec: 20,
      ),
      TechniqueStep(
        text: 'Name 1 thing you can taste.',
        type: StepType.input,
        inputKey: 'taste',
        durationSec: 15,
      ),
      TechniqueStep(
        text: 'You\'re here. Fully present. Well done.',
        type: StepType.read,
        durationSec: 10,
      ),
    ],
  ),
  Technique(
    id: 'thought_record',
    title: 'Thought Record',
    subtitle: 'Examine your thoughts clearly',
    kind: TechniqueKind.cognitive,
    minutes: 10,
    bestFor: [TechniqueTrigger.worry],
    whyNow: 'Writing out a worry separates the thought from the feeling.',
    steps: [
      TechniqueStep(
        text: 'A thought record helps you see your thoughts clearly rather than just feeling them. Take your time.',
        type: StepType.read,
      ),
      TechniqueStep(
        text: 'Describe the situation. What happened? When and where?',
        type: StepType.input,
        inputKey: 'situation',
        durationSec: 90,
      ),
      TechniqueStep(
        text: 'What automatic thought popped into your head? (e.g. "I always mess up")',
        type: StepType.input,
        inputKey: 'automatic_thought',
        durationSec: 60,
      ),
      TechniqueStep(
        text: 'What evidence supports this thought?',
        type: StepType.input,
        inputKey: 'evidence_for',
        durationSec: 90,
      ),
      TechniqueStep(
        text: 'What evidence goes against this thought? (Be a fair witness)',
        type: StepType.input,
        inputKey: 'evidence_against',
        durationSec: 90,
      ),
      TechniqueStep(
        text: 'Write a more balanced thought that holds both perspectives.',
        type: StepType.input,
        inputKey: 'balanced_thought',
        durationSec: 90,
      ),
      TechniqueStep(
        text: 'Read your balanced thought aloud once. Notice how it feels different.',
        type: StepType.read,
        durationSec: 15,
      ),
    ],
  ),
  Technique(
    id: 'behavioral_activation',
    title: 'Behavioral Activation',
    subtitle: 'Break the low-energy loop with one small action',
    kind: TechniqueKind.behavioural,
    minutes: 5,
    bestFor: [TechniqueTrigger.lowEnergy],
    whyNow: 'Low mood and energy form a loop. One tiny action breaks it.',
    steps: [
      TechniqueStep(
        text: 'When we feel low, we often wait to feel better before acting. Behavioral activation flips this — we act first, and feeling better follows.',
        type: StepType.read,
      ),
      TechniqueStep(
        text: 'Think of one tiny, enjoyable (or just neutral) action you could do in the next hour. It doesn\'t have to be productive.',
        type: StepType.input,
        inputKey: 'action',
        durationSec: 60,
      ),
      TechniqueStep(
        text: 'When will you do it? (Be specific — "at 3pm" is better than "later today")',
        type: StepType.input,
        inputKey: 'schedule',
        durationSec: 30,
      ),
      TechniqueStep(
        text: 'That\'s it. You\'ve made a commitment to yourself. Even 5 minutes of something you chose counts.',
        type: StepType.read,
        durationSec: 10,
      ),
    ],
  ),
  Technique(
    id: 'wind_down_breathing',
    title: 'Wind-Down Breathing',
    subtitle: 'Prepare your body for rest',
    kind: TechniqueKind.breathing,
    minutes: 3,
    bestFor: [TechniqueTrigger.poorSleep],
    whyNow: 'Your sleep was below baseline. A longer exhale activates your body\'s rest response.',
    steps: [
      TechniqueStep(
        text: 'The extended exhale (longer than the inhale) activates the parasympathetic nervous system — your body\'s natural off-switch.',
        type: StepType.read,
      ),
      TechniqueStep(
        text: 'Follow the breathing circle',
        type: StepType.breath,
        inhale: 4,
        holdIn: 0,
        exhale: 6,
        holdOut: 0,
        durationSec: 60, // 6 rounds × 10 sec
      ),
      TechniqueStep(
        text: 'Let your breathing return to its natural rhythm. You\'re ready for rest.',
        type: StepType.read,
        durationSec: 10,
      ),
    ],
  ),
];

Technique? techniqueById(String id) {
  try {
    return kTechniqueCatalog.firstWhere((t) => t.id == id);
  } catch (_) {
    return null;
  }
}
