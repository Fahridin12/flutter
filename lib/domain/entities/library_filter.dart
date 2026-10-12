import 'book.dart';
import 'reading_status.dart';

/// Фильтр списка книг по статусу.
enum LibraryFilter {
  all,
  wantToRead,
  reading,
  finished;

  bool matches(Book b) => switch (this) {
        LibraryFilter.all => true,
        LibraryFilter.wantToRead => b.status == ReadingStatus.wantToRead,
        LibraryFilter.reading => b.status == ReadingStatus.reading,
        LibraryFilter.finished => b.status == ReadingStatus.finished,
      };
}
