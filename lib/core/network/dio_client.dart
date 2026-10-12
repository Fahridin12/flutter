import 'package:dio/dio.dart';

/// Dio с таймаутами для публичного API Open Library.
Dio createDioClient() {
  return Dio(
    BaseOptions(
      baseUrl: 'https://openlibrary.org',
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
      headers: const {
        'Accept': 'application/json',
        'User-Agent': 'ReadingTracker/0.8 (student project)',
      },
    ),
  );
}
