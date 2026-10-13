import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../features/exercises/catalog.dart';
import '../models/checkin.dart';
import '../models/coach_message.dart';
import '../models/exercise_session.dart';
import '../models/readiness.dart';
import 'coach_engine.dart';
import 'scripted_coach_engine.dart';

sealed class LlmStreamEvent {}

class LlmChunkEvent extends LlmStreamEvent {
  final String text;
  LlmChunkEvent(this.text);
}

class LlmCompleteEvent extends LlmStreamEvent {
  final CoachMessage message;
  LlmCompleteEvent(this.message);
}

/// LLM-powered Coach Engine that streams responses from the proxy backend via SSE.
/// If network, timeout, or schema issues occur, it transparently falls back to
/// [ScriptedCoachEngine].
class LlmCoachEngine implements CoachEngine {
  final http.Client _client;
  final ScriptedCoachEngine _fallbackEngine;

  LlmCoachEngine({
    http.Client? client,
    ScriptedCoachEngine? fallbackEngine,
  })  : _client = client ?? http.Client(),
        _fallbackEngine = fallbackEngine ?? ScriptedCoachEngine();

  @override
  CoachMessage start({
    required CheckIn checkin,
    required Readiness readiness,
    required String techniqueId,
  }) {
    return _fallbackEngine.start(
      checkin: checkin,
      readiness: readiness,
      techniqueId: techniqueId,
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
    return _fallbackEngine.next(
      history: history,
      userReply: userReply,
      checkin: checkin,
      readiness: readiness,
      techniqueId: techniqueId,
    );
  }

  /// Pings the backend health endpoint.
  Future<bool> checkHealth(String baseUrl) async {
    try {
      final cleanBase = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
      final uri = Uri.parse('$cleanBase${AppConfig.healthEndpoint}');
      final response =
          await _client.get(uri).timeout(AppConfig.timeoutDuration);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Builds request payload strictly adhering to contract.
  Map<String, dynamic> buildPayload({
    required String installId,
    required CheckIn checkin,
    required Readiness readiness,
    required String userMessage,
    List<ExerciseSession> recentSessions = const [],
  }) {
    final bandStr = switch (readiness.band) {
      ReadinessBand.low => 'low',
      ReadinessBand.moderate => 'moderate',
      ReadinessBand.good => 'good',
    };

    return {
      'installId': installId,
      'context': {
        'readinessBand': bandStr,
        'drivers': readiness.drivers.take(5).toList(),
        'mood': checkin.mood.clamp(1, 5),
        'energy': checkin.energy.clamp(1, 5),
        'stress': checkin.stress.clamp(1, 5),
        'tags': checkin.tags.take(10).toList(),
        'recentSummaries': deriveRecentSummaries(recentSessions),
      },
      'userMessage': userMessage,
    };
  }

  /// Formats recent exercise sessions safely with zero PII or raw inputs.
  static List<String> deriveRecentSummaries(List<ExerciseSession> sessions) {
    final summaries = <String>[];
    for (final s in sessions.take(3)) {
      final title = techniqueById(s.techniqueId)?.title ?? s.techniqueId;
      if (s.preMood != null && s.postMood != null) {
        summaries.add('$title (mood: ${s.preMood} -> ${s.postMood})');
      } else {
        summaries.add(title);
      }
    }
    return summaries;
  }

  /// Streams coach response via Server-Sent Events (SSE).
  /// Falls back to [ScriptedCoachEngine] on error or timeout.
  Stream<LlmStreamEvent> streamTurn({
    required String baseUrl,
    required String installId,
    required CheckIn checkin,
    required Readiness readiness,
    required String userMessage,
    required List<CoachMessage> history,
    required String defaultTechniqueId,
    List<ExerciseSession> recentSessions = const [],
  }) async* {
    var rawAccumulated = '';
    var hasCompleted = false;

    try {
      final cleanBase = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
      final uri = Uri.parse('$cleanBase${AppConfig.coachEndpoint}');
      final request = http.Request('POST', uri);
      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'text/event-stream';

      final payload = buildPayload(
        installId: installId,
        checkin: checkin,
        readiness: readiness,
        userMessage: userMessage,
        recentSessions: recentSessions,
      );
      request.body = jsonEncode(payload);

      final streamedResponse =
          await _client.send(request).timeout(AppConfig.timeoutDuration);

      if (streamedResponse.statusCode != 200) {
        throw HttpException(
          'HTTP ${streamedResponse.statusCode} from coach proxy',
        );
      }

      final lines = streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in lines.timeout(AppConfig.timeoutDuration)) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;

        if (trimmed.startsWith('data:')) {
          final dataContent = trimmed.substring(5).trim();
          if (dataContent == '[DONE]') {
            break;
          }

          try {
            final parsed = jsonDecode(dataContent);
            if (parsed is Map<String, dynamic>) {
              final type = parsed['type'];
              if (type == 'chunk') {
                final chunkText = parsed['text']?.toString() ?? '';
                rawAccumulated += chunkText;
                final partial = _extractPartialReply(rawAccumulated);
                if (partial != null && partial.isNotEmpty) {
                  yield LlmChunkEvent(partial);
                }
              } else if (type == 'complete') {
                final data = parsed['data'] as Map<String, dynamic>?;
                if (data != null) {
                  final finalMsg = _buildCompletedMessage(
                    data: data,
                    defaultTechniqueId: defaultTechniqueId,
                  );
                  hasCompleted = true;
                  yield LlmCompleteEvent(finalMsg);
                  break;
                }
              } else if (parsed.containsKey('reply')) {
                // Direct complete JSON frame
                final finalMsg = _buildCompletedMessage(
                  data: parsed,
                  defaultTechniqueId: defaultTechniqueId,
                );
                hasCompleted = true;
                yield LlmCompleteEvent(finalMsg);
                break;
              }
            }
          } catch (_) {
            // If data is plain text chunk rather than JSON
            rawAccumulated += dataContent;
            yield LlmChunkEvent(rawAccumulated);
          }
        }
      }
    } catch (_) {
      // Error or timeout encountered: fall through to fallback
    }

    if (!hasCompleted) {
      // Graceful fallback to ScriptedCoachEngine
      final fallbackMsg = history.isEmpty
          ? _fallbackEngine.start(
              checkin: checkin,
              readiness: readiness,
              techniqueId: defaultTechniqueId,
            )
          : _fallbackEngine.next(
              history: history,
              userReply: userMessage,
              checkin: checkin,
              readiness: readiness,
              techniqueId: defaultTechniqueId,
            );
      yield LlmCompleteEvent(fallbackMsg);
    }
  }

  CoachMessage _buildCompletedMessage({
    required Map<String, dynamic> data,
    required String defaultTechniqueId,
  }) {
    final reply = data['reply']?.toString() ?? '';
    var techId = data['technique_id']?.toString();

    // Validate technique_id against catalog
    if (techId == null || techniqueById(techId) == null) {
      techId = defaultTechniqueId;
    }

    final rawChips = data['chips'];
    List<String>? chips;
    if (rawChips is List) {
      chips = rawChips.map((e) => e.toString()).take(3).toList();
    }

    return CoachMessage(
      text: reply,
      sender: MessageSender.coach,
      chips: chips,
      techniqueId: techId,
      state: CoachState.explore,
    );
  }

  static String? _extractPartialReply(String text) {
    final match =
        RegExp(r'"reply"\s*:\s*"((?:[^"\\]|\\.)*)').firstMatch(text);
    if (match != null) {
      return _unescape(match.group(1) ?? '');
    }
    // If not JSON formatted, return raw stream
    if (!text.trim().startsWith('{')) {
      return text;
    }
    return null;
  }

  static String _unescape(String s) {
    return s
        .replaceAll(r'\"', '"')
        .replaceAll(r'\\', r'\')
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\r', '\r')
        .replaceAll(r'\t', '\t');
  }
}
