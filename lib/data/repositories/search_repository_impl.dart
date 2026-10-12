import 'package:dio/dio.dart';

import '../../domain/entities/search_result.dart';
import '../../domain/failure.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/open_library_api.dart';
import '../datasources/search_cache_storage.dart';

/// Offline-first для поиска: при ошибке сети возвращаем кэш по тому же запросу.
class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl({required OpenLibraryApi api, required SearchCacheStorage cache})
      : _api = api,
        _cache = cache;

  final OpenLibraryApi _api;
  final SearchCacheStorage _cache;

  @override
  Future<SearchResult> searchBooks(String query, {int page = 1}) async {
    try {
      final dto = await _api.search(query, page: page);
      final books = dto.docs.where((d) => d.title.isNotEmpty).map((d) => d.toBook()).toList();
      if (page == 1) await _cache.save(query, books);
      return SearchResult(books: books);
    } on DioException catch (e) {
      final cached = page == 1 ? _cache.read(query) : null;
      if (cached != null) return SearchResult(books: cached, fromCache: true);
      throw _mapDio(e);
    } on FormatException catch (e) {
      throw Failure(FailureType.parse, e.message);
    } on TypeError catch (_) {
      throw const Failure(FailureType.parse);
    }
  }

  Failure _mapDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const Failure(FailureType.timeout);
      case DioExceptionType.connectionError:
        return const Failure(FailureType.network);
      case DioExceptionType.badResponse:
        return Failure(FailureType.server, '${e.response?.statusCode}');
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const Failure(FailureType.unknown);
    }
  }
}
