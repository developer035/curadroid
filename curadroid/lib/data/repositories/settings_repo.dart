import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/app_config.dart';

final settingsRepoProvider = ChangeNotifierProvider<SettingsRepository>(
  (ref) => throw UnimplementedError('Override with SettingsRepository.create()'),
);

class SettingsRepository extends ChangeNotifier {
  static const _keyOnboarded = 'onboarded';
  static const _keyUseRealHealth = 'use_real_health';
  static const _keyReminderTime = 'reminder_time';
  static const _keyInstallId = 'anonymous_install_id';
  static const _keyUseAiCoach = 'use_ai_coach';
  static const _keyHasAiConsent = 'has_ai_consent';
  static const _keyProxyBaseUrl = 'proxy_base_url';

  final SharedPreferences _prefs;
  SettingsRepository(this._prefs);

  static Future<SettingsRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsRepository(prefs);
  }

  bool get onboarded => _prefs.getBool(_keyOnboarded) ?? false;
  set onboarded(bool v) {
    _prefs.setBool(_keyOnboarded, v);
    notifyListeners();
  }

  bool get useRealHealth => _prefs.getBool(_keyUseRealHealth) ?? false;
  set useRealHealth(bool v) {
    _prefs.setBool(_keyUseRealHealth, v);
    notifyListeners();
  }

  String? get reminderTime => _prefs.getString(_keyReminderTime);
  set reminderTime(String? v) {
    if (v == null) {
      _prefs.remove(_keyReminderTime);
    } else {
      _prefs.setString(_keyReminderTime, v);
    }
    notifyListeners();
  }

  String get anonymousInstallId {
    var id = _prefs.getString(_keyInstallId);
    if (id == null || id.isEmpty) {
      final rand = math.Random.secure();
      final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
      id = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      _prefs.setString(_keyInstallId, id);
    }
    return id;
  }

  bool get useAiCoach => _prefs.getBool(_keyUseAiCoach) ?? true;
  set useAiCoach(bool v) {
    _prefs.setBool(_keyUseAiCoach, v);
    notifyListeners();
  }

  bool get hasAiConsent => _prefs.getBool(_keyHasAiConsent) ?? false;
  set hasAiConsent(bool v) {
    _prefs.setBool(_keyHasAiConsent, v);
    notifyListeners();
  }

  String get proxyBaseUrl =>
      _prefs.getString(_keyProxyBaseUrl) ?? AppConfig.defaultProxyBaseUrl;
  set proxyBaseUrl(String v) {
    _prefs.setString(_keyProxyBaseUrl, v);
    notifyListeners();
  }
}
