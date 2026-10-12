import 'package:equatable/equatable.dart';

import 'reading_status.dart';

/// Книга в личной библиотеке пользователя.
class Book extends Equatable {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.addedAt,
    required this.updatedAt,
    this.isbn,
    this.pageCount,
    this.year,
    this.coverUrl,
    this.status = ReadingStatus.wantToRead,
    this.currentPage = 0,
    this.rating,
    this.note,
    this.finishedAt,
  });

  final String id;
  final String title;
  final String author;
  final String? isbn;
  final int? pageCount;
  final int? year;
  final String? coverUrl;
  final ReadingStatus status;
  final int currentPage;

  /// Оценка 1..5, null — не оценена.
  final int? rating;
  final String? note;
  final DateTime addedAt;
  final DateTime updatedAt;
  final DateTime? finishedAt;

  /// Прогресс чтения 0..1.
  double get progress {
    if (status == ReadingStatus.finished) return 1;
    final total = pageCount;
    if (total == null || total <= 0) return 0;
    return (currentPage / total).clamp(0.0, 1.0).toDouble();
  }

  Book copyWith({
    String? title,
    String? author,
    String? isbn,
    int? pageCount,
    int? year,
    String? coverUrl,
    ReadingStatus? status,
    int? currentPage,
    int? rating,
    bool clearRating = false,
    String? note,
    DateTime? updatedAt,
    DateTime? finishedAt,
    bool clearFinishedAt = false,
  }) {
    return Book(
      id: id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      pageCount: pageCount ?? this.pageCount,
      year: year ?? this.year,
      coverUrl: coverUrl ?? this.coverUrl,
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
      rating: clearRating ? null : (rating ?? this.rating),
      note: note ?? this.note,
      addedAt: addedAt,
      updatedAt: updatedAt ?? DateTime.now(),
      finishedAt: clearFinishedAt ? null : (finishedAt ?? this.finishedAt),
    );
  }

  /// Смена статуса с согласованным обновлением страницы и даты завершения.
  Book changeStatus(ReadingStatus newStatus) {
    final now = DateTime.now();
    switch (newStatus) {
      case ReadingStatus.finished:
        return copyWith(
          status: newStatus,
          currentPage: pageCount ?? currentPage,
          finishedAt: now,
          updatedAt: now,
        );
      case ReadingStatus.wantToRead:
        return copyWith(
          status: newStatus,
          currentPage: 0,
          clearFinishedAt: true,
          updatedAt: now,
        );
      case ReadingStatus.reading:
        return copyWith(
          status: newStatus,
          clearFinishedAt: true,
          updatedAt: now,
        );
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'isbn': isbn,
        'pageCount': pageCount,
        'year': year,
        'coverUrl': coverUrl,
        'status': status.name,
        'currentPage': currentPage,
        'rating': rating,
        'note': note,
        'addedAt': addedAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'finishedAt': finishedAt?.toIso8601String(),
      };

  factory Book.fromJson(Map<String, dynamic> json) {
    final finished = json['finishedAt'] as String?;
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String? ?? '',
      isbn: json['isbn'] as String?,
      pageCount: (json['pageCount'] as num?)?.toInt(),
      year: (json['year'] as num?)?.toInt(),
      coverUrl: json['coverUrl'] as String?,
      status: ReadingStatus.fromName(json['status'] as String?),
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toInt(),
      note: json['note'] as String?,
      addedAt: DateTime.parse(json['addedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      finishedAt: finished == null ? null : DateTime.parse(finished),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        isbn,
        pageCount,
        year,
        coverUrl,
        status,
        currentPage,
        rating,
        note,
        addedAt,
        updatedAt,
        finishedAt,
      ];
}
