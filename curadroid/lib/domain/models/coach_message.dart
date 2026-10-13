enum CoachState { listen, explore, suggest, close }
enum MessageSender { coach, user }

class CoachMessage {
  final String text;
  final MessageSender sender;
  final List<String>? chips; // quick-reply options
  final String? techniqueId; // attached technique card
  final CoachState? state;

  const CoachMessage({
    required this.text,
    required this.sender,
    this.chips,
    this.techniqueId,
    this.state,
  });
}
