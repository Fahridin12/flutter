import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/book.dart';
import '../../domain/entities/library_filter.dart';
import '../../domain/repositories/library_repository.dart';

export '../../domain/entities/library_filter.dart';

// ---------- События ----------

sealed class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

/// Загрузить локальные данные и запустить синхронизацию.
class LibraryStarted extends LibraryEvent {
  const LibraryStarted();
}

class LibrarySyncRequested extends LibraryEvent {
  const LibrarySyncRequested();
}

class LibraryBookSaved extends LibraryEvent {
  const LibraryBookSaved(this.book);

  final Book book;

  @override
  List<Object?> get props => [book];
}

class LibraryBookDeleted extends LibraryEvent {
  const LibraryBookDeleted(this.bookId);

  final String bookId;

  @override
  List<Object?> get props => [bookId];
}

class LibraryFilterChanged extends LibraryEvent {
  const LibraryFilterChanged(this.filter);

  final LibraryFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// Выход из аккаунта — сбросить состояние.
class LibraryCleared extends LibraryEvent {
  const LibraryCleared();
}

// ---------- Состояние ----------

enum LibraryLoadStatus { initial, loading, success, failure }

class LibraryState extends Equatable {
  const LibraryState({
    this.status = LibraryLoadStatus.initial,
    this.books = const [],
    this.filter = LibraryFilter.all,
    this.isSyncing = false,
  });

  final LibraryLoadStatus status;
  final List<Book> books;
  final LibraryFilter filter;
  final bool isSyncing;

  List<Book> get visibleBooks => books.where(filter.matches).toList();

  LibraryState copyWith({
    LibraryLoadStatus? status,
    List<Book>? books,
    LibraryFilter? filter,
    bool? isSyncing,
  }) {
    return LibraryState(
      status: status ?? this.status,
      books: books ?? this.books,
      filter: filter ?? this.filter,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  @override
  List<Object?> get props => [status, books, filter, isSyncing];
}

// ---------- Bloc ----------

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc(this._repository) : super(const LibraryState()) {
    on<LibraryStarted>(_onStarted);
    on<LibrarySyncRequested>(_onSync, transformer: droppable());
    on<LibraryBookSaved>(_onSaved);
    on<LibraryBookDeleted>(_onDeleted);
    on<LibraryFilterChanged>((e, emit) => emit(state.copyWith(filter: e.filter)));
    on<LibraryCleared>((_, emit) => emit(const LibraryState()));
  }

  final LibraryRepository _repository;

  Future<void> _onStarted(LibraryStarted event, Emitter<LibraryState> emit) async {
    emit(state.copyWith(status: LibraryLoadStatus.loading));
    try {
      final books = await _repository.getBooks();
      emit(state.copyWith(status: LibraryLoadStatus.success, books: books));
    } catch (_) {
      emit(state.copyWith(status: LibraryLoadStatus.failure));
      return;
    }
    add(const LibrarySyncRequested());
  }

  Future<void> _onSync(LibrarySyncRequested event, Emitter<LibraryState> emit) async {
    emit(state.copyWith(isSyncing: true));
    try {
      await _repository.syncWithCloud().timeout(const Duration(seconds: 15));
      final books = await _repository.getBooks();
      emit(state.copyWith(books: books, isSyncing: false, status: LibraryLoadStatus.success));
    } catch (_) {
      // Нет сети — остаёмся на локальных данных (offline-first).
      emit(state.copyWith(isSyncing: false));
    }
  }

  Future<void> _onSaved(LibraryBookSaved event, Emitter<LibraryState> emit) async {
    await _repository.saveBook(event.book);
    final updated = [
      event.book,
      ...state.books.where((b) => b.id != event.book.id),
    ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    emit(state.copyWith(books: updated, status: LibraryLoadStatus.success));
  }

  Future<void> _onDeleted(LibraryBookDeleted event, Emitter<LibraryState> emit) async {
    await _repository.deleteBook(event.bookId);
    emit(state.copyWith(books: state.books.where((b) => b.id != event.bookId).toList()));
  }
}
