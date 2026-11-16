// lib/board/parent_media.dart

import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Папка на устройстве с фото и записями голоса для карточек родителя.
/// Ничего не отправляется в сеть (П7).
class ParentMedia {
  static Directory? _directory;

  static Future<void> init() async {
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

  static bool get isAvailable => _directory != null;

  /// В профиле лежит только имя файла: полный путь на iOS меняется от запуска
  /// к запуску.
  /// Удаляет файлы карточек (например, вместе с профилем ребёнка).
  static void deleteFiles(Iterable<String?> fileNames) {
    for (final name in fileNames) {
      final target = file(name);
      try {
        if (target != null && target.existsSync()) target.deleteSync();
      } catch (_) {
        // Файл занят или уже удалён: профиль всё равно удалён.
      }
    }
  }

  static File? file(String? fileName) {
    if (_directory == null || fileName == null) return null;
    return File('${_directory!.path}/$fileName');
  }
}
