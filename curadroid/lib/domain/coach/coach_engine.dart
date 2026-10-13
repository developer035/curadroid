import '../../domain/models/checkin.dart';
import '../../domain/models/coach_message.dart';
import '../../domain/models/readiness.dart';

abstract class CoachEngine {
  /// Start a new coach session and return the first [Listen] message.
  CoachMessage start({required CheckIn checkin, required Readiness readiness, required String techniqueId});

  /// Progress the conversation after a user reply and return the next coach message.
  CoachMessage next({
    required List<CoachMessage> history,
    required String? userReply,
    required CheckIn checkin,
    required Readiness readiness,
    required String techniqueId,
  });
}
