import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reading_tracker/domain/entities/book.dart';
import 'package:reading_tracker/domain/entities/reading_status.dart';
import 'package:reading_tracker/domain/repositories/library_repository.dart';
import 'package:reading_tracker/presentation/library/library_bloc.dart';

class FakeLibraryRepository implements LibraryRepository {
  FakeLibraryRepository([List<Book>? initial]) : _books = List.of(initial ?? []);

  final List<Book> _books;
  bool syncCalled = false;

  @override
  Future<List<Book>> getBooks() async => List.unmodifiable(_books);

  @override
  Future<void> saveBook(Book book) async {
    _books.removeWhere((b) => b.id == book.id);
    _books.add(book);
  }

  @override
  Future<void> deleteBook(String id) async {
    _books.removeWhere((b) => b.id == id);
  }

  @override
  Future<void> syncWithCloud() async {
    syncCalled = true;
  }
}

Book _createBook(String id, String title, ReadingStatus status) {
  final now = DateTime(2026, 1, 1);
  return Book(
    id: id,
    title: title,
    author: 'Author $id',
    status: status,
    addedAt: now,
    updatedAt: now,
  );
}

void main() {
  group('LibraryBloc', () {
    late FakeLibraryRepository repository;

    final book1 = _createBook('1', 'Book 1', ReadingStatus.wantToRead);
    final book2 = _createBook('2', 'Book 2', ReadingStatus.reading);
    final book3 = _createBook('3', 'Book 3', ReadingStatus.finished);

    setUp(() {
      repository = FakeLibraryRepository([book1, book2, book3]);
    });

    test('initial state has default values', () {
      final bloc = LibraryBloc(repository);
      expect(bloc.state.status, LibraryLoadStatus.initial);
      expect(bloc.state.books, isEmpty);
      expect(bloc.state.filter, LibraryFilter.all);
      expect(bloc.state.isSyncing, isFalse);
    });

    blocTest<LibraryBloc, LibraryState>(
      'emits [loading, success, isSyncing: true, isSyncing: false] on LibraryStarted',
      build: () => LibraryBloc(repository),
      act: (bloc) => bloc.add(const LibraryStarted()),
      expect: () => [
        const LibraryState(status: LibraryLoadStatus.loading),
        LibraryState(
          status: LibraryLoadStatus.success,
          books: [book1, book2, book3],
        ),
        LibraryState(
          status: LibraryLoadStatus.success,
          books: [book1, book2, book3],
          isSyncing: true,
        ),
        LibraryState(
          status: LibraryLoadStatus.success,
          books: [book1, book2, book3],
          isSyncing: false,
        ),
      ],
    );

    blocTest<LibraryBloc, LibraryState>(
      'filters visible books correctly by status',
      build: () => LibraryBloc(repository),
      seed: () => LibraryState(
        status: LibraryLoadStatus.success,
        books: [book1, book2, book3],
      ),
      act: (bloc) => bloc.add(const LibraryFilterChanged(LibraryFilter.reading)),
      expect: () => [
        LibraryState(
          status: LibraryLoadStatus.success,
          books: [book1, book2, book3],
          filter: LibraryFilter.reading,
        ),
      ],
      verify: (bloc) {
        expect(bloc.state.visibleBooks, [book2]);
      },
    );

    blocTest<LibraryBloc, LibraryState>(
      'saves book and updates state',
      build: () => LibraryBloc(repository),
      seed: () => LibraryState(
        status: LibraryLoadStatus.success,
        books: [book1],
      ),
      act: (bloc) => bloc.add(LibraryBookSaved(book2)),
      expect: () => [
        LibraryState(
          status: LibraryLoadStatus.success,
          books: [book2, book1],
        ),
      ],
    );

    blocTest<LibraryBloc, LibraryState>(
      'deletes book and removes from state',
      build: () => LibraryBloc(repository),
      seed: () => LibraryState(
        status: LibraryLoadStatus.success,
        books: [book1, book2],
      ),
      act: (bloc) => bloc.add(LibraryBookDeleted(book1.id)),
      expect: () => [
        LibraryState(
          status: LibraryLoadStatus.success,
          books: [book2],
        ),
      ],
    );

    blocTest<LibraryBloc, LibraryState>(
      'resets state on LibraryCleared',
      build: () => LibraryBloc(repository),
      seed: () => LibraryState(
        status: LibraryLoadStatus.success,
        books: [book1],
      ),
      act: (bloc) => bloc.add(const LibraryCleared()),
      expect: () => [
        const LibraryState(),
      ],
    );
  });
}
