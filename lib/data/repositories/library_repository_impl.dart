import 'dart:async';

import '../../domain/entities/book.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/firestore_library_data_source.dart';
import '../datasources/local_library_storage.dart';

/// Источник истины для UI — локальная БД (Hive). Каждая запись сразу попадает в Hive,
/// затем отправляется в Firestore. Конфликты решаются по updatedAt (last-write-wins).
class LibraryRepositoryImpl implements LibraryRepository {
  LibraryRepositoryImpl({
    required LocalLibraryStorage local,
    required FirestoreLibraryDataSource remote,
    required AuthRepository auth,
  })  : _local = local,
        _remote = remote,
        _auth = auth;

  final LocalLibraryStorage _local;
  final FirestoreLibraryDataSource _remote;
  final AuthRepository _auth;

  @override
  Future<List<Book>> getBooks() => _local.getAll();

  @override
  Future<void> saveBook(Book book) async {
    await _local.put(book);
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      // Firestore сам кладёт запись в очередь и отправит при появлении сети.
      unawaited(_remote.upsert(uid, book).catchError((Object _) {}));
    }
  }

  @override
  Future<void> deleteBook(String id) async {
    await _local.delete(id);
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      unawaited(_remote.delete(uid, id).catchError((Object _) {}));
    }
  }

  @override
  Future<void> syncWithCloud() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final remoteBooks = await _remote.fetchAll(uid);
    final localBooks = await _local.getAll();
    final localById = {for (final b in localBooks) b.id: b};
    final remoteIds = {for (final b in remoteBooks) b.id};

    for (final remote in remoteBooks) {
      final local = localById[remote.id];
      if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
        await _local.put(remote);
      } else if (local.updatedAt.isAfter(remote.updatedAt)) {
        await _remote.upsert(uid, local);
      }
    }
    // Книги, которых ещё нет в облаке (добавлены офлайн / до входа).
    for (final local in localBooks) {
      if (!remoteIds.contains(local.id)) {
        await _remote.upsert(uid, local);
      }
    }
  }
}
