// Задача 4. Future, async/await, Stream.
// Запуск: dart run dart_tasks/task4_async.dart

import 'dart:async';

/// Имитация сетевого запроса: возвращает название книги по ISBN.
Future<String> fetchTitleByIsbn(String isbn) async {
  await Future<void>.delayed(const Duration(milliseconds: 300));
  const db = {
    '9780441013593': 'Dune',
    '9785170923180': 'Мастер и Маргарита',
  };
  final title = db[isbn];
  if (title == null) throw StateError('Книга с ISBN $isbn не найдена');
  return title;
}

/// Stream: «читаем» книгу, каждую «секунду» приходит новая страница.
Stream<int> readingProgress(int totalPages, {int step = 100}) async* {
  for (var page = 0; page <= totalPages; page += step) {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    yield page;
  }
}

Future<void> main() async {
  // 1. Последовательные await
  print('Ищем книгу...');
  final title = await fetchTitleByIsbn('9780441013593');
  print('Нашли: $title');

  // 2. Обработка ошибки через try/catch/finally
  try {
    await fetchTitleByIsbn('000');
  } on StateError catch (e) {
    print('Ошибка: ${e.message}');
  } finally {
    print('Запрос завершён');
  }

  // 3. Параллельные запросы через Future.wait
  final sw = Stopwatch()..start();
  final titles = await Future.wait([
    fetchTitleByIsbn('9780441013593'),
    fetchTitleByIsbn('9785170923180'),
  ]);
  print('Параллельно: $titles за ${sw.elapsedMilliseconds} мс');

  // 4. Таймаут
  try {
    await fetchTitleByIsbn('9780441013593').timeout(const Duration(milliseconds: 50));
  } on TimeoutException {
    print('Таймаут сработал');
  }

  // 5. Stream: await for + listen + transform
  await for (final page in readingProgress(300)) {
    print('Прочитано страниц: $page');
  }

  final percent = readingProgress(400).map((p) => (p / 400 * 100).round());
  print('Проценты: ${await percent.toList()}');

  // 6. StreamController: ручная отправка событий
  final controller = StreamController<String>();
  final sub = controller.stream.listen((event) => print('Событие: $event'));
  controller
    ..add('книга добавлена')
    ..add('книга прочитана');
  await controller.close();
  await sub.asFuture<void>();
  print('Готово');
}
