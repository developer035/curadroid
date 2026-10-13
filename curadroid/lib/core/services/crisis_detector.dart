/// Offline safety service that flags explicit mentions of self-harm,
/// suicide, or immediate emotional crisis.
class CrisisDetector {
  CrisisDetector._();

  static const List<String> _crisisPhrases = [
    'suicide',
    'kill myself',
    'killing myself',
    'end my life',
    'ending my life',
    'want to die',
    'wanna die',
    'wish i were dead',
    'wish i was dead',
    'self-harm',
    'self harm',
    'cut myself',
    'cutting myself',
    'overdose',
    'hurt myself',
    'hurting myself',
    'no reason to live',
    'better off dead',
    'take my life',
    'taking my life',
    'hang myself',
    'shoot myself',
  ];

  /// Checks whether [text] contains any phrases or keywords indicative of
  /// self-harm, suicide, or crisis risk. Punctuation is stripped and
  /// comparisons are case-insensitive.
  static bool containsCrisisRisk(String text) {
    if (text.trim().isEmpty) return false;

    // Normalize: lowercase, replace punctuation with spaces, collapse whitespace
    final normalized = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (normalized.isEmpty) return false;

    for (final phrase in _crisisPhrases) {
      final cleanPhrase = phrase
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      if (cleanPhrase.contains(' ')) {
        if (normalized.contains(cleanPhrase)) {
          return true;
        }
      } else {
        final regex = RegExp(r'\b' + RegExp.escape(cleanPhrase) + r'\b');
        if (regex.hasMatch(normalized)) {
          return true;
        }
      }
    }

    return false;
  }
}
