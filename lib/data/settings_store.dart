import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/active_timer.dart';

/// Réglages de l'application. D'autres réglages s'ajouteront en phase 4.
@immutable
class AppSettings {
  const AppSettings({this.lastLaunchMode = LaunchMode.automatic});

  /// Dernier mode choisi au lancement (présélectionné la fois suivante).
  final LaunchMode lastLaunchMode;

  AppSettings copyWith({LaunchMode? lastLaunchMode}) {
    return AppSettings(lastLaunchMode: lastLaunchMode ?? this.lastLaunchMode);
  }

  Map<String, dynamic> toJson() => {'lastLaunchMode': lastLaunchMode.key};

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      lastLaunchMode: LaunchMode.fromKey(json['lastLaunchMode'] as String?),
    );
  }
}

/// Lecture et écriture des réglages dans settings.json.
class SettingsStore extends ChangeNotifier {
  static const String _fileName = 'settings.json';

  AppSettings _settings = const AppSettings();

  AppSettings get settings => _settings;

  Future<File> _file() async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<void> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return;
      final data =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      _settings = AppSettings.fromJson(data);
      notifyListeners();
    } catch (error) {
      debugPrint('Réglages illisibles, valeurs par défaut : $error');
    }
  }

  Future<void> update(AppSettings settings) async {
    _settings = settings;
    notifyListeners();
    try {
      final file = await _file();
      final temp = File('${file.path}.tmp');
      await temp.writeAsString(jsonEncode(settings.toJson()), flush: true);
      await temp.rename(file.path);
    } catch (error) {
      debugPrint('Réglages non enregistrés : $error');
    }
  }
}