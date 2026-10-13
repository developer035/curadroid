import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/notification_service.dart';
import 'data/repositories/settings_repo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  final settings = await SettingsRepository.create();

  runApp(
    ProviderScope(
      overrides: [
        settingsRepoProvider.overrideWith((ref) => settings),
      ],
      child: const CuraTrailApp(),
    ),
  );
}
