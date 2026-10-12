import 'package:flutter_test/flutter_test.dart';
import 'package:reading_tracker/data/models/search_dto.dart';
import 'package:reading_tracker/domain/entities/reading_status.dart';

void main() {
  group('Search DTOs', () {
    test('BookDocDto.fromJson parses complete JSON', () {
      final json = {
        'key': '/works/OL45883W',
        'title': 'Dune',
        'author_name': ['Frank Herbert', 'Brian Herbert'],
        'first_publish_year': 1965,
        'cover_i': 12345,
        'number_of_pages_median': 600,
        'isbn': ['9780441013593', '0441013597'],
      };

      final dto = BookDocDto.fromJson(json);
      expect(dto.key, '/works/OL45883W');
      expect(dto.title, 'Dune');
      expect(dto.authorName, ['Frank Herbert', 'Brian Herbert']);
      expect(dto.firstPublishYear, 1965);
      expect(dto.coverId, 12345);
      expect(dto.pagesMedian, 600);
      expect(dto.isbn?.first, '9780441013593');

      final book = dto.toBook();
      expect(book.id, 'OL45883W');
      expect(book.title, 'Dune');
      expect(book.author, 'Frank Herbert, Brian Herbert');
      expect(book.year, 1965);
      expect(book.pageCount, 600);
      expect(book.coverUrl, 'https://covers.openlibrary.org/b/id/12345-M.jpg');
      expect(book.status, ReadingStatus.wantToRead);
      expect(book.currentPage, 0);
    });

    test('BookDocDto.fromJson handles nullable and missing fields safely', () {
      final json = <String, dynamic>{
        'key': '/works/OL00000W',
      };

      final dto = BookDocDto.fromJson(json);
      expect(dto.key, '/works/OL00000W');
      expect(dto.title, '');
      expect(dto.authorName, isNull);
      expect(dto.coverId, isNull);

      final book = dto.toBook();
      expect(book.id, 'OL00000W');
      expect(book.title, '');
      expect(book.author, '');
      expect(book.coverUrl, isNull);
      expect(book.pageCount, isNull);
      expect(book.isbn, isNull);
    });

    test('SearchResponseDto.fromJson parses empty and populated docs list', () {
      final emptyJson = <String, dynamic>{'numFound': 0, 'docs': <dynamic>[]};
      final emptyResponse = SearchResponseDto.fromJson(emptyJson);
      expect(emptyResponse.numFound, 0);
      expect(emptyResponse.docs, isEmpty);

      final populatedJson = {
        'numFound': 1,
        'docs': [
          {'key': '/works/OL1', 'title': 'Test Book'},
        ],
      };
      final populatedResponse = SearchResponseDto.fromJson(populatedJson);
      expect(populatedResponse.numFound, 1);
      expect(populatedResponse.docs.length, 1);
      expect(populatedResponse.docs.first.title, 'Test Book');
    });
  });
}
