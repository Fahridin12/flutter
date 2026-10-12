// Задача 2. Классы, наследование, mixin, enum, extension.
// Запуск: dart run dart_tasks/task2_classes.dart

enum ReadingStatus {
  wantToRead('Хочу прочитать'),
  reading('Читаю'),
  finished('Прочитано');

  const ReadingStatus(this.label);
  final String label;
}

/// Миксин: возможность ставить закладки.
mixin Bookmarkable {
  final List<int> bookmarks = [];

  void addBookmark(int page) {
    if (!bookmarks.contains(page)) {
      bookmarks
        ..add(page)
        ..sort();
    }
  }
}

abstract class Book {
  Book({required this.title, required this.author, this.pages});

  /// Именованный конструктор.
  Book.anonymous(this.title) : author = 'Неизвестен', pages = null;

  final String title;
  final String author;
  final int? pages;
  ReadingStatus status = ReadingStatus.wantToRead;
  int currentPage = 0;

  /// Каждый наследник описывает формат по-своему.
  String get format;

  double get progress {
    final total = pages;
    if (total == null || total == 0) return 0;
    return (currentPage / total).clamp(0.0, 1.0).toDouble();
  }

  void readTo(int page) {
    currentPage = page;
    final total = pages;
    if (total != null && page >= total) {
      status = ReadingStatus.finished;
    } else if (page > 0) {
      status = ReadingStatus.reading;
    }
  }

  @override
  String toString() =>
      '[$format] "$title" — $author, ${status.label}, ${(progress * 100).round()}%';
}

class PaperBook extends Book {
  PaperBook({required super.title, required super.author, super.pages, this.shelf});

  final String? shelf;

  @override
  String get format => 'Бумажная';
}

class EBook extends Book with Bookmarkable {
  EBook({required super.title, required super.author, super.pages, required this.fileSizeMb});

  final double fileSizeMb;

  @override
  String get format => 'Электронная ($fileSizeMb МБ)';
}

extension BookListX on List<Book> {
  int get finishedCount => where((b) => b.status == ReadingStatus.finished).length;
}

void main() {
  final war = PaperBook(title: 'Война и мир', author: 'Лев Толстой', pages: 1300, shelf: 'A2');
  final dune = EBook(title: 'Dune', author: 'Frank Herbert', pages: 600, fileSizeMb: 2.4);

  war.readTo(325);
  dune.readTo(600);
  dune
    ..addBookmark(120)
    ..addBookmark(45)
    ..addBookmark(120); // дубликат проигнорируется

  final books = <Book>[war, dune];
  books.forEach(print);
  print('Закладки Dune: ${dune.bookmarks}'); // [45, 120]
  print('Прочитано книг: ${books.finishedCount}'); // 1
}
