import 'package:flutter_test/flutter_test.dart';
import 'package:curadroid/core/services/crisis_detector.dart';

void main() {
  group('CrisisDetector', () {
    test('triggers true for explicit self-harm and suicide phrases', () {
      expect(CrisisDetector.containsCrisisRisk('I want to kill myself'), isTrue);
      expect(CrisisDetector.containsCrisisRisk('Thinking about suicide today'), isTrue);
      expect(CrisisDetector.containsCrisisRisk('I just want to die'), isTrue);
      expect(CrisisDetector.containsCrisisRisk('I feel like self-harm is my only option'), isTrue);
      expect(CrisisDetector.containsCrisisRisk('I might cut myself tonight'), isTrue);
      expect(CrisisDetector.containsCrisisRisk('I have no reason to live anymore'), isTrue);
      expect(CrisisDetector.containsCrisisRisk('I want to overdose'), isTrue);
      expect(CrisisDetector.containsCrisisRisk('I am going to end my life'), isTrue);
    });

    test('ignores punctuation and casing', () {
      expect(CrisisDetector.containsCrisisRisk('I WANT TO DIE!!!'), isTrue);
      expect(CrisisDetector.containsCrisisRisk('kill myself...'), isTrue);
      expect(CrisisDetector.containsCrisisRisk('   suicide?  '), isTrue);
    });

    test('returns false for ordinary everyday check-in messages', () {
      expect(CrisisDetector.containsCrisisRisk('I feel tired and a bit stressed today'), isFalse);
      expect(CrisisDetector.containsCrisisRisk('Work was really overwhelming today.'), isFalse);
      expect(CrisisDetector.containsCrisisRisk('I am feeling anxious about my presentation.'), isFalse);
      expect(CrisisDetector.containsCrisisRisk('Just need a moment to breathe and clear my head.'), isFalse);
      expect(CrisisDetector.containsCrisisRisk('Happy with my progress so far.'), isFalse);
      expect(CrisisDetector.containsCrisisRisk(''), isFalse);
      expect(CrisisDetector.containsCrisisRisk('   '), isFalse);
    });
  });
}
