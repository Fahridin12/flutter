import '../entities/search_result.dart';

abstract class SearchRepository {
  /// Поиск книг во внешнем каталоге. Бросает [Failure].
  Future<SearchResult> searchBooks(String query, {int page = 1});
}
