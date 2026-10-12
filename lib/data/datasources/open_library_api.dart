import 'package:dio/dio.dart';

import '../models/search_dto.dart';

class OpenLibraryApi {
  OpenLibraryApi(this._dio);

  final Dio _dio;

  Future<SearchResponseDto> search(String query, {int page = 1, int limit = 20}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/search.json',
      queryParameters: {
        'q': query,
        'page': page,
        'limit': limit,
        'fields': 'key,title,author_name,first_publish_year,cover_i,'
            'number_of_pages_median,isbn',
      },
    );
    final data = response.data;
    if (data == null) {
      throw const FormatException('Пустой ответ сервера');
    }
    return SearchResponseDto.fromJson(data);
  }
}
