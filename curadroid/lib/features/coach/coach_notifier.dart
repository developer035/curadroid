import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/crisis_detector.dart';
import '../../data/repositories/checkin_repo.dart';
import '../../data/repositories/health_repo.dart';
import '../../data/repositories/session_repo.dart';
import '../../data/repositories/settings_repo.dart';
import '../../domain/coach/llm_coach_engine.dart';
import '../../domain/coach/scripted_coach_engine.dart';
import '../../domain/models/checkin.dart';
import '../../domain/models/coach_message.dart';
import '../../domain/models/readiness.dart';
import '../../domain/usecases/compute_readiness.dart';
import '../../domain/usecases/pick_technique.dart';

class CoachSessionState {
  final List<CoachMessage> messages;
  final bool isTyping;
  final CheckIn? checkin;
  final Readiness? readiness;
  final String techniqueId;
  final bool loading;
  final bool crisisDetected;

  const CoachSessionState({
    this.messages = const [],
    this.isTyping = false,
    this.checkin,
    this.readiness,
    this.techniqueId = 'grounding_54321',
    this.loading = true,
    this.crisisDetected = false,
  });

  CoachSessionState copyWith({
    List<CoachMessage>? messages,
    bool? isTyping,
    CheckIn? checkin,
    Readiness? readiness,
    String? techniqueId,
    bool? loading,
    bool? crisisDetected,
  }) =>
      CoachSessionState(
        messages: messages ?? this.messages,
        isTyping: isTyping ?? this.isTyping,
        checkin: checkin ?? this.checkin,
        readiness: readiness ?? this.readiness,
        techniqueId: techniqueId ?? this.techniqueId,
        loading: loading ?? this.loading,
        crisisDetected: crisisDetected ?? this.crisisDetected,
      );
}

final coachNotifierProvider = StateNotifierProvider.family
    .autoDispose<CoachNotifier, CoachSessionState, int?>(
  (ref, checkinId) => CoachNotifier(
    ref.watch(checkinRepoProvider),
    ref.watch(healthRepoProvider),
    ref.watch(sessionRepoProvider),
    ref.watch(settingsRepoProvider),
    checkinId,
  ),
);

class CoachNotifier extends StateNotifier<CoachSessionState> {
  final CheckinRepository _checkinRepo;
  final HealthRepository _healthRepo;
  final SessionRepository _sessionRepo;
  final SettingsRepository _settingsRepo;
  final int? _checkinId;
  final _scriptedEngine = ScriptedCoachEngine();
  final _llmEngine = LlmCoachEngine();
  static const _computeReadiness = ComputeReadiness();
  static const _pickTechnique = PickTechnique();

  CoachNotifier(
    this._checkinRepo,
    this._healthRepo,
    this._sessionRepo,
    this._settingsRepo,
    this._checkinId,
  ) : super(const CoachSessionState()) {
    _init();
  }

  Future<void> _init() async {
    // Load checkin by finding latest if id not specific
    final allCheckins = await _checkinRepo.all();
    CheckIn? checkin;
    if (_checkinId != null) {
      try {
        checkin = allCheckins.firstWhere((c) => c.id == _checkinId);
      } catch (_) {
        // Fallback: use most-recent check-in
        checkin = allCheckins.isNotEmpty ? allCheckins.first : null;
      }
    } else {
      // No specific id: use the most-recent check-in (DAOs sort by ts DESC)
      checkin = allCheckins.isNotEmpty ? allCheckins.first : null;
    }

    final history = await _healthRepo.recentDays(30);
    final todayHealth = await _healthRepo.today();
    final baseline = history.where((d) => !_isToday(d.date)).toList();

    final readiness = _computeReadiness(
      today: todayHealth,
      history: baseline,
      todayCheckin: checkin,
    );
    final techniqueId = _pickTechnique(readiness: readiness, checkin: checkin);

    state = state.copyWith(
      checkin: checkin,
      readiness: readiness,
      techniqueId: techniqueId,
      loading: false,
      isTyping: true,
    );

    if (_settingsRepo.useAiCoach && _settingsRepo.hasAiConsent) {
      await _streamCoachTurn(
        userMessage: "Hello, I just completed my check-in.",
        history: const [],
        isStart: true,
      );
    } else {
      await _typingDelay();
      final firstMsg = _scriptedEngine.start(
        checkin: checkin ?? _dummyCheckin(),
        readiness: readiness,
        techniqueId: techniqueId,
      );
      state = state.copyWith(messages: [firstMsg], isTyping: false);
    }
  }

  void grantConsent() {
    _settingsRepo.hasAiConsent = true;
  }

  Future<void> reply(String? userText) async {
    final checkin = state.checkin ?? _dummyCheckin();
    final readiness = state.readiness;
    if (readiness == null) return;

    if (userText == null || userText.trim().isEmpty) return;
    final trimmed = userText.trim();

    // Intercept user input with CrisisDetector
    if (CrisisDetector.containsCrisisRisk(trimmed)) {
      final messages = List<CoachMessage>.from(state.messages)
        ..add(CoachMessage(text: trimmed, sender: MessageSender.user))
        ..add(
          const CoachMessage(
            text:
                "I hear how much pain you're in, and your safety is the most important thing right now. Please connect with someone who can support you. In the US, you can call or text 988 anytime (free, confidential, 24/7).",
            sender: MessageSender.coach,
            chips: ["Find Help Now", "I am safe"],
          ),
        );

      state = state.copyWith(
        messages: messages,
        isTyping: false,
        crisisDetected: true,
      );
      return;
    }

    // Normal reply
    final messages = List<CoachMessage>.from(state.messages)
      ..add(CoachMessage(text: trimmed, sender: MessageSender.user));

    state = state.copyWith(messages: messages, isTyping: true);

    if (_settingsRepo.useAiCoach && _settingsRepo.hasAiConsent) {
      await _streamCoachTurn(
        userMessage: trimmed,
        history: messages,
        isStart: false,
      );
    } else {
      await _typingDelay();
      final next = _scriptedEngine.next(
        history: messages,
        userReply: trimmed,
        checkin: checkin,
        readiness: readiness,
        techniqueId: state.techniqueId,
      );
      state = state.copyWith(messages: [...messages, next], isTyping: false);
    }
  }

  Future<void> _streamCoachTurn({
    required String userMessage,
    required List<CoachMessage> history,
    required bool isStart,
  }) async {
    final checkin = state.checkin ?? _dummyCheckin();
    final readiness = state.readiness!;
    final sessions = await _sessionRepo.recent(7);

    final stream = _llmEngine.streamTurn(
      baseUrl: _settingsRepo.proxyBaseUrl,
      installId: _settingsRepo.anonymousInstallId,
      checkin: checkin,
      readiness: readiness,
      userMessage: userMessage,
      history: history,
      defaultTechniqueId: state.techniqueId,
      recentSessions: sessions,
    );

    CoachMessage? lastMessage;
    await for (final event in stream) {
      if (event is LlmChunkEvent) {
        final msgs = List<CoachMessage>.from(state.messages);
        if (msgs.isNotEmpty &&
            msgs.last.sender == MessageSender.coach &&
            msgs.last.chips == null &&
            msgs.last.techniqueId == null) {
          msgs[msgs.length - 1] = CoachMessage(
            text: event.text,
            sender: MessageSender.coach,
            state: isStart ? CoachState.listen : CoachState.explore,
          );
        } else {
          msgs.add(
            CoachMessage(
              text: event.text,
              sender: MessageSender.coach,
              state: isStart ? CoachState.listen : CoachState.explore,
            ),
          );
        }
        state = state.copyWith(messages: msgs, isTyping: false);
      } else if (event is LlmCompleteEvent) {
        lastMessage = event.message;
      }
    }

    if (lastMessage != null) {
      final msgs = List<CoachMessage>.from(state.messages);
      if (msgs.isNotEmpty &&
          msgs.last.sender == MessageSender.coach &&
          msgs.last.chips == null &&
          msgs.last.techniqueId == null) {
        msgs[msgs.length - 1] = lastMessage;
      } else {
        msgs.add(lastMessage);
      }

      state = state.copyWith(
        messages: msgs,
        techniqueId: lastMessage.techniqueId ?? state.techniqueId,
        isTyping: false,
      );
    }
  }

  /// Called after the user completes an exercise. Shows the Close state message
  /// with a personalised mood delta line.
  Future<void> closeSession({int? preMood, int? postMood}) async {
    state = state.copyWith(isTyping: true);
    await _typingDelay();

    String closeText;
    if (preMood != null && postMood != null) {
      final delta = postMood - preMood;
      if (delta > 0) {
        closeText =
            'Nice work 🙌 Your mood shifted from $preMood to $postMood — a +$delta improvement. Even a few minutes like this adds up.';
      } else if (delta < 0) {
        closeText =
            'You showed up and did the work — that matters. Sometimes the shift comes later. Your nervous system noticed.';
      } else {
        closeText =
            'You stayed with it — and that counts. Keep checking in daily to build momentum.';
      }
    } else {
      closeText =
          'Nice work. Even a few minutes like this counts. Your nervous system notices, even when your mind doesn\'t.';
    }

    final closeMsg = CoachMessage(
      text: closeText,
      sender: MessageSender.coach,
      state: CoachState.close,
    );
    state = state.copyWith(
      messages: [...state.messages, closeMsg],
      isTyping: false,
    );
  }

  Future<void> _typingDelay() async {
    final ms = 400 + math.Random().nextInt(300);
    await Future.delayed(Duration(milliseconds: ms));
  }

  CheckIn _dummyCheckin() =>
      CheckIn(id: 0, ts: _epoch, mood: 3, energy: 3, stress: 3);

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }
}

final _epoch = DateTime.utc(2000);
