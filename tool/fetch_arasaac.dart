// tool/fetch_arasaac.dart
//
// Скачивает пиктограммы ARASAAC для стартового набора доски общения.
// Запускается вручную разработчиком, приложение во время работы к ARASAAC
// не обращается (П8).
//
//   dart run tool/fetch_arasaac.dart --preview 5   # только показать таблицу
//   dart run tool/fetch_arasaac.dart               # найти и скачать всё
//
// Список слов и результат лежат в assets/pictograms/arasaac/manifest.json.
// Картинки скачиваются для всех слов, в том числе тех, у которых на доске
// показывается Mulberry (source == "mulberry"): так весь набор можно
// переключить одной настройкой kPictogramSet. Для слова с пустым id скрипт ищет
// пиктограмму по русскому слову (searchRu), если не найдено — по английскому
// (searchEn), и берёт первый результат. Если id уже указан (например,
// исправлен вручную), используется он. Картинка скачивается, если файла нет
// или id поменялся с прошлого скачивания (fetchedId).
//
// API (официальная документация https://api.arasaac.org/api-docs/):
//   поиск:    GET https://api.arasaac.org/v1/pictograms/{lang}/search/{text}
//   картинка: https://static.arasaac.org/pictograms/{id}/{id}_500.png

import 'dart:convert';
import 'dart:io';

const _manifestPath = 'assets/pictograms/arasaac/manifest.json';
const _imagesDir = 'assets/pictograms/arasaac';
const _resolution = 500;

String _imageUrl(int id) =>
    'https://static.arasaac.org/pictograms/$id/${id}_$_resolution.png';

final _client = HttpClient();

Future<int?> _search(String lang, String text) async {
  final uri = Uri.parse(
    'https://api.arasaac.org/v1/pictograms/$lang/search/'
    '${Uri.encodeComponent(text)}',
  );
  final request = await _client.getUrl(uri);
  final response = await request.close();
  final body = await response.transform(utf8.decoder).join();
  if (response.statusCode != 200) return null;
  final results = jsonDecode(body);
  if (results is! List || results.isEmpty) return null;
  return (results.first as Map<String, dynamic>)['_id'] as int;
}

Future<void> _download(int id, File target) async {
  final request = await _client.getUrl(Uri.parse(_imageUrl(id)));
  final response = await request.close();
  if (response.statusCode != 200) {
    throw HttpException('HTTP ${response.statusCode} для ${_imageUrl(id)}');
  }
  final bytes = await response.fold<List<int>>([], (a, b) => a..addAll(b));
  await target.writeAsBytes(bytes);
}

Future<void> main(List<String> args) async {
  final previewIndex = args.indexOf('--preview');
  final preview = previewIndex >= 0;
  final previewCount =
      preview && args.length > previewIndex + 1
          ? int.parse(args[previewIndex + 1])
          : 5;

  final manifestFile = File(_manifestPath);
  final manifest =
      jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>;
  final words = (manifest['words'] as List).cast<Map<String, dynamic>>();

  final selected = preview ? words.take(previewCount) : words;
  final rows = <List<String>>[];

  for (final word in selected) {
    final name = word['word'] as String;
    var id = word['id'] as int?;
    var foundBy = 'id из manifest';
    if (id == null) {
      id = await _search('ru', word['searchRu'] as String);
      foundBy = 'ru';
      if (id == null) {
        id = await _search('en', word['searchEn'] as String);
        foundBy = 'en';
      }
    }
    if (id == null) {
      rows.add([name, 'НЕ НАЙДЕНО', '', '${word['source']}']);
      continue;
    }
    if (preview) {
      rows.add([name, '$id ($foundBy)', _imageUrl(id), '${word['source']}']);
      continue;
    }
    word['id'] = id;
    final target = File('$_imagesDir/${word['file']}');
    if (!target.existsSync() || word['fetchedId'] != id) {
      await _download(id, target);
      word['fetchedId'] = id;
    }
    rows.add([
      name,
      '$id ($foundBy)',
      '$_imagesDir/${word['file']}',
      '${word['source']}',
    ]);
  }

  if (!preview) {
    await manifestFile.writeAsString(
      '${const JsonEncoder.withIndent('  ').convert(manifest)}\n',
    );
  }

  stdout.writeln(preview
      ? 'Предпросмотр (ничего не скачано):'
      : 'Готово, manifest.json обновлён:');
  stdout.writeln(
    '| слово | id ARASAAC | ${preview ? 'ссылка' : 'файл'} | на доске |',
  );
  stdout.writeln('| --- | --- | --- | --- |');
  for (final row in rows) {
    stdout.writeln('| ${row.join(' | ')} |');
  }
  _client.close();
}
