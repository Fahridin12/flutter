import 'package:equatable/equatable.dart';

import 'book.dart';
import 'reading_status.dart';

/// Агрегированная статистика чтения (чистая бизнес-логика, без Flutter).
class ReadingStats extends Equatable {
  const ReadingStats({
    required this.total,
    required this.wantToRead,
    required this.reading,
    required this.finished,
    required this.finishedThisYear,
    required this.pagesRead,
    required this.averageRating,
    required this.finishedByMonth,
  });

  final int total;
  final int wantToRead;
  final int reading;
  final int finished;
  final int finishedThisYear;
  final int pagesRead;

  /// null, если ни одна книга не оценена.
  final double? averageRating;

  /// 12 значений: сколько книг завершено в каждом месяце текущего года.
  final List<int> finishedByMonth;

  factory ReadingStats.fromBooks(List<Book> books, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final byMonth = List<int>.filled(12, 0);
    var want = 0, reading = 0, finished = 0, thisYear = 0, pages = 0;
    final ratings = <int>[];

    for (final b in books) {
      switch (b.status) {
        case ReadingStatus.wantToRead:
          want++;
        case ReadingStatus.reading:
          reading++;
          pages += b.currentPage;
        case ReadingStatus.finished:
          finished++;
          pages += b.pageCount ?? b.currentPage;
          final d = b.finishedAt;
          if (d != null && d.year == today.year) {
            thisYear++;
            byMonth[d.month - 1]++;
          }
      }
      final r = b.rating;
      if (r != null) ratings.add(r);
    }

    return ReadingStats(
      total: books.length,
      wantToRead: want,
      reading: reading,
      finished: finished,
      finishedThisYear: thisYear,
      pagesRead: pages,
      averageRating:
          ratings.isEmpty ? null : ratings.reduce((a, b) => a + b) / ratings.length,
      finishedByMonth: byMonth,
    );
  }

  @override
  List<Object?> get props => [
        total,
        wantToRead,
        reading,
        finished,
        finishedThisYear,
        pagesRead,
        averageRating,
        finishedByMonth,
      ];
}
