// Задача 3. Коллекции: List, Set, Map, функциональные методы.
// Запуск: dart run dart_tasks/task3_collections.dart

typedef BookRecord = ({String title, String author, int pages, int? rating, bool finished});

final List<BookRecord> library = [
  (title: 'Мастер и Маргарита', author: 'Булгаков', pages: 480, rating: 5, finished: true),
  (title: 'Собачье сердце', author: 'Булгаков', pages: 160, rating: 4, finished: true),
  (title: 'Преступление и наказание', author: 'Достоевский', pages: 600, rating: null, finished: false),
  (title: 'Идиот', author: 'Достоевский', pages: 640, rating: 5, finished: true),
  (title: 'Dune', author: 'Herbert', pages: 600, rating: 5, finished: false),
];

void main() {
  // List: фильтрация, преобразование, сортировка
  final finished = library.where((b) => b.finished).toList();
  print('Прочитанные: ${finished.map((b) => b.title).toList()}');

  final byPages = [...library]..sort((a, b) => b.pages.compareTo(a.pages));
  print('Самая толстая: ${byPages.first.title} (${byPages.first.pages} стр.)');

  // fold: суммарное число прочитанных страниц
  final pagesRead = finished.fold<int>(0, (sum, b) => sum + b.pages);
  print('Страниц прочитано: $pagesRead');

  // Set: уникальные авторы
  final authors = library.map((b) => b.author).toSet();
  print('Авторов: ${authors.length} -> $authors');

  // Map: группировка книг по автору
  final byAuthor = <String, List<String>>{};
  for (final b in library) {
    byAuthor.putIfAbsent(b.author, () => []).add(b.title);
  }
  byAuthor.forEach((author, titles) => print('$author: $titles'));

  // Map: подсчёт оценок (null пропускаем)
  final ratingCounts = <int, int>{};
  for (final r in library.map((b) => b.rating).whereType<int>()) {
    ratingCounts.update(r, (c) => c + 1, ifAbsent: () => 1);
  }
  print('Оценки: $ratingCounts');

  // Средняя оценка
  final ratings = library.map((b) => b.rating).whereType<int>().toList();
  final avg = ratings.isEmpty ? 0 : ratings.reduce((a, b) => a + b) / ratings.length;
  print('Средняя оценка: ${avg.toStringAsFixed(2)}');

  // collection if / collection for / spread
  final labels = [
    for (final b in library)
      if (b.finished) '✓ ${b.title}' else '… ${b.title}',
  ];
  print(labels);

  // any / every / firstWhere с orElse
  print('Есть книга без оценки: ${library.any((b) => b.rating == null)}');
  print('Все больше 100 стр.: ${library.every((b) => b.pages > 100)}');
  final herbert = library.firstWhere(
    (b) => b.author == 'Herbert',
    orElse: () => (title: '—', author: '—', pages: 0, rating: null, finished: false),
  );
  print('Найдено: ${herbert.title}');
}
