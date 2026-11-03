import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/active_timer.dart';

/// Enregistrement des minuteurs en cours.
abstract class ActiveTimerStore {
  Future<List<ActiveTimer>> load();
  Future<void> save(List<ActiveTimer> timers);
}

/// Enregistrement dans le fichier minuteurs.json du téléphone.
class FileActiveTimerStore implements ActiveTimerStore {
  static const String _fileName = 'minuteurs.json';
  static const int _formatVersion = 1;

  Future<File> _file() async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/$_fileName');
  }

  @override
  Future<List<ActiveTimer>> load() async {
    final file = await _file();
    if (!await file.exists()) return [];
    try {
      final data =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final list = data['timers'] as List<dynamic>? ?? const [];
      final timers = <ActiveTimer>[];
      for (final item in list) {
        try {
          final timer =
              ActiveTimer.fromJson(Map<String, dynamic>.from(item as Map));
          if (timer.recipe.steps.isNotEmpty) timers.add(timer);
        } catch (error) {
          debugPrint('Minuteur illisible ignoré : $error');
        }
      }
      return timers;
    } catch (error) {
      debugPrint('Fichier des minuteurs illisible : $error');
      return [];
    }
  }

  @override
  Future<void> save(List<ActiveTimer> timers) async {
    final file = await _file();
    final temp = File('${file.path}.tmp');
    final data = {
      'version': _formatVersion,
      'timers': timers.map((t) => t.toJson()).toList(),
    };
    await temp.writeAsString(jsonEncode(data), flush: true);
    await temp.rename(file.path);
  }
}