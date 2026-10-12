import 'dart:convert';

import 'package:hive/hive.dart';

import '../../domain/entities/book.dart';

/// Кэш ответов API (Hive): запрос -> список книг в JSON.
class SearchCacheStorage {
  static const boxName = 'search_cache';
  static const _maxEntries = 30;

  Box<String> get _box => Hive.box<String>(boxName);

  String _key(String query) => query.trim().toLowerCase();

  Future<void> save(String query, List<Book> books) async {
    await _box.put(_key(query), jsonEncode(books.map((b) => b.toJson()).toList()));
    while (_box.length > _maxEntries) {
      await _box.delete(_box.keys.first);
    }
  }

  List<Book>? read(String query) {
    final raw = _box.get(_key(query));
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }
}
