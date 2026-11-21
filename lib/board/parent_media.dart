// lib/board/parent_media.dart

import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Фото и записи голоса для карточек родителя. Ничего не отправляется в сеть (П7).
///
/// На телефоне и компьютере это файлы в папке приложения. В браузере папок нет:
/// файлы лежат в памяти этого браузера (localStorage), каждый под своим ключом.
/// В профиле в обоих случаях хранится только имя файла.
class ParentMedia {
  static Directory? _directory;

  static SharedPreferences? _prefs;
  static final Map<String, Uint8List> _webFiles = {};
  static const _webPrefix = 'aila_media_';

  static Future<void> init() async {
    if (kIsWeb) {
      try {
        final prefs = await SharedPreferences.getInstance();
        for (final key in prefs.getKeys()) {
          if (!key.startsWith(_webPrefix)) continue;
          final data = prefs.getString(key);
          if (data == null) continue;
          _webFiles[key.substring(_webPrefix.length)] = base64Decode(data);
        }
        _prefs = prefs;
      } catch (_) {
        // Браузер не даёт хранить данные: доска работает без карточек родителя.
        _prefs = null;
      }
      return;
    }
    try {
      final documents = await getApplicationDocumentsDirectory();
      final directory = Directory('${documents.path}/aila_parent_cards');
      await directory.create(recursive: true);
      _directory = directory;
    } catch (_) {
      // Без папки доска работает, недоступны только карточки родителя.
      _directory = null;
    }
  }

  static bool get isAvailable => kIsWeb ? _prefs != null : _directory != null;

  /// Сохраняет файл. Возвращает false, если места не хватило (в браузере
  /// память ограничена несколькими мегабайтами).
  static Future<bool> save(String fileName, Uint8List bytes) async {
    if (kIsWeb) {
      final prefs = _prefs;
      if (prefs == null) return false;
      try {
        final ok = await prefs.setString(
          '$_webPrefix$fileName',
          base64Encode(bytes),
        );
        if (!ok) return false;
        _webFiles[fileName] = bytes;
        return true;
      } catch (_) {
        return false;
      }
    }
    final target = file(fileName);
    if (target == null) return false;
    try {
      await target.writeAsBytes(bytes, flush: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  static bool exists(String? fileName) {
    if (fileName == null) return false;
    if (kIsWeb) return _webFiles.containsKey(fileName);
    return file(fileName)?.existsSync() ?? false;
  }

  /// Картинка карточки или null, если файла нет.
  static ImageProvider? image(String? fileName) {
    if (fileName == null) return null;
    if (kIsWeb) {
      final bytes = _webFiles[fileName];
      return bytes == null ? null : MemoryImage(bytes);
    }
    final target = file(fileName);
    return target == null ? null : FileImage(target);
  }

  /// Запись голоса для проигрывания или null, если её нет.
  static Source? audio(String? fileName) {
    if (fileName == null || !exists(fileName)) return null;
    if (kIsWeb) {
      return BytesSource(
        _webFiles[fileName]!,
        mimeType: fileName.endsWith('.webm') ? 'audio/webm' : 'audio/mp4',
      );
    }
    return DeviceFileSource(file(fileName)!.path);
  }

  /// Удаляет файлы карточек (например, вместе с профилем ребёнка).
  static void deleteFiles(Iterable<String?> fileNames) {
    for (final name in fileNames) {
      if (name == null) continue;
      if (kIsWeb) {
        _webFiles.remove(name);
        _prefs?.remove('$_webPrefix$name');
        continue;
      }
      final target = file(name);
      try {
        if (target != null && target.existsSync()) target.deleteSync();
      } catch (_) {
        // Файл занят или уже удалён: профиль всё равно удалён.
      }
    }
  }

  /// Путь к файлу на устройстве (не в браузере). Полный путь не хранится:
  /// на iOS он меняется от запуска к запуску.
  static File? file(String? fileName) {
    if (kIsWeb || _directory == null || fileName == null) return null;
    return File('${_directory!.path}/$fileName');
  }
}
