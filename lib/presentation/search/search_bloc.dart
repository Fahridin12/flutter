import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/book.dart';
import '../../domain/failure.dart';
import '../../domain/repositories/search_repository.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Pull-to-refresh: повторить текущий запрос без debounce.
class SearchRefreshed extends SearchEvent {
  const SearchRefreshed();
}

enum SearchStatus { initial, loading, success, empty, failure }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.books = const [],
    this.fromCache = false,
    this.failure,
  });

  final SearchStatus status;
  final String query;
  final List<Book> books;
  final bool fromCache;
  final FailureType? failure;

  @override
  List<Object?> get props => [status, query, books, fromCache, failure];
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._repository) : super(const SearchState()) {
    // restartable: новый ввод отменяет предыдущий обработчик -> debounce через Future.delayed.
    on<SearchQueryChanged>(_onQueryChanged, transformer: restartable());
    on<SearchRefreshed>(_onRefreshed, transformer: droppable());
  }

  static const minQueryLength = 2;
  static const debounce = Duration(milliseconds: 400);

  final SearchRepository _repository;

  Future<void> _onQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) async {
    final query = event.query.trim();
    if (query.length < minQueryLength) {
      emit(const SearchState());
      return;
    }
    await Future<void>.delayed(debounce);
    emit(SearchState(status: SearchStatus.loading, query: query));
    await _load(query, emit);
  }

  Future<void> _onRefreshed(SearchRefreshed event, Emitter<SearchState> emit) async {
    final query = state.query;
    if (query.length < minQueryLength) return;
    await _load(query, emit);
  }

  Future<void> _load(String query, Emitter<SearchState> emit) async {
    try {
      final result = await _repository.searchBooks(query);
      emit(SearchState(
        status: result.books.isEmpty ? SearchStatus.empty : SearchStatus.success,
        query: query,
        books: result.books,
        fromCache: result.fromCache,
      ));
    } on Failure catch (f) {
      emit(SearchState(status: SearchStatus.failure, query: query, failure: f.type));
    } catch (_) {
      emit(SearchState(status: SearchStatus.failure, query: query, failure: FailureType.unknown));
    }
  }
}
