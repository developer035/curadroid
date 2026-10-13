import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:curadroid/domain/coach/llm_coach_engine.dart';
import 'package:curadroid/domain/models/checkin.dart';
import 'package:curadroid/domain/models/coach_message.dart';
import 'package:curadroid/domain/models/exercise_session.dart';
import 'package:curadroid/domain/models/readiness.dart';

void main() {
  final testCheckin = CheckIn(
    id: 1,
    ts: DateTime(2026, 10, 12, 8, 30),
    mood: 3,
    energy: 2,
    stress: 4,
    tags: ['work', 'tired'],
  );

  final testReadiness = Readiness(
    score: 65,
    stressIndex: 55,
    band: ReadinessBand.moderate,
    drivers: ['Sleep 45m below baseline'],
  );

  group('LlmCoachEngine payload building', () {
    test('builds compliant payload without raw PII', () {
      final engine = LlmCoachEngine();
      final sessions = [
        ExerciseSession(
          id: 1,
          techniqueId: 'box_breathing',
          startedAt: DateTime.now(),
          completedAt: DateTime.now(),
          preMood: 2,
          postMood: 4,
          inputs: {'private_thought': 'I should not appear in payload'},
        ),
      ];

      final payload = engine.buildPayload(
        installId: 'test-install-123',
        checkin: testCheckin,
        readiness: testReadiness,
        userMessage: 'Hello coach',
        recentSessions: sessions,
      );

      expect(payload['installId'], 'test-install-123');
      expect(payload['userMessage'], 'Hello coach');

      final ctx = payload['context'] as Map<String, dynamic>;
      expect(ctx['readinessBand'], 'moderate');
      expect(ctx['mood'], 3);
      expect(ctx['energy'], 2);
      expect(ctx['stress'], 4);
      expect(ctx['tags'], ['work', 'tired']);

      final summaries = ctx['recentSummaries'] as List;
      expect(summaries.length, 1);
      expect(summaries.first, 'Box Breathing (mood: 2 -> 4)');
      // Verify inputs/notes with PII are never part of the summary
      expect(jsonEncode(payload).contains('private_thought'), isFalse);
    });
  });

  group('LlmCoachEngine SSE stream handling', () {
    test('parses SSE chunks and final complete frame', () async {
      final mockClient = MockClient.streaming((request, bodyStream) async {
        final sseData = [
          'data: {"type":"chunk","text":"Hello, "}\n\n',
          'data: {"type":"chunk","text":"take a breath."}\n\n',
          'data: {"type":"complete","data":{"reply":"Hello, take a breath.","technique_id":"box_breathing","chips":["Let\'s try it","Later"]}}\n\n',
          'data: [DONE]\n\n',
        ];

        return http.StreamedResponse(
          Stream.fromIterable(sseData.map(utf8.encode)),
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      });

      final engine = LlmCoachEngine(client: mockClient);
      final events = await engine.streamTurn(
        baseUrl: 'http://localhost:2000',
        installId: 'test-user',
        checkin: testCheckin,
        readiness: testReadiness,
        userMessage: 'I feel stressed',
        history: const [],
        defaultTechniqueId: 'grounding_54321',
      ).toList();

      expect(events.isNotEmpty, isTrue);
      final completeEvent = events.firstWhere((e) => e is LlmCompleteEvent) as LlmCompleteEvent;
      expect(completeEvent.message.text, 'Hello, take a breath.');
      expect(completeEvent.message.techniqueId, 'box_breathing');
      expect(completeEvent.message.chips, ["Let's try it", "Later"]);
    });

    test('falls back to default technique when backend returns unknown technique_id', () async {
      final mockClient = MockClient.streaming((request, bodyStream) async {
        final sseData = [
          'data: {"type":"complete","data":{"reply":"Empathetic response","technique_id":"unknown_magic_cure","chips":[]}}\n\n',
          'data: [DONE]\n\n',
        ];

        return http.StreamedResponse(
          Stream.fromIterable(sseData.map(utf8.encode)),
          200,
        );
      });

      final engine = LlmCoachEngine(client: mockClient);
      final events = await engine.streamTurn(
        baseUrl: 'http://localhost:2000',
        installId: 'test-user',
        checkin: testCheckin,
        readiness: testReadiness,
        userMessage: 'I feel stressed',
        history: const [],
        defaultTechniqueId: 'grounding_54321',
      ).toList();

      final completeEvent = events.firstWhere((e) => e is LlmCompleteEvent) as LlmCompleteEvent;
      expect(completeEvent.message.techniqueId, 'grounding_54321');
    });

    test('falls back to ScriptedCoachEngine on HTTP 500 error', () async {
      final mockClient = MockClient.streaming((request, bodyStream) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode('Internal Server Error')),
          500,
        );
      });

      final engine = LlmCoachEngine(client: mockClient);
      final events = await engine.streamTurn(
        baseUrl: 'http://localhost:2000',
        installId: 'test-user',
        checkin: testCheckin,
        readiness: testReadiness,
        userMessage: 'I feel stressed',
        history: const [],
        defaultTechniqueId: 'box_breathing',
      ).toList();

      expect(events.length, 1);
      final completeEvent = events.first as LlmCompleteEvent;
      // ScriptedCoachEngine fallback message returned
      expect(completeEvent.message.text.isNotEmpty, isTrue);
      expect(completeEvent.message.sender, MessageSender.coach);
    });

    test('falls back to ScriptedCoachEngine on invalid JSON stream', () async {
      final mockClient = MockClient.streaming((request, bodyStream) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode('data: not-a-json-payload\n\n')),
          200,
        );
      });

      final engine = LlmCoachEngine(client: mockClient);
      final events = await engine.streamTurn(
        baseUrl: 'http://localhost:2000',
        installId: 'test-user',
        checkin: testCheckin,
        readiness: testReadiness,
        userMessage: 'I feel stressed',
        history: const [],
        defaultTechniqueId: 'box_breathing',
      ).toList();

      final completeEvent = events.firstWhere((e) => e is LlmCompleteEvent) as LlmCompleteEvent;
      expect(completeEvent.message.text.isNotEmpty, isTrue);
    });
  });

  group('LlmCoachEngine health check', () {
    test('returns true on 200 OK', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"status":"ok"}', 200);
      });

      final engine = LlmCoachEngine(client: mockClient);
      final ok = await engine.checkHealth('http://localhost:2000');
      expect(ok, isTrue);
    });

    test('returns false on error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Error', 503);
      });

      final engine = LlmCoachEngine(client: mockClient);
      final ok = await engine.checkHealth('http://localhost:2000');
      expect(ok, isFalse);
    });
  });
}
