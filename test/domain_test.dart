import 'package:flutter_test/flutter_test.dart';
import 'package:reading_tracker/domain/entities/book.dart';
import 'package:reading_tracker/domain/entities/reading_stats.dart';
import 'package:reading_tracker/domain/entities/reading_status.dart';

Book _book(String id, {ReadingStatus status = ReadingStatus.wantToRead, int? pages, int? rating, DateTime? finishedAt, int current = 0}) {
  final now = DateTime(2026, 1, 1);
  return Book(
    id: id,
    title: 'Book $id',
    author: 'Author',
    pageCount: pages,
    status: status,
    currentPage: current,
    rating: rating,
    addedAt: now,
    updatedAt: now,
    finishedAt: finishedAt,
  );
}

void main() {
  group('Book', () {
    test('changeStatus(finished) sets last page and finishedAt', () {
      final b = _book('1', pages: 300, status: ReadingStatus.reading, current: 120);
      final done = b.changeStatus(ReadingStatus.finished);
      expect(done.status, ReadingStatus.finished);
      expect(done.currentPage, 300);
      expect(done.finishedAt, isNotNull);
      expect(done.progress, 1);
    });

    test('changeStatus(wantToRead) resets progress', () {
      final b = _book('1', pages: 300, status: ReadingStatus.reading, current: 120);
      final reset = b.changeStatus(ReadingStatus.wantToRead);
      expect(reset.currentPage, 0);
      expect(reset.finishedAt, isNull);
    });

    test('progress is clamped and safe without pageCount', () {
      expect(_book('1', status: ReadingStatus.reading, current: 50).progress, 0);
      expect(_book('2', pages: 100, status: ReadingStatus.reading, current: 250).progress, 1);
    });

    test('toJson / fromJson roundtrip', () {
      final b = _book('1', pages: 200, rating: 4, status: ReadingStatus.reading, current: 20);
      expect(Book.fromJson(b.toJson()), b);
    });

    test('copyWith(clearRating) removes rating', () {
      expect(_book('1', rating: 5).copyWith(clearRating: true).rating, isNull);
    });
  });

  group('ReadingStats', () {
    test('counts statuses, pages, rating and months', () {
      final now = DateTime(2026, 6, 15);
      final books = [
        _book('1'),
        _book('2', status: ReadingStatus.reading, pages: 200, current: 50),
        _book('3', status: ReadingStatus.finished, pages: 300, rating: 5, finishedAt: DateTime(2026, 3, 2)),
        _book('4', status: ReadingStatus.finished, pages: 100, rating: 3, finishedAt: DateTime(2025, 12, 30)),
      ];
      final stats = ReadingStats.fromBooks(books, now: now);

      expect(stats.total, 4);
      expect(stats.wantToRead, 1);
      expect(stats.reading, 1);
      expect(stats.finished, 2);
      expect(stats.finishedThisYear, 1);
      expect(stats.pagesRead, 50 + 300 + 100);
      expect(stats.averageRating, 4);
      expect(stats.finishedByMonth[2], 1);
      expect(stats.finishedByMonth.fold<int>(0, (a, b) => a + b), 1);
    });

    test('averageRating is null when nothing is rated', () {
      expect(ReadingStats.fromBooks([_book('1')]).averageRating, isNull);
    });
  });
}
