import 'dart:convert';

import 'package:hive/hive.dart';

import '../../domain/entities/book.dart';

/// Локальное хранилище библиотеки на Hive.
/// Отдельный box на каждого пользователя: books_<uid>, чтобы данные разных аккаунтов не смешивались.
class LocalLibraryStorage {
  LocalLibraryStorage(this._uidProvider);

  final String? Function() _uidProvider;

  Future<Box<String>> _box() async {
    final name = 'books_${_uidProvider() ?? 'guest'}';
    if (Hive.isBoxOpen(name)) return Hive.box<String>(name);
    return Hive.openBox<String>(name);
  }

  Future<List<Book>> getAll() async {
    final box = await _box();
    final books = <Book>[];
    for (final raw in box.values) {
      try {
        books.add(Book.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      } catch (_) {
        // Повреждённую запись пропускаем.
      }
    }
    books.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return books;
  }

  Future<void> put(Book book) async {
    final box = await _box();
    await box.put(book.id, jsonEncode(book.toJson()));
  }

  Future<void> delete(String id) async {
    final box = await _box();
    await box.delete(id);
  }
}
