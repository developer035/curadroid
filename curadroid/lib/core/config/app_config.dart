import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  /// Default proxy URL depending on platform.
  /// Android emulators map the host machine's localhost to 10.0.2.2.
  static String get defaultProxyBaseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:2000';
    }
    return 'http://localhost:2000';
  }

  static const String coachEndpoint = '/coach';
  static const String healthEndpoint = '/health';

  static const Duration timeoutDuration = Duration(seconds: 8);
}
