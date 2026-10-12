import 'book.dart';

class SearchResult {
  const SearchResult({required this.books, this.fromCache = false});

  final List<Book> books;

  /// true — сеть недоступна, показаны ранее сохранённые результаты.
  final bool fromCache;
}
