import '../entities/book.dart';

/// Личная библиотека пользователя (offline-first: локальная БД + синхронизация с облаком).
abstract class LibraryRepository {
  Future<List<Book>> getBooks();

  Future<void> saveBook(Book book);

  Future<void> deleteBook(String id);

  /// Двусторонняя синхронизация с облаком (если пользователь вошёл).
  /// Бросает исключение, если сети нет.
  Future<void> syncWithCloud();
}
