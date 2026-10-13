import '../../domain/models/checkin.dart';
import '../../domain/models/coach_message.dart';
import '../../domain/models/readiness.dart';
import 'coach_engine.dart';

/// Message templates keyed by (CoachState, context).
/// This is purely scripted — no network, no LLM.
class ScriptedCoachEngine implements CoachEngine {
  @override
  CoachMessage start({
    required CheckIn checkin,
    required Readiness readiness,
    required String techniqueId,
  }) {
    final text = _listenText(checkin, readiness);
    return CoachMessage(
      text: text,
      sender: MessageSender.coach,
      state: CoachState.listen,
    );
  }

  @override
  CoachMessage next({
    required List<CoachMessage> history,
    required String? userReply,
    required CheckIn checkin,
    required Readiness readiness,
    required String techniqueId,
  }) {
    final lastCoachState = history
        .lastWhere((m) => m.sender == MessageSender.coach, orElse: () => history.first)
        .state;

    return switch (lastCoachState) {
      CoachState.listen => _exploreMessage(checkin, readiness),
      CoachState.explore => _suggestMessage(checkin, readiness, techniqueId),
      CoachState.suggest => _closeMessage(checkin),
      _ => _closeMessage(checkin),
    };
  }

  // ─── Listen ───────────────────────────────────────────────────────────────

  String _listenText(CheckIn c, Readiness r) {
    if (c.mood <= 2 && c.energy <= 2) {
      return "It sounds like today is weighing on you — low energy and a tough mood. That's okay. I'm here.";
    }
    if (c.stress >= 4) {
      return "I can hear that things feel intense right now. Your stress is elevated and that's worth paying attention to.";
    }
    if (c.mood >= 4 && r.band == ReadinessBand.good) {
      return "You're in a good place today — solid readiness and your mood reflects it. Let's make the most of it.";
    }
    if (r.band == ReadinessBand.low) {
      return "Your body is signalling that it needs some rest. Let's do something gentle and restorative together.";
    }
    return "Thanks for checking in. I've got a sense of where you are today — let's explore a bit further.";
  }

  // ─── Explore ──────────────────────────────────────────────────────────────

  CoachMessage _exploreMessage(CheckIn c, Readiness r) {
    if (c.stress >= 4 || r.stressIndex >= 70) {
      return const CoachMessage(
        text: "What's the loudest thought in your head right now?",
        sender: MessageSender.coach,
        state: CoachState.explore,
        chips: ["Everything feels urgent", "A specific worry", "My body feels tense", "I'm not sure"],
      );
    }
    if (c.mood <= 2) {
      return const CoachMessage(
        text: "What's been getting in the way of feeling like yourself today?",
        sender: MessageSender.coach,
        state: CoachState.explore,
        chips: ["Low energy", "Hard thoughts", "Something happened", "Just one of those days"],
      );
    }
    return const CoachMessage(
      text: "What would feel most helpful for you right now?",
      sender: MessageSender.coach,
      state: CoachState.explore,
      chips: ["Clear my head", "Feel more grounded", "Work through a thought", "Gentle movement"],
    );
  }

  // ─── Suggest ─────────────────────────────────────────────────────────────

  CoachMessage _suggestMessage(CheckIn c, Readiness r, String techniqueId) {
    final why = _whyNow(c, r, techniqueId);
    return CoachMessage(
      text: why,
      sender: MessageSender.coach,
      state: CoachState.suggest,
      techniqueId: techniqueId,
    );
  }

  String _whyNow(CheckIn c, Readiness r, String id) => switch (id) {
        'box_breathing' =>
          "Box breathing is the fastest tool for resetting a stressed nervous system. 4 counts in, hold, out, hold — and you'll feel the shift.",
        'grounding_54321' =>
          "When thoughts race, your senses can anchor you back to the present. The 5-4-3-2-1 technique gently pulls attention out of your head.",
        'thought_record' =>
          "Your mind may be running a story. Writing it out — the thought, the evidence for and against — helps you see it clearly rather than just feel it.",
        'behavioral_activation' =>
          "Low energy and mood often form a loop. One tiny intentional action breaks the cycle. It doesn't have to be big.",
        'wind_down_breathing' =>
          "Your body didn't get the rest it needed. A slow exhale activates your parasympathetic system — nature's off-switch.",
        _ =>
          "I've found something that could help right now. Give it a try and see how you feel.",
      };

  // ─── Close ────────────────────────────────────────────────────────────────

  CoachMessage _closeMessage(CheckIn c) {
    return CoachMessage(
      text: "Nice work. Even a few minutes like this counts. Your nervous system notices, even when your mind doesn't.",
      sender: MessageSender.coach,
      state: CoachState.close,
    );
  }
}
