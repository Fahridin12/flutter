// Задача 1. Null safety на примере данных о книге.
// Запуск: dart run dart_tasks/task1_null_safety.dart

/// Возвращает автора или заглушку, если автор не указан.
String describeAuthor(String? author) {
  // Flow analysis: после проверки на null компилятор «знает», что author не null.
  if (author == null || author.trim().isEmpty) {
    return 'Автор неизвестен';
  }
  return author.trim();
}

/// Безопасно превращает строку в число страниц (может вернуть null).
int? parsePages(String? raw) => raw == null ? null : int.tryParse(raw.trim());

/// Процент прочитанного; null, если общее число страниц неизвестно.
double? progressPercent({required int currentPage, int? totalPages}) {
  if (totalPages == null || totalPages <= 0) return null;
  return (currentPage / totalPages * 100).clamp(0, 100).toDouble();
}

class Profile {
  // late — инициализация откладывается, но обязательно произойдёт до первого чтения.
  late final String displayName;

  // Необязательное поле.
  String? favoriteGenre;

  void init(String name) => displayName = name;
}

void main() {
  print(describeAuthor(null)); // Автор неизвестен
  print(describeAuthor('  Фёдор Достоевский ')); // Фёдор Достоевский

  print(parsePages('320')); // 320
  print(parsePages('abc')); // null
  print(parsePages(null)); // null

  // Оператор ?? — значение по умолчанию.
  final pages = parsePages('x') ?? 0;
  print('pages = $pages');

  // Оператор ?. — безопасный вызов; результат тоже nullable.
  const String? title = null;
  print(title?.toUpperCase()); // null
  print(title?.length ?? -1); // -1

  // Оператор ??= — присвоить, только если сейчас null.
  String? note;
  note ??= 'Первая заметка';
  print(note); // Первая заметка

  // Оператор ! — «я уверен, что не null» (использовать осторожно!).
  const String? maybe = 'не null';
  print(maybe!.length);

  final percent = progressPercent(currentPage: 150, totalPages: 300);
  print('Прогресс: ${percent?.toStringAsFixed(1) ?? 'нет данных'}%');
  print('Прогресс: ${progressPercent(currentPage: 10)?.toStringAsFixed(1) ?? 'нет данных'}');

  final profile = Profile()..init('Студент');
  profile.favoriteGenre ??= 'Фантастика';
  print('${profile.displayName} любит ${profile.favoriteGenre}');
}
