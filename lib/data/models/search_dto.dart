import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/book.dart';

part 'search_dto.g.dart';

/// Один документ из ответа https://openlibrary.org/search.json
@JsonSerializable(createToJson: false)
class BookDocDto {
  const BookDocDto({
    required this.key,
    this.title = '',
    this.authorName,
    this.firstPublishYear,
    this.coverId,
    this.pagesMedian,
    this.isbn,
  });

  factory BookDocDto.fromJson(Map<String, dynamic> json) => _$BookDocDtoFromJson(json);

  /// Например "/works/OL45883W".
  final String key;

  @JsonKey(defaultValue: '')
  final String title;

  @JsonKey(name: 'author_name')
  final List<String>? authorName;

  @JsonKey(name: 'first_publish_year')
  final int? firstPublishYear;

  @JsonKey(name: 'cover_i')
  final int? coverId;

  @JsonKey(name: 'number_of_pages_median')
  final int? pagesMedian;

  final List<String>? isbn;

  /// Преобразование DTO -> доменная сущность.
  Book toBook() {
    final now = DateTime.now();
    final isbns = isbn;
    return Book(
      id: key.split('/').last,
      title: title,
      author: authorName?.take(2).join(', ') ?? '',
      isbn: (isbns == null || isbns.isEmpty) ? null : isbns.first,
      pageCount: pagesMedian,
      year: firstPublishYear,
      coverUrl: coverId == null ? null : 'https://covers.openlibrary.org/b/id/$coverId-M.jpg',
      addedAt: now,
      updatedAt: now,
    );
  }
}

@JsonSerializable(createToJson: false)
class SearchResponseDto {
  const SearchResponseDto({this.numFound = 0, this.docs = const []});

  factory SearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseDtoFromJson(json);

  @JsonKey(defaultValue: 0)
  final int numFound;

  @JsonKey(defaultValue: <BookDocDto>[])
  final List<BookDocDto> docs;
}
