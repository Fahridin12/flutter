// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookDocDto _$BookDocDtoFromJson(Map<String, dynamic> json) => BookDocDto(
      key: json['key'] as String,
      title: json['title'] as String? ?? '',
      authorName: (json['author_name'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      firstPublishYear: (json['first_publish_year'] as num?)?.toInt(),
      coverId: (json['cover_i'] as num?)?.toInt(),
      pagesMedian: (json['number_of_pages_median'] as num?)?.toInt(),
      isbn: (json['isbn'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

SearchResponseDto _$SearchResponseDtoFromJson(Map<String, dynamic> json) =>
    SearchResponseDto(
      numFound: (json['numFound'] as num?)?.toInt() ?? 0,
      docs: (json['docs'] as List<dynamic>?)
              ?.map((e) => BookDocDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
