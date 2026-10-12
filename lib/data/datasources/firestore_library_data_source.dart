import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/book.dart';

/// Облачное хранилище: users/{uid}/books/{bookId}
class FirestoreLibraryDataSource {
  FirestoreLibraryDataSource([this._db]);

  final FirebaseFirestore? _db;

  CollectionReference<Map<String, dynamic>>? _books(String uid) =>
      _db?.collection('users').doc(uid).collection('books');

  Future<List<Book>> fetchAll(String uid) async {
    final books = _books(uid);
    if (books == null) return [];
    final snapshot = await books.get();
    return snapshot.docs.map((d) => Book.fromJson(d.data())).toList();
  }

  Future<void> upsert(String uid, Book book) async {
    await _books(uid)?.doc(book.id).set(book.toJson());
  }

  Future<void> delete(String uid, String bookId) async {
    await _books(uid)?.doc(bookId).delete();
  }
}

